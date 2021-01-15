#region Character_Class_Ranges

#Match any IP within 192.168.20.0/29
#Vaild Host Range = 192.168.20.1 - 192.168.20.6

$IPAddresses = '192.168.20.1','192.168.20.72','192.168.20.3','10.0.0.0'

$IPAddresses -match '192.168.20.[1-6]'

#Find All Users with Last Name Bailey
Get-ADUser -Filter * | Where-Object Name -Match '[a-z]bailey' | select SurName,GivenName

#Case Sensitive Ranges

'REGEX' -cmatch '[a-z]'
'REGEX' -cmatch '[A-Z]'
'REGEX' -cmatch '[a-zA-z]'

#endregion