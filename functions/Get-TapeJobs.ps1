function Get-TapeJobs {
    [CmdletBinding()]
    param ()

    Write-Host "Gathering Backup to Tape job details..." -ForegroundColor Cyan
    $jobs = Get-VBRTapeJob | Where-Object { $_.Type -eq 'BackupToTape' }
    $results = @()

    foreach ($job in $jobs) {
        try {
            $session = [Veeam.Backup.Core.CBackupSession]::GetByJob($job.Id) |
                       Sort-Object EndTime -Descending | Select-Object -First 1
            $results += [PSCustomObject]@{
                Name       = $job.Name
                JobType    = "Tape Backup"
                LastResult = if ($session) { $session.Result } else { "No sessions found" }
                StartTime  = if ($session) { $session.CreationTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
                EndTime    = if ($session) { $session.EndTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
                Description= $job.Description
            }
        } catch {
            Write-Host "Failed to retrieve tape job info for $($job.Name): $_" -ForegroundColor Red
        }
    }

    if (-not $results) { Write-Host "No Backup to Tape jobs found." -ForegroundColor DarkYellow }
    return $results
}
