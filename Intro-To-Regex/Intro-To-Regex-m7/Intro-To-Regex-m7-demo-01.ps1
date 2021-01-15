#region Star_quantifier

'expression!' -match '...........'

'expression!' -match '.*'

'' -match '.*'
#endregion

#region Plus_sign_quantifier

'expression' -match '\w\w\w\w\w\w\w\w\w\w'

'expression' -match '\w+'

'' -match '\w+'

#endregion

#region Optional_matches

'expression','expressions','expressionsss' -match 'expressions?$' 

'expression','expressions','expressionsss' -match 'expressions*'

#endregion

#region Maximum_number_of_matches

(Get-ADUser -Filter * | Where-Object Name -Match '\w+account').Name

(Get-ADUser -Filter * | Where-Object Name -Match '\w{3}_\w+').Name

#endregion

#region Minimum_&_maximum_number_of_matches

$PhoneNumber = (Get-ADUser jgreen -Properties OfficePhone).OfficePhone

$PhoneNumber -match '\d+-\d+-\d+'

$Extension = (Get-ADUser -Identity bbailey -Properties OfficePhone).OfficePhone
$LongDistance = (Get-ADUser -Identity gbailey -Properties OfficePhone).OfficePhone

$Extension,$LongDistance -match '\d?-?\d{3}-\d{3}-\d{4}|\d{3,5}'

#endregion