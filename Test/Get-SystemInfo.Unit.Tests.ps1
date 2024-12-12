$ModulePath = Split-Path $PSScriptRoot
Import-Module (Join-Path $ModulePath 'PoshAutomator.psd1') -Force
#import-module C:\github\PoshAutomator\PoshAutomator.psd1 -Force
 
InModuleScope -ModuleName PoshAutomator {
    Describe 'Get-SystemInfo' {
        Context "Get-SystemInfo works" {
            It "Get-SystemInfo returns data" {
                $Info = Get-SystemInfo
                $Info.Caption | Should -Not -BeNullOrEmpty
                $Info.InstallDate | Should -Not -BeNullOrEmpty
                $Info.ServicePackMajorVersion | Should -Not -BeNullOrEmpty
                $Info.OSArchitecture | Should -Not -BeNullOrEmpty
                $Info.BootDevice | Should -Not -BeNullOrEmpty
                $Info.BuildNumber | Should -Not -BeNullOrEmpty
                $Info.CSName | Should -Not -BeNullOrEmpty
                $Info.Total_Memory | Should -Not -BeNullOrEmpty
            }
        }
 
        Context "Get-SystemInfo returns data" {
            BeforeAll {
                Mock Get-CimInstance {
                    Import-Clixml -Path ".\Get-CimInstance.Windows.xml"
                }
            }
            It "Get-SystemInfo Windows 11" {
                $Info = Get-SystemInfo
                $Info.Caption | Should -Be 'Microsoft Windows 11 Enterprise'
                $Date = Get-Date -Date  "2023-11-17 07:40:58"
                $Info.InstallDate | Should -Be $Date 
                $Info.ServicePackMajorVersion | Should -Be 0
                $Info.OSArchitecture | Should -Be '64-bit'
                $Info.BootDevice | Should -Be '\Device\HarddiskVolume1'
                $Info.BuildNumber | Should -Be 22631
                $Info.CSName | Should -Be 'SYSW11M23'
                $Info.Total_Memory | Should -Be 16
            }
        }
    }
}