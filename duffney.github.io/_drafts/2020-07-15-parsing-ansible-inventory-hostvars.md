---
layout: post
title:  "Parsing Ansible hostvars"
date:   2020-07-16 13:37:00
comments: true
modified: 2020-07-16
---

=== Discovering Hostvars

Previously, you learned how to output the hostvars as JSON with the `ansible-inventory` command. Scrolling through the output is one way to discovery variables but there is an easier way.


==== Parsing JSON with jq

`jq` is a lightweight and flexible command-line JSON processor. By using `jq` you can explore the JSON output of the `ansible-inventory` command and locate hostvars to create dynamic groups.

Install `jq`

    yum install jq -y

Output the `hostvars` with `jq`

    ansible-inventory -i hosts --list | jq .'_meta.hostvars' 

.hostvars output
----
{
  "<LinuxHost>": {
   ..............
  },
  "<WindowsHost": {
  ................
  }
}
----

Each host object has several variables within it. These are the variables that can be used within the dynamic inventories. 

Use `jq` to output `ansible_connection` host variable.

.Output the `ansible_connection` hostvar
    ansible-inventory -i hosts --list | jq .'_meta.hostvars."vm-linuxweb".ansible_connection'
    
.Output the `offer` hostvar
    ansible-inventory -i hosts_azure_rm.yml --list | jq .'_meta.hostvars."vm-linuxweb".image.offer'

The offer is nested inside of the `image` object. Because of that you have to specific the object's path which is `image.offer`.

==== Parsing JSON with PowerShell

Another option for parsing JSON is PowerShell. PowerShell has a cmdlet called `ConvertFrom-Json` which converts output into a JSON object that you can navigate within terminal.

Start a PowerShell prompt

    pwsh
    

Output `ansible-inventory` a variable

 $var = ansible-inventory -i hosts_azure_rm.yml --list
 

Convert the JSON

    $var = $var | ConvertFrom-JSON


Use `Get-Member` to discover the JSON objects

    $var | Get-Member
    

Use PowerShell to output the name and offer of the Azure VM `vm-winweb01`.

.Output the `name` hostvar
    $var._meta.hostvars.'vm-winweb01'.name
    
.Output the `offer` hostvar
    $var._meta.hostvars.'vm-winweb01'.image.offer


[NOTE]
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7[Installing PowerShell on Linux].

_My https://twitter.com/joshduffney/status/1277186353449570304?s=20[tweet] when I discovered I could use PowerShell to parse the Ansible inventory._