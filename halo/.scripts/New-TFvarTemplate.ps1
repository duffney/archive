
$content = @"
client = {client}
prefix = {prefix}
environment = {environment}
addressPrefix = {addressPrefix}
configVersion = {configVersion}
faultDomainCount = {faultDomainCount}
owner = {owner}
config = {config}
location = {location}
"@

$tfvarFile = 'terraform.tfvars'

if (!(Test-Path $tfvarFile)){
  New-Item -Name $tfvarFile -ItemType File
}
else
{
  Remove-Item $tfvarFile -Force
  New-Item -Name $tfvarFile -Value $content
}
