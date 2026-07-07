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

# 3. Delete local branch
Write-Host "Deleting local branch '$BranchName'..."
git branch -d $BranchName
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Warning "Failed to delete branch '$BranchName' safely (maybe not fully merged?)."
    Write-Warning "If you still want to delete it, run: git branch -D $BranchName"
    Exit $exitCode
}

# 4. Prune remote tracking branches
Write-Host "Pruning remote tracking branches..."
git fetch --prune
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Warning "Failed to prune remote tracking branches. Exit code: $exitCode"
}

Write-Host "Successfully cleaned up branch '$BranchName'."
Exit 0
