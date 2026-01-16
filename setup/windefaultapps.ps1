<# My Windows Set up Script

Enter `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` if you can't run the script.
#>

# Functions

function Set-RegistryValueSafe {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Value,

        [string]$Type = "String" # Default to String if not specified
    )

    # A. Check if the folder path exists; create it if missing
    if (-not (Test-Path $Path)) {
        Write-Host "Creating new path: $Path" -ForegroundColor Cyan
        New-Item -Path $Path -Force | Out-Null
    }

    # B. Set the property (Create or Update)
    # We use -Force on Set-ItemProperty to ensure it overwrites cleanly
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    
    Write-Host "Set [$Name] to '$Value'" -ForegroundColor Green
}

function Update-PathSafe {
    # 1. Snapshot the CURRENT session path (contains Winget, etc.)
    $CurrentSessionPaths = $env:Path -split ';' | Where-Object { $_ -ne "" }

    # 2. Get the FRESH paths from the Registry (contains new installs like Git)
    $MachinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ';'
    $UserPath    = [System.Environment]::GetEnvironmentVariable("Path", "User")    -split ';'
    $RegistryPaths = $MachinePath + $UserPath | Where-Object { $_ -ne "" }

    # 3. Merge them: Start with Registry paths (prioritizing new installs)
    #    Then add any paths from the Current Session that are missing.
    $NewPathList = New-Object System.Collections.Generic.List[string]
    
    # Add all Registry paths first
    foreach ($Path in $RegistryPaths) {
        if (-not $NewPathList.Contains($Path)) {
            $NewPathList.Add($Path)
        }
    }

    # Add back any "Legacy" paths from the session that weren't in the registry
    # (This restores the WindowsApps/Winget path)
    foreach ($Path in $CurrentSessionPaths) {
        if (-not $NewPathList.Contains($Path)) {
            $NewPathList.Add($Path)
        }
    }

    # 4. Update the actual environment variable
    $env:Path = $NewPathList -join ';'
    
    Write-Host "Path refreshed. Merged $($NewPathList.Count) paths." -ForegroundColor Green
}


#### Install apps ####
<#
winget install OneCommander --source winget
winget install Obsidian.Obsidian 
winget install winfsp
winget install AutoHotkey.AutoHotkey 
winget install Ditto.Ditto
winget install Git.Git            
winget install Greenshot.Greenshot
winget install Google.Chrome
winget install Google.GoogleDrive
winget install powertoys
winget install espanso
winget install zen-browser
winget install gsudo
winget install vim.vim
winget install python3
#>

##### Add VIM to the path
[System.Environment]::SetEnvironmentVariable(
    "Path",
    [System.Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Program Files\Vim\vim91",
    "User"
)

Update-PathSafe

# Load my profile from my dotfiles directory
$ProfilePath = $PROFILE
$LineToAdd = '. "$HOME\.config\dotfiles\WINPROFILE.ps1"'

if (-not (Test-Path $ProfilePath)) { New-Item -Path $ProfilePath -ItemType File -Force | Out-Null }
$AlreadyExists = Select-String -Path $ProfilePath -Pattern $LineToAdd -SimpleMatch -Quiet

if (-not $AlreadyExists) {
    Add-Content -Path $ProfilePath -Value "`n$LineToAdd"
    Write-Host "Sourcing WINPROFILE.ps1" -ForegroundColor Green
} else {
    Write-Host "Already sourcing WINPROFILE.ps1" -ForegroundColor Gray
}

# Alias sudo to gsudo
$ProfilePath = "$HOME\.config\dotfiles\WINPROFILE.ps1"
$LineToAdd = "Set-Alias -Name sudo -Value gsudo"

if (-not (Test-Path $ProfilePath)) {
    New-Item -Path $ProfilePath -ItemType File -Force | Out-Null
}

$AlreadyExists = Select-String -Path $ProfilePath -Pattern $LineToAdd -SimpleMatch -Quiet

if (-not $AlreadyExists) {
    Add-Content -Path $ProfilePath -Value "`n$LineToAdd"
    Write-Host "Added sudo alias to profile." -ForegroundColor Green
} else {
    Write-Host "Profile already contains sudo alias. Skipping." -ForegroundColor Gray
}

#### Set registry settings ####
# Add as many blocks here as you need. 
$RegistryKeys = @(
    @{
        Path  = "HKCU:\Software\Ditto\CopyStrings"
        Name  = "WindowsTerminal.exe"
        Value = "^+v"
        Type  = "String"
    },
    @{
        Path  = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
        Name  = "FolderType"
        Value = "NotSpecified"
        Type  = "String"
    }
    # Easy to add a new one here:
    # @{ Path="HKCU:\Test"; Name="Demo"; Value=1; Type="DWord" }
)

# This loops through your array and feeds the data into the function
foreach ($Key in $RegistryKeys) {
    Set-RegistryValueSafe -Path $Key.Path -Name $Key.Name -Value $Key.Value -Type $Key.Type
}

#### git options ####
git config --global core.autocrlf false
#git config --global user.email "win11lappy@collinsoft.com"
#git config --global user.name "Win 11 Lappy"

#### Get the Espanso repo ####
# 1. Define the path using the environment variable ($env:APPDATA)
# Note: $env:APPDATA already includes "\AppData\Roaming"
$TargetFolder = "$env:APPDATA\espanso"

# 2. Check if the folder does NOT exist
if (-not (Test-Path -Path $TargetFolder)) {
    Write-Host "Cloning Espanso Repo" -ForegroundColor Yellow
    git clone git@github.com:mrrcollins/espanso.git $TargetFolder
}

#### Final Tasks ####
Write-Host "Restarting Espanso..." -ForegroundColor Green
#espanso restart
$ProfilePath = $PROFILE
$LineToAdd = "Set-Alias -Name sudo -Value gsudo"

## Setting up VIM
# Define the paths
$RepoUrl    = "git@github.com:mrrcollins/vim.git"
$VimDir     = "$env:USERPROFILE\vimfiles"
$VimRc  = "$env:USERPROFILE\_vimrc"
$sourceLine = "source ~/vimfiles/vimrc"
Write-Host "Set up VIM" -ForegroundColor Yellow

# --- Step 1: Handle the Repo (vimfiles) ---
if (Test-Path $VimDir) {
    Write-Host "Directory 'vimfiles' already exists. Pulling latest changes..." -ForegroundColor Cyan
    # Optional: Update the repo if it already exists
    Push-Location $VimDir
    git pull
    Pop-Location
} else {
    Write-Host "Cloning repository to '$VimDir'..." -ForegroundColor Cyan
    git clone $RepoUrl $VimDir
}

# --- Step 2: Handle the Config File (_vimrc) ---
$SourceLine = "source ~/vimfiles/vimrc"

if (Test-Path $VimRc) {
    # Check if the file already contains the source line to avoid duplicates
    $Content = Get-Content $VimRc -Raw
    if ($Content -match "source ~/vimfiles/vimrc") {
        Write-Host "'_vimrc' is already set up correctly." -ForegroundColor Green
    } else {
        Write-Host "Warning: '_vimrc' exists but does not source your repo." -ForegroundColor Yellow
        Write-Host "Backing up old _vimrc to _vimrc.bak and overwriting..."
        Move-Item $VimRc "$VimRc.bak" -Force
        $SourceLine | Set-Content -Path $VimRc
        Write-Host "Success: Updated '_vimrc'." -ForegroundColor Green
    }
} else {
    Write-Host "Creating new '_vimrc'..." -ForegroundColor Cyan
    $SourceLine | Set-Content -Path $VimRc
    Write-Host "Success: Created '_vimrc' pointing to repo." -ForegroundColor Green
}

# Clone the plugins I use
& "$env:USERPROFILE\vimfiles\bootstrap.ps1"

# Return to home
cd $HOME
