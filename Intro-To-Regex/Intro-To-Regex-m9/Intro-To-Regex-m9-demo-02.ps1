#region Modifiers

#single-line mode

'dot
matches all' -match '(?s).*'

#ignore whitespaces

'202-555-0148' -match '(?x) \d{3} - {\d3} - \d{4}  #comment'

#Do not capture unnamed groups

'abc 123' -match '(?n)(?<word>[a-z]+)\s+(\d+)'

#endregion

#region Windows_Event_Forwarding

$regex = '(?xn)
          (Address:\s)
          (?<ServerName>\w+) #1st named capture
          \.
          (?<Domain>\w+.com) #2nd named capture'

$eventSub = (cmd /c wecutil gs appevents | Out-String)

$eventSub -match $regex

#endregion

#region Create_Objects_from_Named_Captures

[regex]$regexObj = $regex

$keys = $regexObj.GetGroupNames() | Where-Object {$_ -match '(?i)[a-z]{2,}'}

$regexObj.Matches($eventSub) | % {
    $match = $_
    $keys | % -Begin {$hash=[ordered]@{}} -Process {
        $hash.add($_,$match.groups["$_"].value)
    } -End { [PSCustomObject]$hash}
}

#endregion