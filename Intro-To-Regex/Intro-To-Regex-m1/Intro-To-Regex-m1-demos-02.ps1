#region Literal_Regex_Matching

#Matching a ServerName from a UNC Path

'\\GFS-01\Share\regex.ps1' -match 'GFS-01'

$Matches

#Matching a user name within a distinguished name

'CN=jgreen,CN=Users,DC=globomantics,DC=com' -match 'jgreen'

$Matches
$Matches[0]

#Determine domain name from distinguished name

'CN=jgreen,CN=Users,DC=globomantics,DC=com' -match 'globomantics,dc=com'

$Matches[0] -replace ',dc=','.'

#endregion