<#
.SYNOPSIS
    Main entry point for the Veeam Backup Reporting Tool.

.DESCRIPTION
    Loads all PowerShell function files from the ./functions directory and runs
    a complete backup and repository report using Veeam Backup & Replication modules.

.NOTES
    Author  : Klontian Moutsa
    Created : 29/08/2024
    Version : 2.0
#>

# --------------------------- #
# ENVIRONMENT SETUP
# --------------------------- #

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Initializing Veeam Backup Report..." -ForegroundColor Cyan

# Import all function files automatically
Get-ChildItem "$ScriptRoot\functions" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { 
        . $_.FullName
        Write-Host ("Imported function file: " + $_.Name) -ForegroundColor DarkGray
    }

Write-Host "`nAll function files loaded successfully." -ForegroundColor Green
Write-Host "---------------------------------------------`n"

# --------------------------- #
# MAIN EXECUTION
# --------------------------- #

try {
    # --- Load Veeam PowerShell modules --- #
    Write-Host "Loading Veeam PowerShell modules..." -ForegroundColor Cyan
    Import-Module -Name Veeam.Backup.PowerShell -ErrorAction Stop -WarningAction SilentlyContinue
    Import-Module -Name Veeam.Archiver.PowerShell -ErrorAction SilentlyContinue
    Write-Host "Modules loaded successfully.`n" -ForegroundColor Green

    # --- Run core data collection --- #
    $jobResults      = Get-BackupJobs
    $repoResults     = Get-Repositories
    $tapeResults     = $null
    $configResult    = Get-ConfigBackup
    $office365Results= $null

    # --- Optional checks --- #
    if (Get-Command Get-TapeJobs -ErrorAction SilentlyContinue) {
        $tapeResults = Get-TapeJobs
    }

    if (Get-Command Get-Office365Jobs -ErrorAction SilentlyContinue) {
        $office365Results = Get-Office365Jobs
    }

    # --------------------------- #
    # OUTPUT SECTION
    # --------------------------- #
    Write-Host "`n---------------------------------------------" -ForegroundColor Gray
    
    Write-Host "=== VEEAM BACKUP JOBS ===" -ForegroundColor Yellow
    if ($jobResults) { $jobResults | Format-Table -AutoSize }
    else { Write-Host "No backup jobs found." -ForegroundColor DarkYellow }

    Write-Host "`n=== REPOSITORIES ===" -ForegroundColor Yellow
    if ($repoResults) { $repoResults | Format-Table -AutoSize }
    else { Write-Host "No repositories found." -ForegroundColor DarkYellow }

    Write-Host "`n=== BACKUP TO TAPE JOBS ===" -ForegroundColor Yellow
    if ($tapeResults) { $tapeResults | Format-Table -AutoSize }
    else { Write-Host "No Tape backup jobs found." -ForegroundColor DarkYellow }

    Write-Host "`n=== CONFIGURATION BACKUP ===" -ForegroundColor Yellow
    if ($configResult) { $configResult | Format-Table -AutoSize }

    Write-Host "`n=== OFFICE 365 BACKUPS ===" -ForegroundColor Yellow
    if ($office365Results) { $office365Results | Format-Table -AutoSize }
    else { Write-Host "No Office 365 backups or module not installed." -ForegroundColor DarkYellow }

}
catch {
    Write-Host "Error encountered: $_" -ForegroundColor Red
}
finally {
    Write-Host "`n---------------------------------------------" -ForegroundColor Gray
    Write-Host "Veeam Backup Report generation complete!" -ForegroundColor Green
}

# ---------------------------
# EXPORT SECTION
# ---------------------------

Write-Host "`nExporting unified CSV report..." -ForegroundColor Cyan

# Create Reports folder if missing
$ReportsDir = Join-Path $ScriptRoot "Reports"
if (-not (Test-Path $ReportsDir)) {
    New-Item -ItemType Directory -Path $ReportsDir | Out-Null
    Write-Host "Created Reports directory." -ForegroundColor DarkGray
}

# Build timestamped file name
$timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
$exportPath  = Join-Path $ReportsDir "VeeamReport_$timestamp.csv"

# Combine all collected data
$combinedData = @()
$combinedData += $jobResults
$combinedData += $repoResults
$combinedData += $tapeResults
$combinedData += $configResult
if ($office365Results) { $combinedData += $office365Results }

# Export automatically if there’s data
if ($combinedData.Count -gt 0) {
    $combinedData | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
    Write-Host "CSV report saved to: $exportPath" -ForegroundColor Green
} else {
    Write-Host "No data to export — report skipped." -ForegroundColor DarkYellow
}