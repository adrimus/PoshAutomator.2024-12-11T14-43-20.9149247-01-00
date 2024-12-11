Function Test-CmdInstall{
    param(
        $TestCommand
    )
    try{
        $Before = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        $testResult = Invoke-Expression -Command $TestCommand
    }
    catch{
        $testResult = $null
    }
    finally{
        $ErrorActionPreference = $Before
    }
    $testResult
}

# Install Chocolatey
$testchoco = Test-CmdInstall 'choco -v'
if(-not($testChoco)){
    Write-Host 'Installing Chocolatey...' 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression "& { $(Invoke-RestMethod https://chocolatey.org/install.ps1) }"
    # Reload environment variables to ensure choco is avaiable
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
else{
    Write-Host "Chocolatey Version $testchoco is already installed" 
}

# confirm choco is available
$testChoco = Test-CmdInstall 'choco -v'
if(-not($testChoco)){
    Write-Host "Unable to locate choco package. If it was just installed try restarting this script." -ForegroundColor Red
    Start-Sleep -Seconds 30
    break
}

# Install Git for Windows
$testGit = Test-CmdInstall 'git --version'
if(-not ($testGit)){
    Write-Host "Installing Git for Windows..." 
    choco install git.install --params "/GitAndUnixToolsOnPath /NoGitLfs /SChannel /NoAutoCrlf" -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $testGit = Test-CmdInstall 'git --version'
    Write-Host "Git for Windows Version $($testGit) has been installed"
}
else{
    Write-Host "Git for Windows Version $($testGit) is already installed"
}



Invoke-Expression -Command "git clone https://github.com/mdowst/PoshAutomate.git" -ErrorVariable $gitError 

$ModuleFolder = Get-Item './PoshAutomate'
$UserPowerShellModules = [Environment]::GetEnvironmentVariable("PSModulePath").Split(';')[0]
    $SimLinkProperties = @{ 
    ItemType = 'SymbolicLink' 
    Path = (Join-Path $UserPowerShellModules $ModuleFolder.BaseName) 
    Target = $ModuleFolder.FullName 
    Force = $true 
    } 
    New-Item @SimLinkProperties 
