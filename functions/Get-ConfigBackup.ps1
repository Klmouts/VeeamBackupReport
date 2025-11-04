function Get-ConfigBackup {
    [CmdletBinding()]
    param ()

    Write-Host "Retrieving configuration backup..." -ForegroundColor Cyan
    try {
        $jobType = [Veeam.Backup.Model.EDbJobType]::ConfBackup
        $config  = [Veeam.Backup.Core.CBaseSession]::FindLastByJobType($jobType)
        $server  = $env:COMPUTERNAME

        $result = [PSCustomObject]@{
            Name        = "Configuration Backup on $server"
            JobType     = "Configuration Backup"
            LastResult  = if ($config) { $config.Result } else { "No sessions found" }
            StartTime   = if ($config) { $config.StartTime } else { "" }
            EndTime     = if ($config) { $config.EndTime } else { "" }
            Description = "Configuration Backup on $server"
        }
        return @($result)
    } catch {
        Write-Host "Failed to retrieve configuration backup: $_" -ForegroundColor Red
    }
}
