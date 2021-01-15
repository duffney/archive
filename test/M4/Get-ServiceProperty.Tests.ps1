. $PSScriptRoot\Get-ServiceProperty.ps1

Describe 'Get-ServieProperty Tests' {

    Context 'Example 1' {

        $result = Get-ServiceProperty -Name RemoteRegistry

        It 'Count Should Be 6' {
           ($result.PSobject.Properties.Name).Count  | Should -Be 6
        }
    }

    Context 'Example 2' {

        It 'Count Should Be Greater Than 6' {
            ((Get-ServiceProperty -Name RemoteRegistry -Property *).PSobject.Properties.Name).Count | Should -BeGreaterThan 6
        }
    }
    Context 'Example 3' {

        $result = Get-ServiceProperty -Name RemoteRegistry -Property StartName,DelayedAutoStart,PathName

        It 'StartName Property Should Be NT AUTHORITY\LocalService' {
            $result.StartName | Should -Be 'NT AUTHORITY\LocalService'
        }
        It 'DelayedAutoStart Property Should Not BeNullOrEmpty' {
            $result.DelayedAutoStart | Should -Not -BeNullOrEmpty
        }
        It 'PathName Property Should Not BeNullOrEmpty' {
            $result.PathName | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Example 4' {

        It 'Should Not BeNullOrEmpty' {
            Get-Service RemoteRegistry | Get-ServiceProperty | Should -Not -BeNullOrEmpty
        }
    }
}
