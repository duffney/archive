# WebConfig.IISConfig.json
    * DSL ('Modules','DSCResourcesToExecute')
    * Octopus Variables
# CI Builds Nuget Artifact
    * Open Nuget from Octopus Library
    * Point out version and contents
# Octopus Deploy webApp Project
## webApp Process
    1. Roles for Targeting
    2. Deploy WebApp
        * Features (Json Variable, Octopus Variable)
    3. Invoke-DscAppConfig
        * param values
        * step template
    4. Fake Web Deploy
# Create and Deploy Release of webApp
* Step 1
    * variable transforms
* Step 2
    * InvokeDSC runs configuration
* Step 3
    * deploys web app
# Variables
* Scopes
* Json transform ('First 4 vars')
* Variable Substitution ('Last 2 vars')
# InvokeDSC Project
* Process
* Channel version locking
