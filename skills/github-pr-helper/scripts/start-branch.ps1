param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName
)

# 1. Checkout main
Write-Host "Checking out main branch..."
git checkout main
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error "Failed to checkout main branch. Exit code: $exitCode"
    Exit $exitCode
}

# 2. Pull latest main
Write-Host "Pulling latest changes from origin/main..."
git pull origin main
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error "Failed to pull origin main. Exit code: $exitCode"
    Exit $exitCode
}

# 3. Create new branch
Write-Host "Creating and switching to branch '$BranchName'..."
git checkout -b $BranchName
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error "Failed to create branch '$BranchName'. Exit code: $exitCode"
    Exit $exitCode
}

Write-Host "Successfully created and switched to branch '$BranchName'."
Exit 0
