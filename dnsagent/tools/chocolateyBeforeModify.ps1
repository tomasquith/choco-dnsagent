$ErrorActionPreference = 'Stop';

$packageName = 'dnsagent'
$serviceName = 'DNSAgent'

$dnsAgentSvc = Get-Service "$serviceName" -ErrorAction SilentlyContinue
if ($dnsAgentSvc) {
   
    if ($dnsAgentSvc.Status -ne 'Stopped') {
        Write-Verbose "Stopping service to allow backups."
        $dnsAgentSvc.Stop()
        Write-Verbose "Waiting for service to stop."
        $dnsAgentSvc.WaitForStatus('Stopped', '00:01:00')   
        Write-Verbose "Service successfully stopped." 
    }
    else {
        Write-Verbose "The $serviceName service is already stopped."
    }
}