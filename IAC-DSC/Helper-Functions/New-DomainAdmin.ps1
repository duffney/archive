$UserName = 'duffneyj'
$FirstName = 'Josh'
$LastName = 'Duffneyj'
$UserPrincipalName = $UserName+'@globomantics.com'
$name = "$LastName $FirstName"

$secpass = Read-Host "Passw0rd!" -AsSecureString 


$params =@{
GivenName = $FirstName
SurName = $LastName
SamAccountName = $UserName
AccountPassword = $secpass
Enabled = $true
UserPrincipalName = $UserPrincipalName
Name = $name
}

New-ADUser @params


$Groups = (Get-ADPrincipalGroupMembership -Identity administrator).Name

foreach ($item in $Groups)
{
    Add-ADGroupMember -Identity $item -Members $UserName -Verbose
}