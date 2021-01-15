#comment based help (single line)

$fileContent = Get-Content C:\Users\duffney\Downloads\regexchallenge.ps1 | Out-String #<--updatepath

#capture all text move comments aboove CmdletBinding
[regex]$rx = '(?s)(?<binding>.*\[CmdletBinding\(\)\])(?:.*)(?<comments><#(?:.*)#>)' #<--update to replace
$rx.GetGroupNames()
[regex]$rx = '(?s)(?<top>.*)(?<binding>.*\[CmdletBinding\(\)\])(?:.*)(?<comments><#(?:.*)#>)(?<bottom>.*)'
$m = $rx.Match($fileContent)
$m | ForEach-Object {$_.groups["top"].value}
$m | ForEach-Object {$_.groups["binding"].value}
$m | ForEach-Object {$_.groups["comments"].value}
$m | ForEach-Object {$_.groups["bottom"].value}

$rx.Replace($fileContent,'$comments')