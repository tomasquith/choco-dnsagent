$ErrorActionPreference = 'Stop';

$packageName = 'dnsagent'
$serviceName = 'DNSAgent'

$packageDir = "$Env:ChocolateyInstall\lib\$packageName"
$installDir = "$packageDir\tools"
$tempDir = "$Env:TEMP\$packageName"

$executablePath = Join-Path $installDir 'DNSAgent.exe'

function Install {
    Write-Verbose 'Installing DNSAgent package - using native installer'
    Install-ChocolateyInstallPackage -PackageName $packageName -FileType 'EXE' -SilentArgs '--install' -File $executablePath

    Write-Verbose 'Checking if the service has been correctly created by the native installer'
    $svc = Get-Service $serviceName -ErrorAction SilentlyContinue
    if (!$svc) {
        Write-Verbose 'DNSAgent service was not correctly - this happens over WinRM, creating service manually (with the same details as the native installer)'
        New-Service -Name $serviceName -BinaryPathName "$executablePath" -StartupType Automatic -Description 'A powerful "hosts" replacement.'
    }
}

$dnsAgentSvc = Get-Service $serviceName -ErrorAction SilentlyContinue
if ($dnsAgentSvc) {
    Write-Verbose 'DNSAgent service exists - must be an upgrade.'
    Write-Verbose 'Backing up existing config files.'
    md -Path $tempDir -Force | Out-Null
    cp -Path "$installDir\*.cfg" -Destination $tempDir

    Write-Verbose 'Uninstalling package.'
    Install-ChocolateyInstallPackage -PackageName $packageName -FileType 'EXE' -SilentArgs '--uninstall' -File $executablePath

    Install

    Write-Verbose 'Waiting for service to start.'
    $dnsAgentSvc.WaitForStatus('Running', '00:01:00')
    Write-Verbose 'Stopping service.'
    $dnsAgentSvc.Stop()
    Write-Verbose 'Waiting for service to stop.'
    $dnsAgentSvc.WaitForStatus('Stopped', '00:01:00')

    Write-Verbose 'Replacing configuration files with the the previous versions.'
    cp -Path "$tempDir\*.cfg" -Destination $installDir -Force

    if (Test-Path $tempDir) { 
        Write-Verbose 'Removing temporary directory.'
        rm $tempDir -Force -Recurse 
    }

    Write-Verbose 'Starting service.'
    $dnsAgentSvc.Start()

    Write-Verbose 'Waiting for service to start.'
    $dnsAgentSvc.WaitForStatus('Running', '00:01:00')
}
else
{   
    Install
}