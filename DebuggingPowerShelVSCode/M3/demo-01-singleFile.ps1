$admins = Get-LocalGroupMember administrators

foreach ($admin in $admins) { 
    Get-LocalUser -Name $admin.name
}