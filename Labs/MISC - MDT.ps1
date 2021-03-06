#Here AL installs a lab with one domain controller and one client. The OS can be configured quite easily as well as
#the domain name or memory. AL takes care about network settings like in the previous samples.

$labName = 'MISC' 

New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

#make the network definition
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 192.168.23.0/24

Set-LabInstallationCredential -Username Install -Password Admin123!

$postInstallActivity = @()
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain

$mdtRole = Get-LabPostInstallationActivity -CustomRole MDT -Properties @{
    DeploymentFolderLocation = 'C:\MDT'
    InstallUserID = 'MdtService'
    InstallPassword = 'Somepass1'
    OperatingSystems = 'Windows 10 Enterprise Evaluation'
    AdkDownloadPath = '$labSources\SoftwarePackages\ADK'
}

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:Gateway'= '192.168.22.1'
}

Add-LabDomainDefinition -Name "lab.fr" -AdminUser Install -AdminPassword Admin123!

## Create DC
Add-LabMachineDefinition -Name $labName"-DC1" -Memory 2GB -OperatingSystem 'Windows Server 2012 R2 Datacenter Evaluation (Server with a GUI)' -Roles RootDC -DomainName lab.fr -PostInstallationActivity $postInstallActivity #-IpAddress 192.168.23.1

## Create MDT
Add-LabMachineDefinition -Name $labName"-MDT" -Memory 2GB -OperatingSystem 'Windows Server 2016 Standard Evaluation (Desktop Experience)' -DomainName 'lab.fr' -PostInstallationActivity $mdtRole #-IpAddress 192.168.23.3

## Create Internet Access
## External switch must have Internet Access & DHCP
Add-LabVirtualNetworkDefinition -Name External -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }
$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName #-Ipv4Address 192.168.23.2
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch External -UseDhcp
$roles = Get-LabMachineRoleDefinition -Role Routing
Add-LabMachineDefinition -Name $labName"-Router" -NetworkAdapter $netAdapter -Roles $roles -Memory 2GB -OperatingSystem 'Windows Server 2012 R2 Datacenter Evaluation (Server with a GUI)' -DomainName 'lab.fr'

Install-Lab

Show-LabDeploymentSummary -Detailed

Restart-LabVM -ComputerName $labName"-MDT" -Wait
Restart-LabVM -ComputerName $labName"-Router" -Wait

## https://blogs.technet.microsoft.com/teamdhcp/2012/08/31/installing-and-configuring-dhcp-role-on-windows-server-2012/
## If the administrator has completed the post-install configuration using PowerShell, Server Manager may still raise a flag (alert) for its completion using the post-install configuration wizard. This alert can be suppressed by notifying the Server Manager that the post-install configuration has been completed. This can be done by the below command:
Invoke-LabCommand -ComputerName $labName"-MDT" -ScriptBlock {netsh dhcp add securitygroups}
Invoke-LabCommand -ComputerName $labName"-MDT" -ScriptBlock {Restart-service dhcpserver}
Invoke-LabCommand -ComputerName $labName"-MDT" -ScriptBlock {Add-DhcpServerInDC}
Invoke-LabCommand -ComputerName $labName"-MDT" -ScriptBlock {Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2}