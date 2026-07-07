param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [string]$DraftPath = "issue_draft.md",
    
    [Parameter(Mandatory=$false)]
    [switch]$Submit
)

# 1. Define template paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$resourcesDir = Join-Path $scriptDir "..\resources"
$featTemplate = Join-Path $resourcesDir "feature_template.md"
$bugTemplate = Join-Path $resourcesDir "bug_template.md"

# 2. Determine template by prefix
$templatePath = $featTemplate
if ($Title -match "^fix\b") {
    $templatePath = $bugTemplate
}

if (-not $Submit) {
    # Draft creation phase
    if (Test-Path $DraftPath) {
        Write-Warning "Draft file '$DraftPath' already exists. Please review or remove it."
        Exit 1
    }
    
    if (-not (Test-Path $templatePath)) {
        Write-Error "Template file not found at: $templatePath"
        Exit 1
    }
    
    Copy-Item $templatePath $DraftPath
    Write-Host "Draft file created at: $DraftPath"
    Write-Host "Please edit this file to complete the Issue body."
    Write-Host "After editing, run this script with -Submit to create the issue:"
    Write-Host "  .\skills\github-issue-helper\scripts\create-issue.ps1 -Title `"$Title`" -Submit"
    Exit 0
} else {
    # Submission phase
    if (-not (Test-Path $DraftPath)) {
        Write-Error "Draft file '$DraftPath' not found. Cannot submit."
        Exit 1
    }
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed or not in PATH."
        Exit 1
    }
    
    Write-Host "Creating GitHub Issue..."
    $issueUrl = gh issue create --title $Title --body-file $DraftPath
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0 -and $issueUrl) {
        Write-Host "Successfully created issue: $issueUrl"
        Remove-Item $DraftPath -ErrorAction SilentlyContinue
        
        if ($issueUrl -match "/issues/(\d+)") {
            $issueNumber = $Matches[1]
            Write-Host "Issue Number: $issueNumber"
        }
    } else {
        Write-Error "Failed to create issue. GitHub CLI exited with code $exitCode"
        Exit $exitCode
    }
}
