#region Positive_lookahead

'1000' -replace '(?=\d{3}$)',','

#endregion

#region Negative_lookahead_(192.168.20.0/29)

[regex]::Match('192.168.20.11','(\d+\.){3}[1-6]').value

[regex]::Match('192.168.20.11','(\d+\.){3}[1-6](?!\d)').value

#endregion

#region Positive_lookbehind

$t = @"
EventSource[0]:
Address: GDC01.globomantics.com
Enabled: true
EventSource[1]:
Address: GDC02.globomantics.com
Enabled: true
"@

[regex]::matches($t,'(?<=Address:\s+)\w+').value

#endregion

#region Negative_lookbehind

[regex]::Match('develop\improvement-1.2.0','(?<!master\\)improvement\-1\.2\.0').value

[regex]::Match('master\improvement-1.2.0','(?<!master\\)improvement\-1\.2\.0').value

#endregion

#region lookahead_and_lookbehind

$LocalAdmins = net localgroup administrators | Out-String

[regex]::Matches($localadmins,'(?s)(?<=\-\r+\n).*(?=The)').value.trim()

#endregion