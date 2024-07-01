#Enable PowerShell remoting
Enable-PSRemoting -Force

#Set WinRM service startup type to automatic
Set-Service WinRM -StartupType 'Automatic'

#Configure WinRM Service
Set-Item -Path 'WSMan:\localhost\Service\Auth\Certificate' -Value $true
Set-Item -Path 'WSMan:\localhost\Service\AllowUnencrypted' -Value $true
Set-Item -Path 'WSMan:\localhost\Service\Auth\Basic' -Value $true
Set-Item -Path 'WSMan:\localhost\Service\Auth\CredSSP' -Value $true

#Create a self-signed certificate and set up an HTTPS listener
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation "cert:\LocalMachine\My"
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`";CertificateThumbprint=`"$($cert.Thumbprint)`"}"

#Create a firewall rule to allow WinRM HTTPS inbound
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow

#Configure TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "<IP1>,<IP2>" -Force
#Set-Item WSMan:\localhost\Client\TrustedHosts -Value "<IP1>" -Force

#Check Trusted Hosts
Get-Item WSMan:\localhost\Client\TrustedHosts

#Set LocalAccountTokenFilterPolicy
New-ItemProperty -Name LocalAccountTokenFilterPolicy -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -PropertyType DWord -Value 1 -Force

#Set Execution Policy to Unrestricted
Set-ExecutionPolicy RemoteSigned -Force

#Restart the WinRM service
Restart-Service WinRM

#List the WinRM listeners
winrm enumerate winrm/config/Listener