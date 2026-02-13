#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up Cursor AI configuration using git submodules.

.DESCRIPTION
    Adds this repository as a git submodule and creates symlinks to shared AI configs
    (rules, skills, agents). The project-specific project-context.mdc is copied
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
    Set $env:AI_CONFIGS_REPO to override the submodule repository URL.
#>

param(
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

# Submodule repository URL
$SubmoduleRepo = if ($env:AI_CONFIGS_REPO) { $env:AI_CONFIGS_REPO } else { "https://github.com/your-org/ai-configs.git" }

# Change to project directory
Set-Location $ProjectPath

# Validate git repository
if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
}

$Dest = ".cursor"
$SubmodulePath = Join-Path $Dest "ai-configs"
$SourceCursor = Join-Path $SubmodulePath ".cursor"

Write-Host "Setting up Cursor config with git submodule..." -ForegroundColor Cyan
Write-Host "  Repository: $SubmoduleRepo"
Write-Host "  Target: $ProjectPath"

# Add submodule if it doesn't exist
if (-not (Test-Path $SubmodulePath)) {
    Write-Host "  Adding git submodule..." -ForegroundColor Cyan
    git submodule add $SubmoduleRepo $SubmodulePath
    Write-Host "  Submodule added" -ForegroundColor Green
} else {
    Write-Host "  Submodule already exists, updating..." -ForegroundColor Gray
    git submodule update --init --recursive $SubmodulePath
}

# Validate submodule exists
if (-not (Test-Path $SourceCursor)) {
    Write-Error "Submodule not properly initialized"
    exit 1
}

# Create .cursor/rules directory
$RulesDir = Join-Path $Dest "rules"
if (-not (Test-Path $RulesDir)) {
    New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
    Write-Host "  Created: .cursor/rules/" -ForegroundColor Green
}

# Symlink shared rules (all except project-context.mdc)
$SourceRules = Join-Path $SourceCursor "rules"
Get-ChildItem -Path $SourceRules -Filter "*.mdc" | Where-Object { $_.Name -ne "project-context.mdc" } | ForEach-Object {
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

# Copy project context template (only if it doesn't exist)
$ContextDest = Join-Path $RulesDir "project-context.mdc"
if (-not (Test-Path $ContextDest)) {
    $ContextSource = Join-Path $SourceRules "project-context.mdc"
    Copy-Item -Path $ContextSource -Destination $ContextDest -Force
    Write-Host "  Copied: rules/project-context.mdc" -ForegroundColor Green
} else {
    Write-Host "  Skipped: rules/project-context.mdc (already exists)" -ForegroundColor Gray
}

# Copy AGENTS.md for cross-editor compatibility (Zed, Windsurf, Copilot, etc.)
$AgentsSource = Join-Path $SubmodulePath "AGENTS.md"
$AgentsDest = Join-Path $ProjectPath "AGENTS.md"
if ((Test-Path $AgentsSource) -and -not (Test-Path $AgentsDest)) {
    Copy-Item -Path $AgentsSource -Destination $AgentsDest -Force
    Write-Host "  Copied: AGENTS.md (cross-editor baseline)" -ForegroundColor Green
} elseif (Test-Path $AgentsDest) {
    Write-Host "  Skipped: AGENTS.md (already exists)" -ForegroundColor Gray
}

Write-Host "`nCursor config set up successfully!" -ForegroundColor Green
Write-Host "Next step: Edit .cursor/rules/project-context.mdc for this project." -ForegroundColor Yellow
Write-Host "To update the submodule: cd .cursor\ai-configs; git pull; cd ..\.." -ForegroundColor Gray
