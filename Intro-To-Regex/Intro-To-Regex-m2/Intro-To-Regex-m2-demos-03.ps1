#region Negated_Character_Classes  

#Validate Dates

'01-04-1990' -match '[0-9][0-9][^ ][0-9][0-9][^ ][0-9][0-9][0-9][0-9]'

'01/04/1990' -match '[0-9][0-9][^ ][0-9][0-9][^ ][0-9][0-9][0-9][0-9]'

'01 04 1990' -match '[0-9][0-9][^ ][0-9][0-9][^ ][0-9][0-9][0-9][0-9]'

#Better Regular Expression for Dates

'01/04/1990' -match '[0-9][0-9][-./][0-9][0-9][-./][0-9][0-9][0-9][0-9]'

#Spliting  Usernames

('ewalker@globomantics.com' -split '@').split('.')

'ewalker@globomantics.com' -split '[^a-z]'

#endregion