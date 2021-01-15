#Splitting on whitespaces

$text = "This text  contains
whitespaces  and  a newline."

#Results in extra whitespaces

$text.Split(' ')

#split after 1 or two whitespaces characters

$text -split '\s|\s\s'

#Alternation position matters

$text -split '\s\s|\s'

#Getting roles from win32_computersystem

Get-WmiObject win32_computersystem | select roles

$rolesArray = (Get-WmiObject win32_computersystem).roles

$roles = ($rolesArray | Out-String) -replace '\n',','

$roles = $roles.Trim(',')

$obj = [PSCustomObject]@{ComputerName=$env:COMPUTERNAME;roles=$roles}