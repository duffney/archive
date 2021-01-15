@{
    AllNodes = @(
      @{
        NodeName = '*'
        Lability_SwitchName = 'Regex-External'
        DomainName = 'globomantics.com'
        PSDscAllowPlainTextPassword = $true;    
      }
    
      @{
        NodeName = 'GDC01'
        Folders = 'Sales','Sales Engineers','Sales Managers'
        Lability_ProcessorCount = 2
        Lability_Media = '2016TP4_x64_Standard_EN'
        Lability_HasDynamicMemory = $false
      }
  )

  NonNodeData = @{

    Lability = @{
      # Prefix all of our VMs with 'LAB-' in Hyper-V
      EnvironmentPrefix         = 'Regex-'

      Network = @(
        @{
          Name              = 'Regex-External'
          Type              = 'External'
          NetadapterName    = 'Ethernet'
          AllowManagementOS = $true
        }
      ) # network
    
        DSCResource = @(
          @{ Name = 'xActiveDirectory'; MinimumVersion = '2.13.0.0'; }
          @{ Name = 'xPSDesiredStateConfiguration'; MinimumVersion = '3.7.0.0'; }
          @{ Name = 'xWindowsEventForwarding'; MinimumVersion = '1.0.0.0'; }
      )

    } # lability'

  } # nonnodedate
}