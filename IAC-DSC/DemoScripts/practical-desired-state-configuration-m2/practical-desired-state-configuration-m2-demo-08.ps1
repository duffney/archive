$cim = New-CimSession -ComputerName "PS-S02"

Test-DscConfiguration -CimSession $cim

Get-DscConfiguration -CimSession $cim

Get-DscConfigurationStatus -CimSession $cim