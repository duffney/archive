#$appconfig = Get-Content sample.json | ConvertFrom-Json

#TODO - Replace with AppConfig data
# $localsInput = [PSCustomObject]@{
#     location = 'West US 2'
# }

$configData = (az appconfig kv list -n haloproto --key "arch*" | ConvertFrom-Json) | Select-Object key,value

$locals = [PSCustomObject]@{}

foreach ($config in $configData)
{
  $localkey = "$(($config.key).Split(':')[-1])"
  $locals | Add-Member -MemberType NoteProperty -Name $localkey -Value $config.value
}

$json = Get-Content main_template.json | ConvertFrom-Json

$json | Add-Member -Type NoteProperty -Name 'locals' -Value $locals

$json = $json | ConvertTo-Json -Depth 3

If ((Test-Path main.tf.json)){
  Remove-Item main.tf.json
}

New-Item -Name main.tf.json -value $json

# $localsInput = [PSCustomObject]@{
#   locals = [PSCustomObject]@{
#     location = 'West US 2'
#   }
# }

# $locals += (Get-Content sample.json | ConvertFrom-Json)

# $aVar = Get-Content sample.json
# $bVar = $localsInput | ConvertTo-Json

# $combinedObject = New-Object -TypeName PSObject -Property @{
#   oldEmployees = @($aVar | ConvertFrom-Json )
#   newEmployees = @($bVar | ConvertFrom-Json )
# } | ConvertTo-Json


#Sources
#https://stackoverflow.com/questions/57724976/combine-json-objects-in-powershell
#https://stackoverflow.com/questions/45724114/add-new-key-value-pair-to-json-file-in-powershell
#https://stackoverflow.com/questions/43916931/powershell-how-to-add-to-json-array/43916989
#https://powershellexplained.com/2016-10-28-powershell-everything-you-wanted-to-know-about-pscustomobject/?utm_source=blog&utm_medium=blog&utm_content=indexref