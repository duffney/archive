$configData = (Get-Content archappconfig.json | ConvertFrom-Json) | Select-Object key,value
$locals = [PSCustomObject]@{}
foreach ($config in $configData)
{
  $localkey = "$(($config.key).Split(':')[-1])"
  $locals | Add-Member -MemberType NoteProperty -Name $localkey -Value $config.value
}

$json = Get-Content main_template.json | ConvertFrom-Json

$json | Add-Member -Type NoteProperty -Name 'locals' -Value $locals

$json = $json | ConvertTo-Json -Depth 4

New-Item -Name main.tf.json -value $json