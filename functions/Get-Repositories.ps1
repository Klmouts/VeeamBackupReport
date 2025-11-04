function Get-Repositories {
    [CmdletBinding()]
    param ()

    Write-Host "Collecting repository details..." -ForegroundColor Cyan
    $repos = @()
    $BackupRepos = Get-VBRBackupRepository | Where-Object {$_.Type -ne "SanSnapshotOnly"}
    $ScaleOuts   = Get-VBRBackupRepository -ScaleOut

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
                $FreeSpaceGb  = $BackupRepo.GetContainer().CachedFreeSpace.InGigabytes
                $PercentUsed  = if ($TotalSpaceGb -ne 0) { ((($TotalSpaceGb - $FreeSpaceGb)/$TotalSpaceGb)*100).ToString("F2") + "%" } else { "N/A" }

                $repos += [PSCustomObject]@{
                    Name        = $BackupRepo.Name
                    Type        = $BackupRepo.Type
                    TotalSpace  = "{0:N2} GB" -f $TotalSpaceGb
                    FreeSpace   = "{0:N2} GB" -f $FreeSpaceGb
                    PercentUsed = $PercentUsed
                    Description = $BackupRepo.Description
                }
            }
        } catch {
            Write-Host "Failed to retrieve repo $($BackupRepo.Name): $_" -ForegroundColor Red
        }
    }

    if (-not $repos) { Write-Host "No repositories found." -ForegroundColor DarkYellow }
    return $repos
}
