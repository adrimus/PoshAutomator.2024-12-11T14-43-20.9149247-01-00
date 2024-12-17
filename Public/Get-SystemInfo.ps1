Function Get-SystemInfo {
    [CmdletBinding()]
    param()
    if (Get-Variable -Name IsLinux -ValueOnly) {
        $OS = Get-Content -Path /etc/os-release |
        ConvertFrom-StringData
 
        $search = @{
            Path    = '/proc/meminfo'
            Pattern = 'MemTotal'
        }
        $Mem = Select-String @search |
        ForEach-Object { [regex]::Match($_.line, "(\d+)").value }
 
        $stat = Invoke-Expression -Command 'stat /'
        $InstallDate = $stat | Select-String -Pattern 'Birth:' |
        ForEach-Object {
            Get-Date $_.Line.Replace('Birth:', '').Trim()
        }
 
        $boot = Invoke-Expression -Command 'df /boot'
        $OSArchitecture = Invoke-Expression -Command 'uname -m'
        $CSName = Invoke-Expression -Command 'uname -n'
 
        [pscustomobject]@{
            Caption                 = $OS.PRETTY_NAME.Replace('"', "")
            InstallDate             = $InstallDate
            ServicePackMajorVersion = $OS.VERSION.Replace('"', "")
            OSArchitecture          = $OSArchitecture
            BootDevice              = $boot.Split("`n")[-1].Split()[0]
            BuildNumber             = $OS.VERSION_ID.Replace('"', "")
            CSName                  = $CSName
            Total_Memory            = [math]::Round($Mem / 1MB)
        }
    }
    else {
        Get-CimInstance -Class Win32_OperatingSystem |
        Select-Object Caption, InstallDate, ServicePackMajorVersion,
        OSArchitecture, BootDevice, BuildNumber, CSName,
        @{l   = 'Total_Memory';
            e = { [math]::Round($_.TotalVisibleMemorySize / 1MB) }
        }
    }
}