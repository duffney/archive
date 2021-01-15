# halo
POC repository for Halo Unified App config for IaC


## Github actions

### Update App config

1. Azure Login

```powershell
az ad sp create-for-rbac --name "halo" --role contributor \
--scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
--sdk-auth
```

2. Add output to Github repo secret
3. add workflow files to use [Azure Login](https://github.com/Azure/login) action