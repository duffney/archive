---
layout: post
title: Connecting to SQL with Visual Studio Code
excerpt: "I've been working with SQL a lot and in the middle of writing some T-SQL a thought popped into my head, I wonder if I can connect to SQL with VisualStudio Code? As it turns out you can."
comments: true
tags: [PowerShell, VSCode, SQL]
modified: 2016-7-22 8:00:00
date: 2016-7-22 8:00:00
---
#### Applies to: Visual Studio Code Version 1.3.1

It took me about 6 months but I finally stopped using the PowerShell ISE and now only use Visual Studio Code and the PowerShell console. I've been working
with SQL a lot and in the middle of writing some T-SQL a thought popped into my head, "I wonder if I can connect to SQL with Visual Studio Code?" As it turns out
you can and there is a nice extension for connecting to Microsoft SQL called [vscode-mssql](https://marketplace.visualstudio.com/items?itemName=sanagama.vscode-mssql). 
There are a few more extensions available, but I chose this one based on reviews and by the documentation available at the time.

### Install the vscode-mssql Extension

To install the extension follow the steps defined below.

1. Open Visual Studio Code...
2. Hit Ctrl+Shift+X
3. Type sql in the search box
4. Click on vscode-mssql
5. Click Install
6. Click Enable

![Install-Extension](/images/posts/2016-7-22/Install-Extension.gif "Install-Extension")

### Setting up Connections

Next you'll want to setup some connections to your SQL databases. To do that you will need to modify either the User Settings or Workspace Settings in Visual Studio
code. I chose to modify the User Settings. 

1. In Visual Studio Code Click on File
2. Click Preferences
4. Click User Settings
5. Within the settings.json file define your databases settings, see below for details.

![Sql-connections](/images/posts/2016-7-22/SQL-Connections.png "SQL-Connections")

### Connect to the Database

With the connections settings defined you can now use the extension to issue T-SQL command against the database, but before they will work you have to connect to the database.

1. Hit F1
2. Type mssql
3. Hit Enter
4. Select the database you want, then hit Enter

![Connect-To-Database](/images/posts/2016-7-22/Connect-To-Database.gif "Connect-To-Database")

### Issuing T-SQL statements within Visual Studio Code

Now that you've got the extension install and the database connections defined, you can now issue some T-SQL statements. You've got a few options at this point.
You can either open up a .sql file or you can type out some sql code. Below will walk through writing some T-SQL code and then executing it. If you open a .sql
file skip to line 4.

1. Ctrl+N for a new file
2. Type your T-SQL statement [select * from Users]
3. Hit Ctrl+K then hit M and type SQL and hit enter [Changes language syntax to SQL]
4. Hit Ctrl+Shift+E [Exectues the T-SQL]

![ExectueTSQL](/images/posts/2016-7-22/Execute_TSQL.gif "Execute_TSQL")
