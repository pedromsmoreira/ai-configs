#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up Cursor AI configuration symlinks for a project.

.DESCRIPTION
    Creates symlinks to shared AI configs (rules, skills, agents) from a central
    ai-configs repository. The project-specific 00-project-context.mdc is copied
    for customization.

.PARAMETER ProjectPath
    Path to the target project. Defaults to current directory.

.EXAMPLE
    .\setup-cursor.ps1
    Sets up Cursor config in the current directory.

.EXAMPLE
    .\setup-cursor.ps1 -ProjectPath "C:\Projects\my-app"
    Sets up Cursor config in the specified project directory.

.NOTES
    Requires Administrator privileges or Developer Mode enabled for symlinks.
    Set $env:AI_CONFIGS_PATH to override the default source location.
#>

param(
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

# Source location: environment variable or default
$Source = if ($env:AI_CONFIGS_PATH) { $env:AI_CONFIGS_PATH } else { "C:\ai-configs" }
$SourceCursor = Join-Path $Source ".cursor"
$Dest = Join-Path $ProjectPath ".cursor"

# Validate source exists
if (-not (Test-Path $SourceCursor)) {
    Write-Error "ai-configs not found at $Source`nSet `$env:AI_CONFIGS_PATH or clone to C:\ai-configs"
    exit 1
}

Write-Host "Setting up Cursor config..." -ForegroundColor Cyan
Write-Host "  Source: $Source"
Write-Host "  Target: $ProjectPath"

# Create .cursor/rules directory
$RulesDir = Join-Path $Dest "rules"
if (-not (Test-Path $RulesDir)) {
    New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
    Write-Host "  Created: .cursor/rules/" -ForegroundColor Green
}

# Symlink shared rules (01-11*.mdc, excluding 00-*)
$SourceRules = Join-Path $SourceCursor "rules"
Get-ChildItem -Path $SourceRules -Filter "*.mdc" | Where-Object { $_.Name -notmatch "^00-" } | ForEach-Object {
    $LinkPath = Join-Path $RulesDir $_.Name
    if (Test-Path $LinkPath) {
        Remove-Item $LinkPath -Force
    }
    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $_.FullName | Out-Null
    Write-Host "  Linked: rules/$($_.Name)" -ForegroundColor Gray
}

# Symlink skills directory
$SkillsLink = Join-Path $Dest "skills"
$SkillsSource = Join-Path $SourceCursor "skills"
if (Test-Path $SkillsLink) {
    Remove-Item $SkillsLink -Force -Recurse
}
New-Item -ItemType SymbolicLink -Path $SkillsLink -Target $SkillsSource | Out-Null
Write-Host "  Linked: skills/" -ForegroundColor Gray

# Symlink agents directory
$AgentsLink = Join-Path $Dest "agents"
$AgentsSource = Join-Path $SourceCursor "agents"
if (Test-Path $AgentsLink) {
    Remove-Item $AgentsLink -Force -Recurse
}
New-Item -ItemType SymbolicLink -Path $AgentsLink -Target $AgentsSource | Out-Null
Write-Host "  Linked: agents/" -ForegroundColor Gray

# Copy project context template
$ContextSource = Join-Path $SourceRules "00-project-context.mdc"
$ContextDest = Join-Path $RulesDir "00-project-context.mdc"
Copy-Item -Path $ContextSource -Destination $ContextDest -Force
Write-Host "  Copied: rules/00-project-context.mdc" -ForegroundColor Green

Write-Host "`nCursor config linked successfully!" -ForegroundColor Green
Write-Host "Next step: Edit .cursor/rules/00-project-context.mdc for this project." -ForegroundColor Yellow
