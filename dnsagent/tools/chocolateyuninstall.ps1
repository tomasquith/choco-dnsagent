$ErrorActionPreference = 'Stop';

$packageName = 'dnsagent'
$serviceName = 'DNSAgent'

$packageDir = "$Env:ChocolateyInstall\lib\$packageName"
$installDir = "$packageDir\tools"

$executablePath = Join-Path $installDir 'DNSAgent.exe'

Write-Verbose "Uninstalling DNSAgent ($executablePath)"
Install-ChocolateyInstallPackage -PackageName $packageName -FileType 'EXE' -SilentArgs '--uninstall' -File $executablePath

if (Test-Path $installDir) { 
    Write-Verbose "Removing install directory."
    rm $installDir -Force -Recurse 
}