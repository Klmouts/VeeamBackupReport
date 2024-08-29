<#
.SYNOPSIS
    This script retrieves and reports on various Veeam Backup and Recovery job details, including job statuses, backup sessions, and repository usage.

.DESCRIPTION
    This PowerShell script is designed to interact with Veeam Backup and Recovery modules to:
    - Import necessary Veeam PowerShell modules.
    - Provide a user-friendly name for each job type.
    - Collect and display details about backup jobs, including last results, start and end times.
    - Retrieve details about Backup to Tape jobs.
    - Gather information about Backup Repositories, including total and free space.
    - Handle Backup for Office 365 jobs if the relevant module is installed.
    - Output the results in a formatted table.

.NOTES
    File Name       : VeeamScriptReport.ps1
    Author          : Klontian Moutsa
    Created         : 29/08/2024
    Last Modified   : 29/08/2024
    Requirements    : Veeam Backup & Replication PowerShell modules and/or Veeam Backup for Office 365 module.
#>

# Load Veeam PowerShell modules
Import-Module -Name Veeam.Backup.PowerShell
Import-Module -Name Veeam.Archiver.PowerShell -ErrorAction SilentlyContinue

# Function to map job types to user-friendly names
function Get-UserFriendlyJobType {
    param (
        [string]$JobType
    )
    switch ($JobType) {
        "EpAgentBackup"          { return "Endpoint Backup" }
        "SimpleBackupCopyPolicy" { return "Policy Backup" }
        "VMBackup"               { return "VM Backup" }
        "FileBackup"             { return "File Backup" }
        "TapeBackup"             { return "Tape Backup" }
        "ReplicaJob"             { return "Replication Backup" }
        "NetworkBackup"          { return "Network Backup" }
        "SQLBackup"              { return "SQL Backup" }
        "OracleBackup"           { return "Oracle Backup" }
        "NASBackup"              { return "NAS Backup" }
        "SharePointBackup"       { return "SharePoint Backup" }
        "ExchangeBackup"         { return "Exchange Backup" }
        default                  { return $JobType } # Default to the original type if no match
    }
}

# Function to get Backup to Tape details
function Get-BackupToTapeDetails {
    $jobs = Get-VBRTapeJob | Where-Object { $_.Type -eq 'BackupToTape' }
    $backupToTapeDetails = @()

    foreach ($job in $jobs) {
        $jobId = $job.Id
        if ($jobId -is [System.Object[]]) {
            $jobId = $jobId[0]
        }

        try {
            $session = [Veeam.Backup.Core.CBackupSession]::GetByJob($jobId) | 
                       Sort-Object -Property EndTime -Descending | 
                       Select-Object -First 1

            $jobDetail = [PSCustomObject]@{
                Name        = $job.Name
                JobType     = "Tape Backup"
                LastResult  = if ($session) { $session.Result } else { "No sessions found" }
                StartTime   = if ($session) { $session.CreationTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
                EndTime     = if ($session) { $session.EndTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
                Description = $job.Description
            }
            $backupToTapeDetails += $jobDetail
        } catch {
            Write-Output "Failed to retrieve session details for $($job.Name): $_"
        }
    }
    return $backupToTapeDetails
}

# Initialize array to store job results
$jobResults = @()

# Process Backup Jobs
foreach ($job in Get-VBRJob -WarningAction SilentlyContinue) {
    $lastResult = "No sessions found"
    $startTime = "No sessions found"
    $endTime = "No sessions found"

    try {
        if ($job.JobType -eq "SimpleBackupCopyPolicy") {
            $workers = $job.GetWorkerJobs()
            foreach ($worker in $workers) {
                $workerId = $worker.Id
                if ($workerId -is [System.Object[]]) {
                    $workerId = $workerId[0]
                }

                $lastSession = [Veeam.Backup.Core.CBackupSession]::GetByJob($workerId) |
                               Where-Object { $_.State -eq 'Stopped' } |
                               Sort-Object EndTimeUTC -Descending |
                               Select-Object -First 1

                if ($lastSession) {
                    $lastResult = $lastSession.Result
                    $startTime = $lastSession.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                    $endTime = $lastSession.EndTime.ToString("yyyy-MM-dd HH:mm:ss")
                }
            }
        } else {
            $vmSessions = Get-VBRBackupSession -WarningAction SilentlyContinue | Where-Object { $_.JobId -eq $job.Id }
            $compSessions = Get-VBRComputerBackupJobSession -WarningAction SilentlyContinue | Where-Object { $_.JobId -eq $job.Id }
            $sessions = $vmSessions + $compSessions

            if ($sessions.Count -gt 0) {
                $lastSession = $sessions | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
                if ($lastSession) {
                    $lastResult = $lastSession.Result
                    $startTime = $lastSession.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                    $endTime = $lastSession.EndTime.ToString("yyyy-MM-dd HH:mm:ss")
                }
            }
        }

        $jobResult = [PSCustomObject]@{
            Name        = $job.Name
            JobType     = Get-UserFriendlyJobType -JobType $job.JobType
            LastResult  = $lastResult
            StartTime   = if ($startTime -ne "No sessions found") { $startTime } else { "" }
            EndTime     = if ($endTime -ne "No sessions found") { $endTime } else { "" }
            Description = if ($job.Name -like "*Office 365*") { "Entire Organization Backup 365" } else { $job.Description }
        }
        $jobResults += $jobResult
    } catch {
        Write-Output "Failed to retrieve job session details for $($job.Name): $_"
    }
}

# Process Office 365 Backup Jobs
if (Get-Module -Name Veeam.Archiver.PowerShell) {
    foreach ($job in Get-VBOJob -WarningAction SilentlyContinue) {
        $lastResult = "No sessions found"
        $startTime = "No sessions found"
        $endTime = "No sessions found"

        try {
            $sessions = Get-VBOJobSession -WarningAction SilentlyContinue | Where-Object { $_.JobId -eq $job.Id }

            if ($sessions.Count -gt 0) {
                $lastSession = $sessions | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
                if ($lastSession) {
                    $lastResult = $lastSession.Status  # Adjust if 'Status' is not the correct property
                    $startTime = $lastSession.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                    $endTime = $lastSession.EndTime.ToString("yyyy-MM-dd HH:mm:ss")
                }
            }

            $jobResult = [PSCustomObject]@{
                Name        = $job.Name
                JobType     = "Office 365 Backup"
                LastResult  = $lastResult
                StartTime   = if ($startTime -ne "No sessions found") { $startTime } else { "" }
                EndTime     = if ($endTime -ne "No sessions found") { $endTime } else { "" }
                Description = "Entire Organization Backup 365"
            }
            $jobResults += $jobResult
        } catch {
            Write-Output "Failed to retrieve job session details for $($job.Name): $_"
        }
    }
} else {
    Write-Output "Veeam Backup for Office 365 module is not installed."
}

# Retrieve Backup to Tape details
$backupToTapeDetails = Get-BackupToTapeDetails
$jobResults += $backupToTapeDetails

# Retrieve Configuration Backup details
try {
    $jobType = [Veeam.Backup.Model.EDbJobType]::ConfBackup
    $configBackup = [Veeam.Backup.Core.CBaseSession]::FindLastByJobType($jobType)
    $serverName = $env:COMPUTERNAME

    $configBackupResult = [PSCustomObject]@{
        Name        = "Configuration Backup on $serverName"
        JobType     = "Configuration Backup"
        LastResult  = if ($configBackup) { $configBackup.Result } else { "No sessions found" }
        StartTime   = if ($configBackup) { $configBackup.StartTime } else { "No sessions found" }
        EndTime     = if ($configBackup) { $configBackup.EndTime } else { "No sessions found" }
        Description = "Configuration Backup on $serverName"
    }
    $jobResults += $configBackupResult
} catch {
    Write-Output "Failed to retrieve configuration backup details: $_"
}

# Retrieve Backup Repository details
$repoResults = @()
$BackupRepos = Get-VBRBackupRepository | Where-Object {$_.Type -ne "SanSnapshotOnly"}
$ScaleOuts = Get-VBRBackupRepository -ScaleOut

if ($ScaleOuts) {
    foreach ($ScaleOut in $ScaleOuts) {
        $Extents = Get-VBRRepositoryExtent -Repository $ScaleOut
        foreach ($Extent in $Extents) {
            $BackupRepos += $Extent.repository
        }
    }
}

foreach ($BackupRepo in $BackupRepos) {
    try {
        if ($BackupRepo -and $BackupRepo.GetContainer()) {
            $TotalSpaceGb = $BackupRepo.GetContainer().CachedTotalSpace.InGigabytes
            $FreeSpaceGb = $BackupRepo.GetContainer().CachedFreeSpace.InGigabytes
            $PercentUsed = if ($TotalSpaceGb -ne 0) { ((($TotalSpaceGb - $FreeSpaceGb) / $TotalSpaceGb) * 100).ToString("F2") + "%" } else { "N/A" }
            $repoResult = [PSCustomObject]@{
                Name       = $BackupRepo.Name
                Type       = $BackupRepo.Type
                TotalSpace = "{0:N2} GB" -f $TotalSpaceGb
                FreeSpace  = "{0:N2} GB" -f $FreeSpaceGb
                PercentUsed= $PercentUsed
                Description= $BackupRepo.Description
            }
            $repoResults += $repoResult
        }
    } catch {
        Write-Output "Failed to retrieve repository details for $($BackupRepo.Name): $_"
    }
}

# Output results
$jobResults | Format-Table -AutoSize
$repoResults | Format-Table -AutoSize
