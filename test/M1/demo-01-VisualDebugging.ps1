function Get-ItemInfo ($Path) {
    
    $itemProperties = Get-ChildItem -Path $Path | Select-Object Name,FullName,CreationTimeLastWriteTime
    
    $owner = (Get-Acl -Path).Owner

    $results = [PSCustomObject]@{
        Name = $itemProperties.Name
        FullName = $itemProperties.FullName
        CreationTime = $itemProperties.CreationTime
        ModifiedDate = $itemProperties.LastWriteTime
        Owner = $owner
    }

    return $result
}