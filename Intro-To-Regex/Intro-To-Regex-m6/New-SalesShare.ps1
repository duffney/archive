function New-SalesShare ($Path) {
$root = 'Share'
$subfolders = 'Sales','Sales_Engineers','Sales_Managers'

New-Item -Path $Path -Name $root -ItemType Directory
$ACL = Get-ACL -Path $Path\$root
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule((Get-ADGroup -Identity 'Domain Users').name, 'Read','ContainerInherit,ObjectInherit', 'None', 'Allow')
$ACL.SetAccessRule($Ar)
Set-ACL -Path $Path\$root -AclObject $ACL

foreach ($subfolder in $subfolders) {

    switch -Regex ($subfolder) {
        '\bsales\b' {
            New-Item -Path $Path\$root -Name $subfolder -ItemType Directory
            'US_Sales','EU_Sales' | % {New-Item -Path $Path\$root\$subfolder -Name $_ -ItemType Directory}
            $ACL = Get-ACL -Path $Path\$root\$subfolder
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule((Get-ADGroup -Identity $subfolder).name, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
            $ACL.SetAccessRule($Ar)
            Set-ACL -Path $Path\$root\$subfolder -AclObject $ACL
        }

        'Sales[^a-z]Managers' {
            New-Item -Path $Path\$root -Name $subfolder -ItemType Directory
            $ACL = Get-ACL -Path $Path\$root\$subfolder
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule((Get-ADGroup -Identity ($subfolder -replace '[^a-z]')).name, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
            $ACL.SetAccessRule($Ar)
            Set-ACL -Path $Path\$root\$subfolder -AclObject $ACL
        }

        'Sales\wEngineers' {
            New-Item -Path $Path\$root -Name $subfolder -ItemType Directory
            $ACL = Get-ACL -Path $Path\$root\$subfolder
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule((Get-ADGroup -Identity ($subfolder -replace '_|-')).name, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
            $ACL.SetAccessRule($Ar)
            Set-ACL -Path $Path\$root\$subfolder -AclObject $ACL
        }
    }
} 
}