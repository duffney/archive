#region Alternations

#Matching Learning and Regex

'Learning Regex is awesome!' | select-string -pattern 'Learning|Regex' -all | % Matches

#Finding all Get,Set and Add cmdlets

(Get-Command) -match '[GS]et-|Add-'

#Matching PowerShell file extensions

(Get-ChildItem) -match 'ps1|ps[md]1'

#Matching Windows Events

Clear-EventLog -LogName Security

$Users = 'mhall','alewis','jblack'

foreach ($User in $Users){
    New-ADUser -Name $User -Verbose
    Remove-ADUser -Identity $User -Confirm:$false -Verbose
}

#Longer non-regex method

Get-EventLog -InstanceId 4720,4726 -LogName Security | Where `
{$_.message -like '*mhall*' -or $_.message -like '*alewis*'}

#Simplifying with regex alternation

Get-EventLog -InstanceId 4720,4726 -LogName Security | Where Message -Match 'mhall|alewis'

#Expanding the Message

Get-EventLog -InstanceId 4720,4726 -LogName Security | Where-Object Message -Match 'mhall|alewis' `
| select -ExpandProperty Message

#endregion