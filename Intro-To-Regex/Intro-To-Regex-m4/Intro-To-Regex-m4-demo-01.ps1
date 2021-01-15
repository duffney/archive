#region Shorthand_metacharacters

#Matching anything with .

$matchAnything = 'a',1,'!',' '

$matchAnything -match '.'

#Matching word characters with \w
$wordCharacterTest = 'a','b',' ',1,'$'

$wordCharacterTest -match '\w'

#Finding Active Directory Users

Get-ADUser -Filter * | Where-Object Name -Match '\w\w\w\waccount'

#Matching digits with \d

$IPAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress

$IPAddress -match '\d\d\d.\d\d\d.\d.\d\d'

$IPAddress.replace('.','$') -match '\d\d\d.\d\d\d.\d.\d\d'

#Escaping metacharacters
$IPAddress.replace('.','$') -match '\d\d\d\.\d\d\d.\d\.\d\d'

#endregion 