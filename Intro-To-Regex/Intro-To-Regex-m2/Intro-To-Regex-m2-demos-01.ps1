#region Character_Class 

#Simple character class example

'gray','grey' -match 'gr[ae]y'

'gray grey' -match 'gr[ae]y'

#Using select string to find multiple matches

'gray & grey' | Select-String -Pattern 'gr[ae]y' -all | % Matches

#Character classes to find AD cmdlets

Get-Command -Module ActiveDirectory | Where-Object Name -Match 'Get-'

Get-Command -Module ActiveDirectory | Where-Object Name -Match 'Set-'

Get-Command -Module ActiveDirectory | Where-Object Name -Match '[GS]et-'

(gcm -Module ActiveDirectory | Where-Object Name -Match 'Get-').count + `
(gcm -Module ActiveDirectory | Where-Object Name -Match 'Set-').count -eq `
(gcm -Module ActiveDirectory | Where-Object Name -Match '[GS]et-').count

#Replace Invalid Characters in Username
'Eliz[abeth Walker!' -replace  '[][!/\\;|=+<>]',''

#Character class to validate IP Address

$IPAddress = (Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress

$IPAddress

$IPAddress -match '192.168.1.[0123456789][0123456789]'

#endregion