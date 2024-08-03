# Script written by Harze2k
# https://forums.plex.tv/t/script-to-automatically-check-update-both-plex-htpc-and-mitzschs-mpv-with-truehd-support/883742

function Get-PlexHTPCFileVersion {
    param (
        [string]$LatestOnlineVersion
    )
    $plexPath = Join-Path -Path $localInstallPath -ChildPath 'Plex HTPC.exe'
    if (Test-Path $plexPath) {
        try {
            $content = [System.IO.File]::ReadAllBytes($plexPath)
            $text = [System.Text.Encoding]::ASCII.GetString($content)
            $cleanText = $text -replace "`0", " "
            $versionPattern = "Plex HTPC\s+(\d+\.\d+\.\d+\.\d+)-[a-f0-9]+"
            if ($cleanText -match $versionPattern) {
                $foundVersion = $matches[1]
                $updateNeeded = $foundVersion -ne $LatestOnlineVersion
                return [PSCustomObject]@{
                    UpdateNeeded = $updateNeeded
                    LocalVersion = $foundVersion
                }
            }
            else {
                return [PSCustomObject]@{
                    UpdateNeeded = $true
                    LocalVersion = $null
                }
            }
        }
        catch {
            Write-Host "An error occurred while processing the file: $_"
            return [PSCustomObject]@{
                UpdateNeeded = $true
                LocalVersion = $null
            }
        }
    }
    else {
        Write-Host "Plex HTPC executable not found at the specified path."
        return [PSCustomObject]@{
            UpdateNeeded = $true
            LocalVersion = $null
        }
    }
}
function Check-PlexHTPCUpdate {
    $plexExePath = Join-Path $localInstallPath -ChildPath 'Plex HTPC.exe'
    if (-not (Test-Path $plexExePath)) {
        Write-Host "Plex HTPC not installed. Install manually."
        return $null
    }
    $json = Invoke-RestMethod -Uri "https://plex.tv/api/downloads/7.json"
    $download = $json.computer.Windows.releases.url
    if (-not $download) {
        Write-Host "Error fetching data from plex.tv"
        return $null
    }
    $downloadVersion = $json.computer.Windows.version -replace '-.*$'
    $localVersion = Get-PlexHTPCFileVersion -LatestOnlineVersion $downloadVersion
    if ($localVersion.UpdateNeeded -eq $false) {
        Write-Host "Plex HTPC is up-to-date."
        Write-Host "Current Plex HTPC version: $($localVersion.LocalVersion) same as latest online version: $downloadVersion"
        return $null
    }
    else {
        Write-Host "Plex HTPC is NOT up-to-date."
        Write-Host "Current Plex HTPC version: $($localVersion.LocalVersion) is NOT same as latest online version: $downloadVersion"
        return @{
            Download = $download
            Version  = $downloadVersion
        }
    }
}
function Get-MPVDLLDate {
    $mpvDllPath = Join-Path $localInstallPath "mpv-2.dll"
    if (Test-Path $mpvDllPath) {
        return (Get-Item $mpvDllPath).LastWriteTime.ToString("yyyy-MM-dd")
    }
    else {
        return $null
    }
}
function Check-MPVUpdate {
    $mpvRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/mitzsch/mpv-winbuild/releases/latest"
    $latestVersion = $mpvRelease.tag_name
    $latestDate = $latestVersion.Substring(0, 10)  # Extract date from version string
    $localDate = Get-MPVDLLDate
    if ($localDate) {
        Write-Host "Current MPV version date (from DLL): $localDate"
    }
    else {
        Write-Host "MPV DLL not found. Assuming update is needed."
        $localDate = "0000-00-00"
    }
    Write-Host "Latest online MPV version: $latestVersion"
    if ($latestDate -le $localDate) {
        Write-Host "MPV is up-to-date."
        return $null
    }
    Write-Host "New MPV version available: $latestVersion"
    $mpvDownloadUrl = ($mpvRelease.assets | Where-Object name -Like "mpv-dev-x86_64-v3-*").browser_download_url
    return @{
        Download = $mpvDownloadUrl
        Version  = $latestVersion
    }
}
function Update-PlexHTPC {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Download,
        [Parameter(Mandatory = $true)]
        [string]$Version
    )
    try {
        Write-Host "Starting Plex HTPC update process..."
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
        $plexFilename = Split-Path $Download -Leaf
        Write-Host "Downloading Plex HTPC update: $plexFilename"
        Invoke-WebRequest -Uri $Download -OutFile (Join-Path $tempPath $plexFilename)
        Write-Host "Extracting Plex HTPC update..."
        & $zipTool x (Join-Path $tempPath $plexFilename) ("-o" + (Join-Path $tempPath "app\")) -y
        $plexProcess = Get-Process "Plex HTPC" -ErrorAction SilentlyContinue
        if ($plexProcess) {
            Write-Host "Stopping Plex HTPC process..."
            $plexProcess | Stop-Process -Force
        }
        Write-Host "Copying updated Plex HTPC files..."
        Copy-Item -Path (Join-Path $tempPath "app\*") -Destination $localInstallPath -Recurse -Exclude '$PLUGINSDIR', '$TEMP', "*.nsi", "*.nsis" -Force
        if ($plexProcess) {
            Write-Host "Restarting Plex HTPC..."
            Start-Process -FilePath (Join-Path $localInstallPath "Plex HTPC.exe")
        }
        Write-Host "Plex HTPC update completed successfully! New version: $Version"
    }
    catch {
        Write-Host "An error occurred during the Plex HTPC update process: $_"
    }
    finally {
        Remove-Item $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
function Update-MPV {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Download,
        [Parameter(Mandatory = $true)]
        [string]$Version
    )
    try {
        Write-Host "Starting MPV update process..."
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
        $mpvFilename = [System.IO.Path]::GetFileName($Download)
        Write-Host "Downloading MPV update: $mpvFilename"
        Invoke-WebRequest -Uri $Download -OutFile (Join-Path $tempPath $mpvFilename)
        Write-Host "Extracting MPV update..."
        & $zipTool x (Join-Path $tempPath $mpvFilename) ("-o" + (Join-Path $tempPath "lib\")) -y
        $plexProcess = Get-Process "Plex HTPC" -ErrorAction SilentlyContinue
        if ($plexProcess) {
            Write-Host "Stopping Plex HTPC process..."
            $plexProcess | Stop-Process -Force
        }
        Write-Host "Copying updated MPV files..."
        Copy-Item -Path (Join-Path $tempPath "lib\mpv-2.dll") -Destination $localInstallPath -Force -Confirm:$false
        if ($plexProcess) {
            Write-Host "Restarting Plex HTPC..."
            Start-Process -FilePath (Join-Path $localInstallPath "Plex HTPC.exe")
        }
        Write-Host "MPV update completed successfully! New version: $Version"
        $updatedDate = Get-MPVDLLDate
        if ($updatedDate -eq $Version.Substring(0, 10)) {
            Write-Host "MPV update verified successfully."
        }
        else {
            Write-Host "MPV update verification failed. Please check manually."
            Write-Host "Expected date: $($Version.Substring(0, 10))"
            Write-Host "Actual date: $updatedDate"
        }
        Remove-Item -Path (Join-Path $tempPath $mpvFilename) -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "An error occurred during the MPV update process: $_"
    }
    finally {
        Remove-Item $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
function Ensure-NanaZipInstalled {
    $nanaZipInstalled = Get-AppxPackage | Where-Object { $_.Name -like "*NanaZip*" }
    if ($nanaZipInstalled) {
        Write-Host "NanaZip is already installed."
        return $true
    }
    $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetPath) {
        Write-Host "Winget is not installed. Please install the Windows Package Manager (winget) to proceed."
        return $false
    }
    Write-Host "Attempting to install NanaZip..."
    try {
        winget install -e --force --id M2Team.NanaZip --accept-package-agreements --accept-source-agreements
        $nanaZipInstalled = Get-AppxPackage | Where-Object { $_.Name -like "*NanaZip*" }
        if ($nanaZipInstalled) {
            Write-Host "NanaZip has been successfully installed."
            return $true
        }
        else {
            Write-Host "NanaZip installation seems to have failed. Please check for any error messages above."
            return $false
        }
    }
    catch {
        Write-Host "An error occurred while trying to install NanaZip: $_"
        return $false
    }
}
# Main script
Write-Host "Starting update check for Plex HTPC and MPV..."
# Global variables
$localInstallPath = "C:\Program Files\Plex\Plex HTPC\"
$tempPath = "$env:TEMP\plexhtpc\"
$zipTool = "nanazipc"
#Start update check
if (!(Ensure-NanaZipInstalled)) {
    Write-Host "Failed to make sure nanazip is installed and usable. The script will not work without it."
    Exit 1
}
$plexUpdateInfo = Check-PlexHTPCUpdate
if ($plexUpdateInfo) {
    Write-Host "Updating Plex HTPC..."
    Update-PlexHTPC -Download $plexUpdateInfo.Download -Version $plexUpdateInfo.Version
}
else {
    Write-Host "No Plex HTPC update required."
}
$mpvUpdateInfo = Check-MPVUpdate
if ($mpvUpdateInfo) {
    Write-Host "Updating MPV..."
    Update-MPV -Download $mpvUpdateInfo.Download -Version $mpvUpdateInfo.Version
}
else {
    Write-Host "No MPV update required."
}
Write-Host "Update process completed."