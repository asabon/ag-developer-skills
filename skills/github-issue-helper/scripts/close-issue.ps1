param(
    [Parameter(Mandatory=$true)]
    [int]$IssueNumber,
    
    [Parameter(Mandatory=$false)]
    [string]$WalkthroughPath = "walkthrough.md"
)

# 1. Check gh CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed or not in PATH."
    Exit 1
}

# 2. Check for uncompleted checklist items in the issue body
Write-Host "Checking checklist status for Issue #$IssueNumber..."
$issueBodyJson = gh issue view $IssueNumber --json body
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Error "Failed to fetch Issue #$IssueNumber body. Exit code: $exitCode"
    Exit $exitCode
}

$issueBody = ($issueBodyJson | ConvertFrom-Json).body
if ($issueBody -match '[-*]\s*\[\s*\]') {
    Write-Error "Cannot close Issue #$IssueNumber. There are uncompleted checklist items ('- [ ]') in the issue body."
    Write-Error "Please make sure all tasks are checked on GitHub before closing."
    Exit 1
}
Write-Host "All checklist items are completed (or no checklist found)."

# 3. Check walkthrough.md
if (-not (Test-Path $WalkthroughPath)) {
    Write-Error "Walkthrough file not found at '$WalkthroughPath'."
    Write-Error "Please ensure you have created '$WalkthroughPath' before closing the issue."
    Exit 1
}

# 4. Post comment
Write-Host "Posting walkthrough comments to Issue #$IssueNumber..."
$commentResult = gh issue comment $IssueNumber --body-file $WalkthroughPath
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Error "Failed to post comment to Issue #$IssueNumber. Exit code: $exitCode"
    Exit $exitCode
}
Write-Host "Comment posted successfully."

# 5. Close Issue
Write-Host "Closing Issue #$IssueNumber..."
$closeResult = gh issue close $IssueNumber
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Error "Failed to close Issue #$IssueNumber. Exit code: $exitCode"
    Exit $exitCode
}

Write-Host "Successfully closed Issue #$IssueNumber."
Exit 0
