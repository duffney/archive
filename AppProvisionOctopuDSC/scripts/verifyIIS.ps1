Import-Module WebAdministration
write-output '#---------------------- C:\webApp Exists----------------------------------------------#'
Test-Path 'C:\webapp'
write-output '#---------------------- C:\logs\webapp Exists----------------------------------------------#'
Test-Path 'C:\logs\webapp'
write-output '#---------------------- AppPool Settings----------------------------------------------#'
Get-ItemProperty -Path IIS:\AppPools\webApp | select *
write-output '#---------------------- Web Application Settings----------------------------------------------#'
Get-WebApplication -Name webApp | select *
write-output '#---------------------- ACL for c:\logs\webapp----------------------------------------------#'
(Get-Acl C:\logs\webApp).Access | where IdentityReference -eq 'IIS APPPOOL\webApp'