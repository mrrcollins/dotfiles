# run with:
# powershell -ExecutionPolicy Bypass -File .\FILENAME.ps1

$defaults = @(
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

$args = @("mount") + $defaults + @("cp:", "Documents/cp")

# Start-Process -FilePath "rclone" -ArgumentList $args
Start-Process `
    -FilePath "rclone" `
    -ArgumentList $args `
    -WindowStyle Hidden

$args = @("mount") + $defaults + @("ts:", "Documents/ts")

# Start-Process -FilePath "rclone" -ArgumentList $args
Start-Process `
    -FilePath "rclone" `
    -ArgumentList $args `
    -WindowStyle Hidden
