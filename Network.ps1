#Developer - Janarthanan Kugathasan
#Date - 9/11/2018
#Purpose - To assign static IP and network name to Windows 2012/2016 VMs running in VMware


#function for logging time
function timestamp ($message)
{
$date=Get-Date
"$date : $message" >> $log
}


$vCenter= Read-Host -Prompt "Please enter the Vcenter you want to connect `n" 

$vCenterUser= Read-Host -Prompt "Enter Vcenter user name`n"

$vCenterUserPassword= Read-Host -Prompt "Password `n" -assecurestring

$credential = New-Object System.Management.Automation.PSCredential($vCenterUser,$vCenterUserPassword)

Connect-VIServer -Server $vCenter -Credential $credential

#To avoid timeout
Set-PowerCLIConfiguration -WebOperationTimeoutSeconds -1 -confirm:$false

$UserVM = Read-Host -Prompt "Enter user name to connect to VMs (Domain\***) `n"
$PasswordVM= Read-Host -Prompt "Password for that account (Guest Password for VM) `n"

$log=Read-Host "Give the file and folder location to store the log details Eg-[D:\Log\log.txt]"
$vmlist=Read-Host "Give the location of CSV File Eg-[D:\vm.csv]"

$location = Import-CSV $vmlist

foreach ($a in $location)
{
$vm_name=$a.VM_Name
$IP=$a.IP_Address
$dg=$a.Default_Gateway
$sub=$a.Prefix
$dns1=$a.DNS_1
$dns2=$a.DNS_2
$net=$a.Network

"`n">>$log
timestamp "Working on $vm_name"

$script_final= @'
$name=Get-NetAdapter | select Name -ExpandProperty Name;
New-NetIPAddress -InterfaceAlias $name -IPAddress "dIP" -Prefixlength "dsub" -DefaultGateway "ddg";
Set-DnsClientServerAddress -InterfaceAlias $name -ServerAddresses "ddns1","ddns2"
'@

#Replacing with actual variables	
$script_final=$script_final.Replace('dIP',$IP).Replace('dsub',$sub).Replace('ddg',$dg).Replace('ddns1',$dns1).Replace('ddns2',$dns2)

		    #Setting the execution policy in the VM
			Invoke-VMScript -VM $vm_name -ScriptText 'set-executionpolicy bypass' -GuestUser $UserVM  -GuestPassword $PasswordVM -ScriptType PowerShell
			#Executing the script located in shared folder
			Invoke-VMScript -VM $vm_name -ScriptText  $script_final -GuestUser $UserVM  -GuestPassword $PasswordVM -ScriptType PowerShell
			
			
			#To check whether reconfiguration is successful
			if($? -eq "True")
			{
				timestamp "Static IP address is assigned successfully"
				Get-VM $vm_name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $net -Confirm:$false
				
				if($? -eq "True")
				{
				timestamp "$vm_name is successfull"
				}
				
				else
				{
				timestamp "$vm_name is failed"
				}
				
			}
			
			else
			{
				timestamp "Static IP address assignment in $vm_name is failed"
			}

}

#Disconnecting from Vcenter	
Disconnect-VIServer -Server $vCenter -confirm:$false
timestamp "Disconnected from datacenter. Bye !!! Bye !!!"