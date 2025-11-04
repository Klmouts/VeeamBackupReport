<#
.SYNOPSIS
    Retrieves details about all Veeam backup jobs.
.DESCRIPTION
    Fetches job name, type, last result, timestamps, and description.
.AUTHOR
    Klontian Moutsa
.DATE
    2024-08-29
#>



function Get-BackupJobs {
    [CmdletBinding()]
    param ()

    Write-Host "Collecting Veeam backup jobs..." -ForegroundColor Cyan
    $jobResults = @()

    foreach ($job in Get-VBRJob -WarningAction SilentlyContinue) {
        $lastResult = "No sessions found"
        $startTime = ""
        $endTime = ""

        try {
            if ($job.JobType -eq "SimpleBackupCopyPolicy") {
                $workers = $job.GetWorkerJobs()
                foreach ($worker in $workers) {
                    $lastSession = [Veeam.Backup.Core.CBackupSession]::GetByJob($worker.Id) |
                                   Where-Object { $_.State -eq 'Stopped' } |
                                   Sort-Object EndTimeUTC -Descending |
                                   Select-Object -First 1
                    if ($lastSession) {
                        $lastResult = $lastSession.Result
                        $startTime  = $lastSession.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                        $endTime    = $lastSession.EndTime.ToString("yyyy-MM-dd HH:mm:ss")
                    }
                }
            } else {
                $vmSessions  = Get-VBRBackupSession -WarningAction SilentlyContinue | Where-Object { $_.JobId -eq $job.Id }
                $compSessions= Get-VBRComputerBackupJobSession -WarningAction SilentlyContinue | Where-Object { $_.JobId -eq $job.Id }
                $sessions    = $vmSessions + $compSessions
                if ($sessions.Count -gt 0) {
                    $lastSession = $sessions | Sort-Object CreationTime -Descending | Select-Object -First 1
                    if ($lastSession) {
                        $lastResult = $lastSession.Result
                        $startTime  = $lastSession.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                        $endTime    = $lastSession.EndTime.ToString("yyyy-MM-dd HH:mm:ss")
                    }
                }
            }

            $jobResults += [PSCustomObject]@{
                Name        = $job.Name
                JobType     = Get-UserFriendlyJobType -JobType $job.JobType
                LastResult  = $lastResult
                StartTime   = $startTime
                EndTime     = $endTime
                Description = $job.Description
            }
        } catch {
            Write-Host "Failed to retrieve job details for $($job.Name): $_" -ForegroundColor Red
        }
    }

    return $jobResults
}
