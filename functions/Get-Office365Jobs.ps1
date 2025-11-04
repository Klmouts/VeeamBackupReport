function Get-Office365Jobs {
    [CmdletBinding()]
    param ()

    if (Get-Module -Name Veeam.Archiver.PowerShell) {
        Write-Host "Collecting Office 365 backup job details..." -ForegroundColor Cyan
        $results = @()

        foreach ($job in Get-VBOJob -WarningAction SilentlyContinue) {
            try {
                $sessions = Get-VBOJobSession -WarningAction SilentlyContinue | Where-Object { $_.JobId -eq $job.Id }
                $last = $sessions | Sort-Object CreationTime -Descending | Select-Object -First 1

                $results += [PSCustomObject]@{
                    Name        = $job.Name
                    JobType     = "Office 365 Backup"
                    LastResult  = if ($last) { $last.Status } else { "No sessions found" }
                    StartTime   = if ($last) { $last.CreationTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
                    EndTime     = if ($last) { $last.EndTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
                    Description = "Entire Organization Backup 365"
                }
            } catch {
                Write-Host "Failed to retrieve Office 365 job: $_" -ForegroundColor Red
            }
        }

        return $results
    }
    else {
        Write-Host "Veeam Backup for Office 365 module is not installed." -ForegroundColor Yellow
    }
}
