param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$Body,

    [Parameter(Mandatory=$false)]
    [string]$VerifyCommand
)

# 1. Check gh CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed or not in PATH."
    Exit 1
}

# 2. Run verification command if provided
if (-not [string]::IsNullOrEmpty($VerifyCommand)) {
    Write-Host "Running verification command: $VerifyCommand"
    Invoke-Expression $VerifyCommand
    $verifyExit = $LASTEXITCODE
    if ($null -eq $verifyExit) {
        $verifyExit = 0
    }
    
    if ($verifyExit -ne 0) {
        Write-Error "Verification failed! Cannot submit Pull Request. Please fix errors and try again."
        Exit $verifyExit
    }
    Write-Host "Verification passed."
} else {
    Write-Host "No verification command provided. Skipping verification."
}

# 3. Create Pull Request
Write-Host "Creating Pull Request..."

$exitCode = 0
try {
    # First attempt
    gh pr create --title $Title --body $Body
    $exitCode = $LASTEXITCODE
} catch {
    $exitCode = 1
}

if ($exitCode -ne 0) {
    Write-Warning "Failed to create PR. Retrying with cleared GITHUB_TOKEN/GH_TOKEN environment variables in this session..."
    $oldToken = $env:GITHUB_TOKEN
    $oldGhToken = $env:GH_TOKEN
    $env:GITHUB_TOKEN = $null
    $env:GH_TOKEN = $null
    
    try {
        gh pr create --title $Title --body $Body
        $exitCode = $LASTEXITCODE
    } catch {
        $exitCode = 1
    }
    
    # Restore environment variables
    $env:GITHUB_TOKEN = $oldToken
    $env:GH_TOKEN = $oldGhToken
}

if ($exitCode -eq 0) {
    Write-Host "Successfully created Pull Request."
    Exit 0
} else {
    Write-Error "Failed to create Pull Request. GitHub CLI exited with code $exitCode"
    Exit $exitCode
}
