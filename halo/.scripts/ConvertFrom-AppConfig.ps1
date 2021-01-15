#az appconfig kv list -n halopoc --key "halo*"

#$var = az appconfig kv list -n halopoc --key "halo*" --query '[].{Value:value,key:key}' -o json | ConvertFrom-Json
$tfvarFile = 'terraform.tfvars'
$configData = (az appconfig kv list -n haloproto --key "arch*" | ConvertFrom-Json) | Select-Object key,value

#$prefix = ($var | where key -Match 'prefix')

if ((Test-Path $tfvarFile))
{
  #Remove-Item $tfvarFile -Force
  #New-Item -Name $tfvarFile -ItemType File
  $content = Get-Content $tfvarFile

  foreach ($config in $configData)
  {
    $tfVarName = "{$(($config.key).Split(':')[-1])}"
    
    if ($tfVarName -eq '{faultDomainCount}')
    {
      $tfVarValue =  [int]$($config.value)  
      $content = $content -replace $tfVarName,$tfVarValue
    }
    else 
    {
      $tfVarName =
      $content = $content -replace $tfVarName,"`"$($config.value)`""
    }
  }

  Set-Content $tfvarFile -Value $content
}
# else
# {
#   New-Item -Name $tfvarFile -ItemType File
# }

#Add-Content -Path $tfvarFile -Value "$(($prefix.key).Split('.')[-1]) = `"$($prefix.value)`"" 