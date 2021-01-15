task . InstallDependencies, Analyze, Test, UpdateVersion, Clean, Archive

task InstallDependencies {
    Install-Module Pester -Force
    Install-Module PSScriptAnalyzer -Force
}

task Analyze {
    $scriptAnalyzerParams = @{
        Path = "$BuildRoot\DSCClassResources\TeamCityAgent\"
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
        ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}

task Test {
    $invokePesterParams = @{
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    $numberFails = $testResults.FailedCount
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)
}

task UpdateVersion {
    try 
    {
        $moduleManifestFile = ((($BuildFile -split '\\')[-1] -split '\.')[0]+'.psd1')
        $manifestContent = Get-Content $moduleManifestFile -Raw
        [version]$version = [regex]::matches($manifestContent,"ModuleVersion\s=\s\'(?<version>(\d+\.)?(\d+\.)?(\*|\d+))") | ForEach-Object {$_.groups['version'].value}
        $newVersion = "{0}.{1}.{2}" -f $version.Major, $version.Minor, ($version.Build + 1)

        $replacements = @{
            "ModuleVersion = '.*'" = "ModuleVersion = '$newVersion'"            
        }

        $replacements.GetEnumerator() | ForEach-Object {
            $manifestContent = $manifestContent -replace $_.Key,$_.Value
        }
        $manifestContent | Set-Content -Path "$BuildRoot\$moduleManifestFile"
    }
    catch
    {
        Write-Error -Message $_.Exception.Message
        $host.SetShouldExit($LastExitCode)
    }
}

task Clean {
    $Artifacts = "$BuildRoot\Artifacts"
    
    if (Test-Path -Path $Artifacts)
    {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force
}

task Archive {
    $Artifacts = "$BuildRoot\Artifacts"
    $ModuleName = ($buildroot -split '\\')[-1]
    Compress-Archive  -LiteralPath .\TeamCityAgentDSC.psd1 -DestinationPath "$Artifacts\$ModuleName.zip"
    Compress-Archive -Path .\DSCClassResources -Update -DestinationPath "$Artifacts\$ModuleName.zip"
    Compress-Archive -Path .\Examples -Update -DestinationPath "$Artifacts\$ModuleName.zip"
}