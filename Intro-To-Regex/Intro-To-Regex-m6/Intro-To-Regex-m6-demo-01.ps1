#region word_boundaries

#Start of line anchor

'cat scatty cat scatter' | Select-String -Pattern '^cat' -all | % matches | % value

#End of line anchor

'cat scatty scatter cat' | Select-String -Pattern 'cat$' -all | % matches | % value

#Word Boundary

'cat scatty cat scatter cat' | Select-String -Pattern '\bcat\b' -all | % matches | % value

#endregion

#region Searching_permissions

#Setup sales directories
New-SalesShare -Path 'C:\'
Set-Location -Path 'C:\Share'

Get-ChildItem -Recurse | select fullname

#Wildcards match to many groups

Get-ChildItem -Recurse | Get-Acl | `
select PSPath -ExpandProperty access | `
where IdentityReference -like '*sales*' | `
select IdentityReference,@{n='Path';e={($PSItem.PSPath -replace '\w+\.\w+\.\w+\\(\w+)::')}}

#Using a word boundary to filter results

Get-ChildItem -Recurse | Get-Acl | `
select PSPath -ExpandProperty access | `
where IdentityReference -match '\bsales\b' | `
select IdentityReference,@{n='Path';e={($PSItem.PSPath -replace '\w+\.\w+\.\w+\\(\w+)::')}}

#endregion

#region finding_server_names
$xml = Get-Content C:\Intro-To-Regex\Intro-To-Regex-m6\web.config.xml

$xml.GetType()

$xml -match 'customers'

$xml -match '\bcustomers\b'

#endregion