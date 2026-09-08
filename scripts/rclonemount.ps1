# run with:
# powershell -ExecutionPolicy Bypass -File .\FILENAME.ps1

$defaults = @(
    "--no-console"
    "--links"
    "--allow-non-empty"
    "--cache-workers=8"
    "--cache-writes"
    "--no-modtime"
    "--drive-use-trash"
    "--stats=0"
    "--checkers=16"
    "--vfs-cache-mode=full"
    "--vfs-cache-max-size=1G"
)

$mounts = @(
    [pscustomobject]@{
        Name    = 'Tailscale'
        Src     = 'ts:'
        Dst     = 'Documents/ts'
    }
    [pscustomobject]@{
        Name    = 'Dev'
        Src     = 'dev:'
        Dst     = 'Documents/dev'
    }
    [pscustomobject]@{
        Name    = 'plex'
        Src     = 'plex:'
        Dst     = 'Documents/plex'
    }    
)

#foreach ($mount in $mounts) {
#    Write-Host "Mounting $($mount.Name)"
#    $args = @("mount") + $mount.Src + $mount.Dst + $defaults
#    Start-Process `
#        -FilePath "rclone" `
#        -ArgumentList $args `
#        -WindowStyle Hidden
#    }

Write-Host "Mounting CopyParty..."
     
$windefaults = @(
    "--no-console"
    "--network-mode"
    "--vfs-cache-mode=full"
    "--vfs-cache-max-size=10G"
    "--vfs-cache-max-age=24h"
    "--dir-cache-time=24h"
    "--log-level=INFO"
    "--log-file=$env:LOCALAPPDATA\rclone\rclone.log"
    "--cache-dir=$env:LOCALAPPDATA\rclone\cache"
)

New-Item `
    -ItemType Directory `
    -Path "$env:LOCALAPPDATA\rclone" `
    -Force | Out-Null

New-Item `
    -ItemType Directory `
    -Path "$env:LOCALAPPDATA\rclone\cache" `
    -Force | Out-Null

$rcloneArgs = @(
    "mount"
    "cp:"
    "O:"
) + $windefaults

Start-Process `
    -FilePath "rclone.exe" `
    -ArgumentList $rcloneArgs `
    -WindowStyle Hidden
