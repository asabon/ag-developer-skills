param(
    [Parameter(Mandatory=$true)]
    [int]$IssueNumber,
    
    [Parameter(Mandatory=$false)]
    [string]$DraftPath = "issue_draft.md",
    
    [Parameter(Mandatory=$false)]
    [switch]$Submit
)

# 1. Check gh CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed or not in PATH."
    Exit 1
}

if (-not $Submit) {
    # Draft creation phase (download current body)
    if (Test-Path $DraftPath) {
        Write-Warning "Draft file '$DraftPath' already exists. Please review or remove it."
        Exit 1
    }
    
    Write-Host "Fetching current body of Issue #$IssueNumber..."
    $issueBodyJson = gh issue view $IssueNumber --json body
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -ne 0) {
        Write-Error "Failed to fetch Issue #$IssueNumber. Exit code: $exitCode"
        Exit $exitCode
    }
    
    $issueBody = ($issueBodyJson | ConvertFrom-Json).body
    
    # Write to draft path with UTF-8 encoding
    $issueBody | Out-File -FilePath $DraftPath -Encoding utf8
    Write-Host "Draft file created at: $DraftPath"
    Write-Host "Please edit this file to update the Issue body."
    Write-Host "After editing, run this script with -Submit to update the issue:"
    Write-Host "  .\skills\github-issue-helper\scripts\update-issue.ps1 -IssueNumber $IssueNumber -Submit"
    Exit 0
} else {
    # Submission phase (upload edited draft)
    if (-not (Test-Path $DraftPath)) {
        Write-Error "Draft file '$DraftPath' not found. Cannot submit."
        Exit 1
    }
    
    Write-Host "Updating GitHub Issue #$IssueNumber..."
    # Execute gh issue edit
    gh issue edit $IssueNumber --body-file $DraftPath
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "Successfully updated Issue #$IssueNumber."
        Remove-Item $DraftPath -ErrorAction SilentlyContinue
        Exit 0
    } else {
        Write-Error "Failed to update issue. GitHub CLI exited with code $exitCode"
        Exit $exitCode
    }
}
