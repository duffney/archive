#region wildcards

#Search for all .txt files
cd C:\Intro-To-Regex\Intro-To-Regex-m1\wildcards

Get-ChildItem *.txt

#Search for text within a filename
cd C:\Intro-To-Regex\Intro-To-Regex-m1

Get-ChildItem *demos*

#Search for cmdlets
Get-Command *et-*net*

#Search for network services
Get-Service *net*

Get-Service | Where-Object Name -Like *net*

Get-Service *net* | Where-Object Status -Like *s*
#Searching Active Directory
Get-ADUser -Filter {name -like '*green*'}

Get-ADUser -Filter {Manager -like '*smith*'}

Get-ADUser -Filter {manager -eq 'cn=ssmith,cn=users,dc=globomantics,dc=com'}

Get-ADUser -Filter * -Properties Manager | Where-Object Manager -like *smith*

#endregion