# Assign-Static-IP
Assigning static IP and changing the network of Windows 2012/2016 VMs running in VMWare through PowerShell Script


Scenario -

Assume there are multiple VMs running with Windows 2016/2012 OS and receive their IP addresses via DHCP server and the VMs network  adopters are configured to be in the network "Network-DHCP". So now, suddenly a request has come to change the IP address of all VMs in network "Network-DHCP" to static IP and change their network adopters to be in network "Network-Manual".  If there are large number of VMs, then it is going to be big overhead for the managing team. By using the below, script, its possible to automate the assignment of static IP address to all VMs and to change their network name to "Network-Manual" 

Requirements -

Make sure VMware Tools are installed in all VMs

Create a csv file as given below, to include all necessary details (Static  IP Address and other details)
