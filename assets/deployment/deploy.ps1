param(
    [string]$ipaddr,
    [string]$distro,
    [string]$root
)

Import-Module $PSScriptRoot\deployment_support.ps1 -Force


$APP_ROOT = "/web-ui"

# Check connection
Write-Host "Check connection with device ${ipaddr} in progress..."
$testConnectionStatus = Test-Connection -TargetName $ipaddr -IPv4 -Count 5
If ($testConnectionStatus.Status -ne "Success") {
    Write-Host "ERROR! Failed to connect to the device ${ipaddr}."
    Exit 1
}
Write-Host "Connection with the device ${ipaddr} was established!"
Write-Host
Start-Sleep -Seconds 2

# Sync date&time on OpenWrt OS
Sync-DateTime -ipaddr $ipaddr

# Shutting down UHTTPD
Write-Host "Shutting down UHTTPD web server with '$WEB_UI_APP_NAME'..."
$remoteOutput = ssh ${ACCOUNT}@${ipaddr} '/etc/init.d/uhttpd stop' *>&1
$hasError = Find-ExternalError -remoteOutput $remoteOutput
if ($hasError) {
    # exit
}
Start-Sleep -Seconds 2
Write-Host

# Initializing the app folders
Initialize-AppFolders -ipaddr $ipaddr -AppRootFolders $APP_ROOT

# Clear app forlder
Write-Host "Removing orignal files '$WEB_UI_APP_NAME'..." -ForegroundColor Green
$remoteOutput = ssh ${ACCOUNT}@${ipaddr} "rm -rf ${WORKSPACE_ROOT}${APP_ROOT}/" *>&1
$hasError = Find-ExternalError -remoteOutput $remoteOutput
if ($hasError) {
    Exit 1
}
Start-Sleep -Seconds 2
Write-Host



# Deleting JS and CSS maps files
Write-Host "Deleting JS and CSS source maps files..." -ForegroundColor Green
Get-ChildItem -Path "./${root}/distributable/${distro}/build" -Recurse -Include "*.map" | Remove-Item -Force -Recurse
Start-Sleep -Seconds 2
Write-Host

# Copying files
Write-Host "Copying updated files..." -ForegroundColor Green
$remoteOutput = scp -r ${root}/distributable/${distro}/build ${ACCOUNT}@${ipaddr}:${WORKSPACE_ROOT}${APP_ROOT} *>&1
$hasError = Find-ExternalError -remoteOutput $remoteOutput
if ($hasError) {

    # Exit 1
}
Start-Sleep -Seconds 2
Write-Host

# Updating UHTTPD configuration
Write-Host "Updating UHTTPD configuration for '$WEB_UI_APP_NAME'..." -ForegroundColor Green
$remoteOutput = scp ${root}/configs/uhttpd ${ACCOUNT}@${ipaddr}:/etc/config/uhttpd *>&1
$hasError = Find-ExternalError -remoteOutput $remoteOutput
if ($hasError) {
    Exit 1
}
Start-Sleep -Seconds 2
Write-Host

Write-Host "Starting UHTTPD web server with '$WEB_UI_APP_NAME'..." -ForegroundColor Green
$remoteOutput = ssh ${ACCOUNT}@${IPADDR} '/etc/init.d/uhttpd start' *>&1
$hasError = Find-ExternalError -remoteOutput $remoteOutput
if ($hasError) {
    Exit 1
}
Start-Sleep -Seconds 2

Write-Host
Write-Host "CONGRATULATION! Deployment on $ipaddr was suiccessfully complete!"