#Authoring Machine .mof clear text
psedit C:\dsc\configs\WIN-6J22PI2U9RJ.mof

#Authoring Machine .mof Encrypted Credentials
psedit C:\dsc\configs\WIN-FK9EMOE6CMG.mof

#PSv5 Encrypted .mof target node (Push)
psedit '\\ps-s01\C$\Windows\System32\Configuration\Current.mof'

#Pull Server .mof Encrypted Credentials
psedit "\\ps-pull01\C$\Program Files\WindowsPowerShell\DscService\Configuration\80f08b42-945f-4675-b58d-82fd16f7d997.mof"