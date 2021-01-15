$Session = New-PSSession -ComputerName WIN-6J22PI2U9RJ

$Params =@{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\xComputerManagement'
    Destination = 'C:\Program Files\WindowsPowerShell\Modules'
    ToSession = $Session
}

Copy-Item @Params -Recurse
