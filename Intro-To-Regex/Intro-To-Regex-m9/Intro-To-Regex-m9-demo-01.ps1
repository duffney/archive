#region Named_Captures_Intro

'abcd 1234' -match '(?<word>\w+) (?<num>\d+)'

$share = '\\GDC01\NETLOGON'

$regex = '^\\\\(?<ServerName>[a-z0-9]+)\\(?<ShareName>\w+)'

$share -match $regex

#endregion

#region Regex_Object_Match

$string = 'abcd 1234 efg 567'

[regex]$regex = '(?<word>[a-z]+) (?<num>[0-9]+)'

$regex.Match($string)

#endregion

#region Regex_Object_Match

$string = 'abcd 1234 efg 567'

$regex.Matches($string)

$m = $regex.Matches($string)
$m | ForEach-Object {$_.groups["word"].value}
$m | ForEach-Object {$_.groups["num"].value}

$regex.GetGroupNames()

[regex]::Matches($string,'(?<word>[a-z]+) (?<num>[0-9]+)')

[regex]::Matches($string,'(?<word>[a-z]+) (?<num>[0-9]+)') | `
ForEach-Object {$_.groups['word'].value}

#endregion