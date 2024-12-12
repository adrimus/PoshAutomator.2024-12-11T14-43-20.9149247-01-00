$gitResults = New-TemporaryFile
Start-Process -FilePath 'git.exe' -ArgumentList 'checkout main' -WorkingDirectory $PSScriptRoot -Wait -NoNewWindow
Start-Process -FilePath 'git.exe' -ArgumentList 'fetch' -WorkingDirectory $PSScriptRoot -Wait -NoNewWindow
Start-Process -FilePath 'git.exe' -ArgumentList 'diff main origin/main --compact-summary' -WorkingDirectory $PSScriptRoot -RedirectStandardOutput $gitResults -Wait -NoNewWindow

$content = Get-Content -LiteralPath $gitResults -Raw
if($content){
    Write-Host "A module update was detected. Downloading new code base..."
    Start-Process -FilePath 'git.exe' -ArgumentList 'reset --hard origin/main' -WorkingDirectory $PSScriptRoot -RedirectStandardOutput $gitResults -Wait
    $content = Get-Content -LiteralPath $gitResults
    Write-Host $content
    Write-Host "Code was updated. It is recommended that you reload your PowerShell window.hd"
}

if(Test-Path $gitResults){
    Remove-Item -Path $gitResults -Force
}

# Get all the ps1 files in the Public folder
$Path = Join-Path $PSScriptRoot 'Public'
$Functions = Get-ChildItem -Path $Path -Filter '*.ps1'

# Loop through each ps1 file
Foreach ($import in $Functions) {
    Try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        # Execute each ps1 file to load the function into memory
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}