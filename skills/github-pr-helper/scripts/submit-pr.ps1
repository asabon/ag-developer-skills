param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$false)]
    [string]$DraftPath = "pr_draft.md",

    [Parameter(Mandatory=$false)]
    [string]$VerifyCommand,

    [Parameter(Mandatory=$false)]
    [switch]$Submit
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$resourcesDir = Join-Path $scriptDir "..\resources"
$prTemplate = Join-Path $resourcesDir "pr_template.md"

if (-not $Submit) {
    # 1. Draft creation phase
    if (Test-Path $DraftPath) {
        Write-Warning "Draft file '$DraftPath' already exists. Please review or remove it."
        Exit 1
    }
    
    if (-not (Test-Path $prTemplate)) {
        Write-Error "PR template file not found at: $prTemplate"
        Exit 1
    }
    
    Copy-Item $prTemplate $DraftPath
    Write-Host "Draft file created at: $DraftPath"
    Write-Host "Please edit this file to complete the Pull Request body."
    Write-Host "After editing, run this script with -Submit to create the Pull Request:"
    Write-Host "  .\skills\github-pr-helper\scripts\submit-pr.ps1 -Title `"$Title`" -Submit"
    if ($VerifyCommand) {
        Write-Host "  (You can also specify -VerifyCommand `"$VerifyCommand`")"
    }
    Exit 0
} else {
    # 2. Submission phase
    if (-not (Test-Path $DraftPath)) {
        Write-Error "Draft file '$DraftPath' not found. Cannot submit."
        Exit 1
    }
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed or not in PATH."
        Exit 1
    }
    
    # Run verification command if provided
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
    
    Write-Host "Creating Pull Request..."
    
    $exitCode = 0
    try {
        gh pr create --title $Title --body-file $DraftPath
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
            gh pr create --title $Title --body-file $DraftPath
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
        Remove-Item $DraftPath -ErrorAction SilentlyContinue
        Exit 0
    } else {
        Write-Error "Failed to create Pull Request. GitHub CLI exited with code $exitCode"
        Exit $exitCode
    }
}
