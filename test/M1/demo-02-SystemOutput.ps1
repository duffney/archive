function Get-ItemInfo ($Path) {
    
    $itemProperties = Get-ChildItem -Path $Path | Select-Object Name,FullName,CreationTime,LastWriteTime
    
    $owner = (Get-Acl -Path $Path).Owner

    $enabled = (Get-LocalUser -Name ($owner -split '\\')[1])

    #Write-Output $enabled

    $result = [PSCustomObject]@{
        Name = $itemProperties.Name
        FullName = $itemProperties.FullName
        CreationTime = $itemProperties.CreationTime
        ModifiedDate = $itemProperties.LastWriteTime
        Owner = $owner
        OwnerEnabled = $enabled
    }

    return $result
}