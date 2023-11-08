# Powershell script to get Hyper-V VM "master" IP address and save it to a file

# Salt Master minion config with Powershell, Credits / Sources:
# https://techgenix.com/vm-ip-address/

$IP = Get-VMNetworkAdapter -VMName master | Select -ExpandProperty IPAddresses
Set-Content -Path ./minion -Value "master: ${IP}"