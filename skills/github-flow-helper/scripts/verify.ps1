param (
    [string]$command
)

# Helper function to execute a command and propagate its exit code
function Run-CommandAndExit {
    param (
        [string]$cmdStr
    )
    Write-Host "Running: $cmdStr"
    Invoke-Expression $cmdStr
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
        $exitCode = 0
    }
    Exit $exitCode
}

# 1. Explicit command execution
if (-not [string]::IsNullOrEmpty($command)) {
    Run-CommandAndExit $command
}

# 2. Gradle Wrapper detection (prefer gradlew.bat on Windows)
if (Test-Path "gradlew.bat" -PathType Leaf) {
    Write-Host "Detected Gradle wrapper (gradlew.bat)."
    
    # Get all available tasks
    $tasksOutput = & .\gradlew.bat tasks --all --console=plain 2>$null
    
    $targetTasks = @("lintDebug", "ktlintCheck", "assembleRelease", "testDebugUnitTest")
    $execTasks = @()
    
    foreach ($t in $targetTasks) {
        # Check if the task exists in tasks output
        if ($tasksOutput -match "^$t\b") {
            $execTasks += $t
        }
    }
    
    if ($execTasks.Count -gt 0) {
        $tasksStr = $execTasks -join " "
        Run-CommandAndExit ".\gradlew.bat $tasksStr"
    } else {
        Write-Host "None of the specific tasks (lintDebug, ktlintCheck, assembleRelease, testDebugUnitTest) were found. Falling back to test."
        Run-CommandAndExit ".\gradlew.bat test"
    }
} elseif (Test-Path "gradlew" -PathType Leaf) {
    Write-Host "Detected Gradle wrapper (gradlew)."
    
    $tasksOutput = & ./gradlew tasks --all --console=plain 2>$null
    
    $targetTasks = @("lintDebug", "ktlintCheck", "assembleRelease", "testDebugUnitTest")
    $execTasks = @()
    
    foreach ($t in $targetTasks) {
        if ($tasksOutput -match "^$t\b") {
            $execTasks += $t
        }
    }
    
    if ($execTasks.Count -gt 0) {
        $tasksStr = $execTasks -join " "
        Run-CommandAndExit "./gradlew $tasksStr"
    } else {
        Write-Host "None of the specific tasks (lintDebug, ktlintCheck, assembleRelease, testDebugUnitTest) were found. Falling back to test."
        Run-CommandAndExit "./gradlew test"
    }
}

# 3. npm detection
if (Test-Path "package.json" -PathType Leaf) {
    Write-Host "Detected package.json."
    Run-CommandAndExit "npm test"
}

# 4. Cargo detection
if (Test-Path "Cargo.toml" -PathType Leaf) {
    Write-Host "Detected Cargo.toml."
    Run-CommandAndExit "cargo test"
}

# 5. No tool detected
Write-Warning "No supported build tool (Gradle, npm, Cargo) detected. Verification skipped."
Exit 0
