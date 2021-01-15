$server = 'http://'+(docker inspect appprovisionoctopusdsc_octopus_1 | convertfrom-json).NetworkSettings.Networks.nat.IpAddress+':81'

.\Octo.exe create-release --project=InvokeDsc --deployto=development --user=admin --pass=P@ssw0rd --server=$server --waitfordeployment

.\Octo.exe create-release --project=ansibleish --deployto=development --user=admin --pass=P@ssw0rd --server=$server --waitfordeployment

.\Octo.exe create-release --project=webApp --deployto=development --user=admin --pass=P@ssw0rd --server=$server --waitfordeployment