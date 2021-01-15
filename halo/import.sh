#az appconfig kv list -n haloproto
az appconfig kv import -n haloproto --label archetype -s file --path appConfig.json --format json -y --separator :