---
layout: post
title: Remove Blank Lines from Foreach Results
comments: true
tags: [PowerShell, if-statement]
modified: 2014-12-11 22:00:00
date: 2014-12-11 22:00:00
---
#### Applies to: Windows PowerShell 3.0, Windows PowerShell 4.0, Windows PowerShell 5.0

While creating a script that gathers all the product codes of .MSI files in a directory, I discovered a problem. The variable that I had place them in was generating blank lines between my variables. Below is
an example of the problem

![foreachissue](/images/posts/2014-12-11/foreachissue.png "foreachissue")

After not being able to Google the correct combination of works, I quickly posted this problem to the Spiceworks community to help, shortly after I had my answer. Below lists the problem code, then followed by the solution. Place an If statement verifying that there is real data in the variable prevents it from running the foreach with newlines and character returns.

``` PowerShell
function MSI {

param(
[parameter(Mandatory=$true)]
[IO.FileInfo]$Path,
[parameter(Mandatory=$true)]
[ValidateSet("ProductCode","ProductVersion","ProductName")]
[string]$Property
)
try {
    $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase","InvokeMethod",$Null,$WindowsInstaller,@($Path.FullName,0))
    $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
    $View = $MSIDatabase.GetType().InvokeMember("OpenView","InvokeMethod",$null,$MSIDatabase,($Query))
    $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
    $Record = $View.GetType().InvokeMember("Fetch","InvokeMethod",$null,$View,$null)
    $Value = $Record.GetType().InvokeMember("StringData","GetProperty",$null,$Record,1)
    return $Value
}
catch {
    Write-Output $_.Exception.Message
}

}

$Paths = (Get-ChildItem -path $app.SourceFolderPath -Recurse *.msi).FullName
Foreach ($MSI in $Paths) {
$UninstallCodes += MSI -Path "$MSI" -Property ProductCode
}

foreach ($UninstallCode in $UninstallCodes) {

Write-Host -ForegroundColor Green "Execute-MSI Uninstall -Path $UninstallCOde"

}
```

### Solution

{% highlight powershell %}
Foreach ($MSI in $Paths) {
   If ($MSI)
   {  $UninstallCodes += MSI -Path "$MSI" -Property ProductCode
   }
}
{% endhighlight %}


[Spiceworks Community Post](https://community.spiceworks.com/topic/587947-powershell-foreach-inputting-blank-lines?page=1&source=homepage-feed#entry-3810509) Best Answer by [Martin9700](https://community.spiceworks.com/people/martin9700)