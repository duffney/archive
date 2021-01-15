$configdata = @{
    AllNodes = @(
      @{
        NodeName = 'GDC01'
        DomainName = 'globomantics.com'
        PSDscAllowPlainTextPassword = $true;    
        Folders = 'Sales','Sales Engineers','Sales Managers'
      }
  )
}