$ErrorActionPreference = 'Stop';

$packageName= 'dnsagent'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$installDir = Get-ToolsLocation + "\$packageName"
$fileLocation = Join-Path $installDir 'DNSAgent.exe'

Write-Verbose "Uninstalling DNSAgent."
Install-ChocolateyInstallPackage -PackageName $packageName -FileType 'EXE' -SilentArgs '--uninstall' -File $fileLocation

if (Test-Path $installDir) 
{ 
    Write-Verbose "Removing install directory."
    rm $installDir -Force -Recurse 
}