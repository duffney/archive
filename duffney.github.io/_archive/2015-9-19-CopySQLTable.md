---
layout: post
title: Copying SQL Tables with PowerShell
excerpt: "Use PowerShell to Copy SQL tables"
comments: true
tags: [PowerShell, SQL, Microsoft SQL]
modified: 2015-09-19 8:00:00
date: 2015-09-19 8:00:00
---
#### Applies to: Windows PowerShell 3.0, Windows PowerShell 4.0, Windows PowerShell 5.0, SQLCmdlets Module 1.0

When working with SQL there might be a time where you want to move all the data in a table to a new database. This process is simple with Standard and up versions of SQL because they provide a tool for you. If you are using SQL express however that tool doesn't exist. In this blog post we'll be walking through how to use a function I wrote that takes all the data in a table from a source database and then inserts that into a target database. 

### Setting Up
As mentioned in the (Applies To:) this function depends on a SQLcmdlets module, which can be found on my [PowerShell GitHub Repository](https://github.com/Duffney/PowerShell/blob/master/Modules/SQLcmdlets.psm1). This module came from the Learn PowerShell Toolmaking in a Month of Lunches. You can either download this and add it to your modules directory or for one time use paste it into the PowerShell ISE and run it, so it's loaded into memory. 

At this point I'm assuming you already have a database with tables that you need to copy. This will be refered to as your source database and tables. With that already taken care of you'll have to create a new database on the same server or a different server. In my example I have both databases on the same server and instance of SQL Express. My source database is OmahaPSUG and my target database is OmahaPSUG_BK.

![SQLDatabases](/images/posts/2015-9-19/SQLDatabases.PNG "SQLDatabases")

The last thing you need in order to run the Copy-SQLTable function is a table in the target database with the same column strucutre as the source. This simpliest way is to right click on the table you wish to copy select Script Table as > Create To > New Query Editor Window. This will pull up some SQL code you can execute to create the table in the new database, copy this code and paste it into a new query workspace on the target database. Besure to replace the database name in line 1 of the code to the new target database name. In my example I'll change OmahaPSUG to OmahaPSUG_BK, once the database name is changed execute the query.

![ScriptTableAs](/images/posts/2015-9-19/ScriptTableAs.PNG "ScriptTableAs")
![CreateTableScript](/images/posts/2015-9-19/CreateTableScript.PNG "CreateTableScript")

### Using Copy-SQLTable

Now we are ready to use the [Copy-SQLTable](https://github.com/Duffney/PowerShell/blob/master/SQL/Copy-SQLTable.ps1) function. Copy the code below and run it to load it into memory. The below gist includes an example that includes all the necessary parameters. 

{% gist 4cfdacac22576a6846d3 %}
