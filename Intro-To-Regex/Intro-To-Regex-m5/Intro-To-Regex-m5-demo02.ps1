#region End_of_line_anchors

#Matches both

'Script','Scripts' -match 'Script'

#Only matches Script

'Script','Scripts' -match 'Script$'

#Replacing whitespaces

'Has a whitespace at the end. ' -replace '\s'

'Has a whitespace at the end. ' -replace '\s$'

#Finding tools and console features

Get-WindowsFeature | where name -Match 'tools$|console$'

#Matching events

$IDs = '5565','6587','65'

foreach ($ID in $IDs) {
    
    switch -regex ($id) {
        '65$' {$MessageData = "End of line match found [$ID]"}
        '^65' {$MessageData = "Start of line match found [$ID]"}
        '^65$' {$MessageData = "Start and end of line match found [$ID]"}
    } 
    
    $splat = @{
        SourceIdentifier = 'Intro-To-Regex'
        MessageData = $MessageData
        Sender = 'windows.timer'
    }
    
    New-Event @splat | Out-Null
}

Get-Event -SourceIdentifier Intro-To-Regex

#endregion