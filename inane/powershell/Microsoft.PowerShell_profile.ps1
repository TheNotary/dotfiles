fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression


function gis { git status @args }

Remove-Item Alias:gcm -Force
function gcm {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message
    )
    git commit -m $Message
}

function d { git diff @args }
function ad { git add @args }
function c { git checkout @args }

function glg { git log --graph --branches --tags --remotes --oneline --decorate @args }

function gam {
    git add -A
    git commit --amend --reset-author
}

function prompt {
    # Render the prompt text in color WITHOUT creating a newline
    Write-Host "PS $($PWD)> " -NoNewline -ForegroundColor Cyan

    # IMPORTANT: return a string so PowerShell considers the prompt "drawn"
    return " "
}
