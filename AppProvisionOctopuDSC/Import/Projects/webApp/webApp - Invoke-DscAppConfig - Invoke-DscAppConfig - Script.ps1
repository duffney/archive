try
{
	Import-Module InvokeDSC -Force
}
catch [System.IO.FileNotFoundException]
{
	throw 'InvokeDSC module not found'
}

$splat = @{
    Path = $Path
    Repository = $Repository
}

Invoke-DscConfiguration @splat