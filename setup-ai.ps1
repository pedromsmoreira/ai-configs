<#
.SYNOPSIS
    Sets up AI editor-agnostic configuration.

.DESCRIPTION
    Minimal setup for any AI editor (Zed, Windsurf, Copilot, etc.): adds ai-configs
    as submodule and deploys AGENTS.md. Does NOT set up Cursor-specific rules,
    skills, or agents. For full Cursor experience, use setup-cursor.ps1 instead.

.PARAMETER ProjectPath
    Path to the target project. Defaults to current directory.

.PARAMETER CreateRulesLink
    If set, creates .rules symlink to AGENTS.md for Zed. Requires Administrator
    privileges or Developer Mode.

.EXAMPLE
    .\setup-ai.ps1
    Sets up AGENTS.md in the current directory.

.EXAMPLE
    .\setup-ai.ps1 -ProjectPath "C:\Projects\my-app" -CreateRulesLink
    Sets up AGENTS.md and .rules symlink in the specified project.

.NOTES
    CreateRulesLink requires Administrator privileges or Developer Mode for symlinks.
    Set $env:AI_CONFIGS_REPO to override the submodule repository URL.
#>

param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$CreateRulesLink
)

$ErrorActionPreference = "Stop"

$SubmoduleRepo = if ($env:AI_CONFIGS_REPO) { $env:AI_CONFIGS_REPO } else { "https://github.com/your-org/ai-configs.git" }
Set-Location $ProjectPath

if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
}

$SubmodulePath = ".cursor\ai-configs"

Write-Host "Setting up AI editor-agnostic config..." -ForegroundColor Cyan
Write-Host "  Repository: $SubmoduleRepo"
Write-Host "  Target: $ProjectPath"

if (-not (Test-Path $SubmodulePath)) {
    Write-Host "  Adding git submodule..." -ForegroundColor Cyan
    $ParentDir = Split-Path $SubmodulePath -Parent
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }
    git submodule add $SubmoduleRepo $SubmodulePath
    Write-Host "  Submodule added" -ForegroundColor Green
} else {
    Write-Host "  Submodule already exists, updating..." -ForegroundColor Gray
    git submodule update --init --recursive $SubmodulePath
}

$AgentsSource = Join-Path $SubmodulePath "AGENTS.md"
if (-not (Test-Path $AgentsSource)) {
    Write-Error "AGENTS.md not found in submodule"
    exit 1
}

$AgentsDest = Join-Path $ProjectPath "AGENTS.md"
if (-not (Test-Path $AgentsDest)) {
    Copy-Item -Path $AgentsSource -Destination $AgentsDest -Force
    Write-Host "  Copied: AGENTS.md" -ForegroundColor Green
} else {
    Write-Host "  Skipped: AGENTS.md (already exists)" -ForegroundColor Gray
}

if ($CreateRulesLink -or $env:CREATE_RULES_LINK -eq "1") {
    $RulesPath = Join-Path $ProjectPath ".rules"
    if (-not (Test-Path $RulesPath)) {
        New-Item -ItemType SymbolicLink -Path $RulesPath -Target "AGENTS.md" | Out-Null
        Write-Host "  Linked: .rules -> AGENTS.md (for Zed)" -ForegroundColor Green
    } else {
        Write-Host "  Skipped: .rules (already exists)" -ForegroundColor Gray
    }
}

Write-Host "`nAI config set up successfully!" -ForegroundColor Green
Write-Host "Edit AGENTS.md to customize for your project." -ForegroundColor Yellow
Write-Host "For full Cursor experience (rules, skills, agents): run setup-cursor.ps1" -ForegroundColor Gray
