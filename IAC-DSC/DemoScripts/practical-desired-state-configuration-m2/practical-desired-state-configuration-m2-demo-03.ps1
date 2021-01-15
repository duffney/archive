#Finding DSC Resource Syntax & Properties
Get-DscResource xDNSServerAddress
Get-DscResource xDNSServerAddress | select -ExpandProperty Properties | ft -AutoSize
Get-DscResource xDNSServerAddress -Syntax