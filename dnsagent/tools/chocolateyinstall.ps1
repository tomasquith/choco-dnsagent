$ErrorActionPreference = 'Stop';

$packageName= 'dnsagent'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$installDir = Get-BinRoot + "\$packageName"
$tempDir = "$Env:TEMP\$packageName"

$fileLocation = Join-Path $installDir 'DNSAgent.exe'

function CreateDirectoriesAndInstall 
{
    Write-Verbose "Copying package to install directory: $installDir"
    md -Path $installDir -Force | Out-Null
    cp -Path "$toolsDir\*" -Destination $installDir -Recurse

    Write-Verbose "Installing DNSAgent package and starting service"
    Install-ChocolateyInstallPackage -PackageName $packageName -FileType 'EXE' -SilentArgs '--install' -File $fileLocation
}

$svc = Get-Service "DNSAgent" -ErrorAction SilentlyContinue
if ($svc)
{
    Write-Verbose "DNSAgent service exists - must be an upgrade."
    Write-Verbose "Backing up existing config files."
    md -Path $tempDir -Force | Out-Null
    cp -Path "$installDir\*.cfg" -Destination $tempDir

    Write-Verbose "Uninstalling package."
    Install-ChocolateyInstallPackage -PackageName $packageName -FileType 'EXE' -SilentArgs '--uninstall' -File $fileLocation
    
    if (Test-Path $installDir) {
        Write-Verbose "Removing install directory."
        rm $installDir -Force -Recurse 
    }

    CreateDirectoriesAndInstall

    Write-Verbose "Waiting for service to start."
    $svc.WaitForStatus('Running', '00:02:00')
    Write-Verbose "Stopping service."
    $svc.Stop()
    Write-Verbose "Waiting for service to stop."
    $svc.WaitForStatus('Stopped', '00:02:00')

    Write-Verbose "Replacing configuration files with the the previous versions."
    cp -Path "$tempDir\*.cfg" -Destination $installDir -Force

    if (Test-Path $tempDir) { 
        Write-Verbose "Removing temporary directory."
        rm $tempDir -Force -Recurse 
    }

    Write-Verbose "Starting service."
    $svc.Start()

    Write-Verbose "Waiting for service to start."
    $svc.WaitForStatus('Running', '00:02:00')
}
else
{
    CreateDirectoriesAndInstall
}