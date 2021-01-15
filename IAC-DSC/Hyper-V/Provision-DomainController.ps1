$Name = 'ZDC02'
$SwitchName = 'Internal'
$HardDiskSize = 32GB
$HDPath = 'E:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
$Generation = '2'
$ISO_Path = 'D:\ISOs\Windows Server 2016\WindowsServer2016TechnicalPreview4.ISO'

New-VM -Name $Name -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 1024MB

Add-VMDvdDrive -VMName $Name -Path $ISO_Path


$MyDVD = Get-VMDvdDrive $Name
$MyHD = Get-VMHardDiskDrive $Name
$MyNIC = Get-VMNetworkAdapter $Name

Set-VMFirmware $Name -BootOrder $MyDVD,$MyHD,$MyNIC
Set-VMMemory $Name -DynamicMemoryEnabled $false

$Path = 'E:\Hyper-V\Virtual Hard Disks\'+$Name+'DB.vhdx'

New-VHD -Path ('E:\Hyper-V\Virtual Hard Disks\'+$Name+'DB.vhdx') -Dynamic -SizeBytes 1GB
Add-VMHardDiskDrive -VMName $Name -Path ('E:\Hyper-V\Virtual Hard Disks\'+$Name+'DB.vhdx')
New-VHD -Path ('E:\Hyper-V\Virtual Hard Disks\'+$Name+'logs.vhdx') -Dynamic -SizeBytes 5GB
Add-VMHardDiskDrive -VMName $Name -Path ('E:\Hyper-V\Virtual Hard Disks\'+$Name+'logs.vhdx')
break
