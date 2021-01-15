#Discover & Download resources
Find-Module -Name *computer*
Install-Module -Name xComputerManagement
Get-DscResource -Module xComputerManagement
Get-DscResource -Name xComputer -Syntax



#Simple DSC Configuration
Configuration RenameComputer {
    param(
        [string]$NodeName,
        [string]$NewName
    )

    Import-DscResource -ModuleName xComputerManagement
        
    Node $NodeName {

        xComputer RenameComputer
        {
            Name = $NewName
        }         
    } #end node block
    
} #end configuration 

RenameComputer -NodeName 'WIN-6J22PI2U9RJ' -NewName 'PS-S01' -OutputPath c:\dsc\push

$cim = New-CimSession -ComputerName 'WIN-6J22PI2U9RJ'

Start-DscConfiguration -CimSession $cim -Path C:\dsc\push -Wait -Verbose -Force

#Copying DSC resource module to remote node
$Session = New-PSSession -ComputerName 'WIN-6J22PI2U9RJ'

$Params =@{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\xComputerManagement'
    Destination = 'C:\Program Files\WindowsPowerShell\Modules'
    ToSession = $Session
}

Copy-Item @Params -Recurse

Invoke-Command -Session $Session -ScriptBlock {Get-Module xComputerManagement -ListAvailable}