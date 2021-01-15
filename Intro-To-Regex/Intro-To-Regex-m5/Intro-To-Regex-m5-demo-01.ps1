#region Start_of_line_anchors

#Matches both

'Set','Reset' -match 'Set'

#Only matches Set

'Set','Reset' -match '^Set'

#Anchored character class

Get-Command -Module ActiveDirectory | Where-Object Name -Match '^[GS]et'

#Start of line anchor within an alternation

Get-Command -Module ActiveDirectory | Where-Object Name -Match 'Get|^Set'

#Start of line anchor with shorthand metacharacters

Get-ADUser -Filter * | Where-Object Name -Match '^\w\w\w\waccount'

#endregion