# Install-RcloneMount.ps1
#
# Creates/repairs:
#   Windows Service: RcloneCpMount
#   Logon Task:      RcloneCpMount-AtLogon
#
# Run this script from an elevated PowerShell session.

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

$ServiceName = "RcloneCpMount"
$DisplayName = "Rclone cp: mount"
$TaskName    = "$ServiceName-AtLogon"

$Remote      = "cp:"
$MountPoint  = "O:"

$CacheDir = Join-Path $env:LOCALAPPDATA "rclone\cache"
$LogDir   = Join-Path $env:LOCALAPPDATA "rclone"
$LogFile  = Join-Path $LogDir "rclone.log"

$RcloneOptions = @(
    "--no-console"
    "--network-mode"
    "--vfs-cache-mode=full"
    "--vfs-cache-max-size=10G"
    "--vfs-cache-max-age=24h"
    "--cache-dir=$CacheDir"
    "--dir-cache-time=24h"
    "--poll-interval=1m"
    "--log-level=INFO"
    "--log-file=$LogFile"
)

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Quote-CommandLineArgument {
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    if ($Value.Contains('"')) {
        throw "Command-line argument contains an unsupported quote: $Value"
    }

    if ($Value -match '\s') {
        return '"' + $Value + '"'
    }

    return $Value
}

function Remove-RcloneService {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue

    if ($service) {
        if ($service.Status -ne "Stopped") {
            Write-Host "Stopping service $Name..."
            Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        }

        Write-Host "Removing service $Name..."
        & sc.exe delete $Name | Out-Null

        # Wait until Service Control Manager has actually removed it.
        for ($i = 0; $i -lt 20; $i++) {
            if (-not (Get-Service -Name $Name -ErrorAction SilentlyContinue)) {
                break
            }

            Start-Sleep -Milliseconds 250
        }

        if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
            throw "Service $Name could not be removed."
        }
    }
}

# ---------------------------------------------------------------------------
# Require elevation
# ---------------------------------------------------------------------------

if (-not (Test-Administrator)) {
    throw "Run this script from an elevated PowerShell session."
}

# ---------------------------------------------------------------------------
# Find rclone
# ---------------------------------------------------------------------------

$rcloneCommand = Get-Command "rclone.exe" -ErrorAction SilentlyContinue

if (-not $rcloneCommand) {
    throw "rclone.exe could not be found in PATH."
}

$RcloneExe = $rcloneCommand.Source

Write-Host "rclone: $RcloneExe"

# ---------------------------------------------------------------------------
# Find the config that YOUR account currently uses
# ---------------------------------------------------------------------------

$configOutput = & $RcloneExe config file 2>&1

if ($LASTEXITCODE -ne 0) {
    throw "Unable to determine the rclone configuration path."
}

$ConfigFile = ([string]($configOutput | Select-Object -Last 1)).Trim()

if (-not (Test-Path $ConfigFile)) {
    throw "rclone config does not exist: $ConfigFile"
}

Write-Host "Config: $ConfigFile"

# ---------------------------------------------------------------------------
# Verify that cp: exists
# ---------------------------------------------------------------------------

$remotes = & $RcloneExe listremotes "--config=$ConfigFile"

if ($LASTEXITCODE -ne 0) {
    throw "Unable to read rclone remotes from $ConfigFile"
}

if ($remotes -notcontains $Remote) {
    throw "The rclone remote '$Remote' does not exist in $ConfigFile"
}

# ---------------------------------------------------------------------------
# Check WinFsp
# ---------------------------------------------------------------------------

$winfsp = Get-Service -Name "WinFsp.Launcher" -ErrorAction SilentlyContinue

if (-not $winfsp) {
    Write-Warning "WinFsp.Launcher was not found. rclone mount requires WinFsp on Windows."
}

# ---------------------------------------------------------------------------
# Create cache/log directories
# ---------------------------------------------------------------------------

New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
New-Item -ItemType Directory -Path $LogDir   -Force | Out-Null

# ---------------------------------------------------------------------------
# Build the service command line
# ---------------------------------------------------------------------------

$ServiceArguments = @(
    "mount"
    $Remote
    $MountPoint
    "--config=$ConfigFile"
) + $RcloneOptions

$CommandParts = @($RcloneExe) + $ServiceArguments

$DesiredBinaryPath = (
    $CommandParts |
        ForEach-Object { Quote-CommandLineArgument $_ }
) -join " "

Write-Host ""
Write-Host "Service command:"
Write-Host $DesiredBinaryPath
Write-Host ""

# ---------------------------------------------------------------------------
# Check existing service
# ---------------------------------------------------------------------------

$ExistingService = Get-CimInstance Win32_Service `
    -Filter "Name='$ServiceName'" `
    -ErrorAction SilentlyContinue

$ReinstallService = $false

if (-not $ExistingService) {
    Write-Host "Service does not exist."
    $ReinstallService = $true
}
else {
    if ($ExistingService.PathName -ne $DesiredBinaryPath) {
        Write-Host "Service command has changed."
        $ReinstallService = $true
    }

    if ($ExistingService.StartName -ne "LocalSystem") {
        Write-Host "Service is not running as LocalSystem."
        $ReinstallService = $true
    }
}

# ---------------------------------------------------------------------------
# Install/reinstall service if necessary
# ---------------------------------------------------------------------------

if ($ReinstallService) {

    Remove-RcloneService -Name $ServiceName

    Write-Host "Installing service..."

    New-Service `
        -Name $ServiceName `
        -DisplayName $DisplayName `
        -BinaryPathName $DesiredBinaryPath `
        -StartupType Manual `
        -Description "Mounts $Remote as $MountPoint using rclone."

    Write-Host "Service installed."
}
else {
    Write-Host "Service configuration is current."

    # Make sure it remains manual since the logon task starts it.
    Set-Service `
        -Name $ServiceName `
        -StartupType Manual
}

# ---------------------------------------------------------------------------
# Configure service recovery
#
# If rclone crashes, Windows will restart it.
# ---------------------------------------------------------------------------

& sc.exe failure $ServiceName `
    "reset= 86400" `
    "actions= restart/5000/restart/5000/restart/5000" |
    Out-Null

# ---------------------------------------------------------------------------
# Create/repair login task
# ---------------------------------------------------------------------------

$LogonUser = (& whoami).Trim()
$ScExe     = Join-Path $env:SystemRoot "System32\sc.exe"

Write-Host "Login user: $LogonUser"

$ExistingTask = Get-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction SilentlyContinue

$TaskNeedsUpdate = $true

if ($ExistingTask) {

    $Action = @($ExistingTask.Actions)[0]

    if (
        $Action.Execute -ieq $ScExe -and
        $Action.Arguments -eq "start $ServiceName"
    ) {
        $TaskNeedsUpdate = $false
    }
}

if ($TaskNeedsUpdate) {

    if ($ExistingTask) {
        Write-Host "Replacing logon task..."

        Unregister-ScheduledTask `
            -TaskName $TaskName `
            -Confirm:$false
    }
    else {
        Write-Host "Creating logon task..."
    }

    $Action = New-ScheduledTaskAction `
        -Execute $ScExe `
        -Argument "start $ServiceName"

    $Trigger = New-ScheduledTaskTrigger `
        -AtLogOn `
        -User $LogonUser

    # Run the tiny starter task as SYSTEM so Start-Service does not
    # require an elevation prompt when you log in.
    $Principal = New-ScheduledTaskPrincipal `
        -UserId "SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest

    $Settings = New-ScheduledTaskSettingsSet `
        -StartWhenAvailable `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries

    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $Action `
        -Trigger $Trigger `
        -Principal $Principal `
        -Settings $Settings |
        Out-Null

    Write-Host "Logon task installed."
}
else {
    Write-Host "Logon task is current."
}

# ---------------------------------------------------------------------------
# Start it now
# ---------------------------------------------------------------------------

$Service = Get-Service -Name $ServiceName

if ($Service.Status -ne "Running") {
    Write-Host "Starting $ServiceName..."
    Start-Service -Name $ServiceName
}
else {
    Write-Host "$ServiceName is already running."
}

# ---------------------------------------------------------------------------
# Final status
# ---------------------------------------------------------------------------

Start-Sleep -Milliseconds 500

$Service = Get-Service -Name $ServiceName

Write-Host ""
Write-Host "----------------------------------------"
Write-Host "Service:    $ServiceName"
Write-Host "Status:     $($Service.Status)"
Write-Host "Remote:     $Remote"
Write-Host "Mount:      $MountPoint"
Write-Host "Config:     $ConfigFile"
Write-Host "Cache:      $CacheDir"
Write-Host "Log:        $LogFile"
Write-Host "Logon task: $TaskName"
Write-Host "----------------------------------------"