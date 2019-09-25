<#
.Synopsis
   This script downloads the secure baseline master, unzips it, applies it, and then cleans up
#>

$zipfile = "C:\Windows\Temp\win10-baseline.zip"

$url = "https://github.com/mxk/win10-secure-baseline-gpo/archive/master.zip"
Write-Output "Attempting to download from $url"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $zipfile)

if (-not (Test-Path -Path $zipfile -PathType leaf)) {
    Write-Output "The zip file appears to have failed to download."
}
else {
    Write-Output "Download successful"
}

Write-Output "Attempting zip file decompression"
Expand-Archive $zipfile -DestinationPath "C:\Windows\Temp"

Write-Output "Beginning GPO installation"
. "C:\Windows\Temp\win10-secure-baseline-gpo-master\install.cmd" /y

#Restart-Computer -Force 