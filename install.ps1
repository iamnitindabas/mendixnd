#requires -Version 5.1
<#
.SYNOPSIS
Install the MendixND Agent Skill for one or more coding agents.

.DESCRIPTION
Copies (or links) the canonical skills/mendixnd directory into the discovery paths used by
OpenCode, Claude Code, OpenAI Codex, and GitHub Copilot.

The default is a user-wide copy. Use -Scope Project for a repository-local install.
Existing different content is never overwritten unless -Force is supplied; a backup is kept
outside the skills directory.

.EXAMPLE
.\install.ps1 -Scope User -Harnesses all

.EXAMPLE
.\install.ps1 -Scope Project -Harnesses opencode,claude -Force

.EXAMPLE
.\install.ps1 -Harnesses all -Link
#>
param(
    [ValidateSet('User', 'Project')]
    [string]$Scope = 'User',

    [ValidateSet('all', 'opencode', 'claude', 'codex', 'copilot')]
    [string[]]$Harnesses = @('all'),

    [switch]$Force,
    [switch]$Link,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Source = Join-Path $PSScriptRoot 'skills\mendixnd'
if (-not (Test-Path (Join-Path $Source 'SKILL.md'))) {
    throw "Canonical skill not found at '$Source'. Run this script from the repository root."
}

$HomeDir = if ($HOME) { $HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { throw 'Cannot determine home directory.' }
$ProjectRoot = (Get-Location).Path

function Get-Targets {
    param([string]$Scope, [string[]]$Harnesses, [string]$HomeDir, [string]$ProjectRoot)

    $expanded = @()
    foreach ($h in $Harnesses) {
        if ($h -eq 'all') { $expanded += @('opencode', 'claude', 'codex', 'copilot') }
        else { $expanded += $h }
    }
    $expanded = $expanded | Select-Object -Unique

    $targets = @()
    foreach ($h in $expanded) {
        switch ($h) {
            'opencode' {
                $base = if ($Scope -eq 'User') { Join-Path $HomeDir '.config\opencode\skills' } else { Join-Path $ProjectRoot '.opencode\skills' }
                $targets += [PSCustomObject]@{ Harness = 'OpenCode'; Path = (Join-Path $base 'mendixnd'); Invoke = '@mendixnd' }
            }
            'claude' {
                $base = if ($Scope -eq 'User') { Join-Path $HomeDir '.claude\skills' } else { Join-Path $ProjectRoot '.claude\skills' }
                $targets += [PSCustomObject]@{ Harness = 'Claude Code'; Path = (Join-Path $base 'mendixnd'); Invoke = '/mendixnd' }
            }
            'codex' {
                $base = if ($Scope -eq 'User') { Join-Path $HomeDir '.agents\skills' } else { Join-Path $ProjectRoot '.agents\skills' }
                $targets += [PSCustomObject]@{ Harness = 'OpenAI Codex'; Path = (Join-Path $base 'mendixnd'); Invoke = '$mendixnd or /skills' }
            }
            'copilot' {
                # ~/.agents/skills is shared by Codex and Copilot; project .agents/skills is also shared.
                $base = if ($Scope -eq 'User') { Join-Path $HomeDir '.agents\skills' } else { Join-Path $ProjectRoot '.agents\skills' }
                $targets += [PSCustomObject]@{ Harness = 'GitHub Copilot'; Path = (Join-Path $base 'mendixnd'); Invoke = '/mendixnd or /skills' }
            }
        }
    }

    # Deduplicate shared targets (Codex + Copilot both use .agents/skills).
    $seen = @{}
    $deduped = @()
    foreach ($t in $targets) {
        $key = $t.Path.ToLowerInvariant()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $deduped += $t
        }
        else {
            $existing = $deduped | Where-Object { $_.Path.ToLowerInvariant() -eq $key } | Select-Object -First 1
            if ($existing) { $existing.Harness = "$($existing.Harness) + $($t.Harness)" }
        }
    }
    return $deduped
}

function Get-TreeHash {
    param([string]$Path)
    $files = Get-ChildItem -Path $Path -Recurse -File | Sort-Object FullName
    $lines = foreach ($f in $files) {
        $rel = $f.FullName.Substring($Path.Length).TrimStart('\', '/')
        $hash = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash
        "$rel=$hash"
    }
    return ($lines -join "`n")
}

function Install-Skill {
    param(
        [PSCustomObject]$Target,
        [string]$Source,
        [bool]$Force,
        [bool]$Link,
        [bool]$DryRun
    )

    $targetPath = $Target.Path
    $parent = Split-Path -Parent $targetPath
    $exists = Test-Path $targetPath
    $action = if ($exists) { 'update' } else { 'install' }

    if ($exists) {
        $sourceHash = Get-TreeHash -Path $Source
        $targetHash = Get-TreeHash -Path $targetPath
        if ($sourceHash -eq $targetHash) {
            Write-Host "[skip] $($Target.Harness): already up to date at $targetPath"
            return
        }
        if (-not $Force) {
            Write-Warning "[exists] $($Target.Harness): different content at $targetPath. Re-run with -Force to replace it."
            return
        }
    }

    if ($DryRun) {
        Write-Host "[dry-run] $($Target.Harness): $action at $targetPath"
        return
    }

    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    if ($exists -and $Force) {
        $backupRoot = Join-Path $env:USERPROFILE '.mendixnd-backups'
        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        $backup = Join-Path $backupRoot ("mendixnd-{0}-{1}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'), ($Target.Harness -replace '[^a-zA-Z0-9]+', '-'))
        Move-Item -Path $targetPath -Destination $backup -Force
        Write-Host "[backup] $targetPath -> $backup"
    }

    $linked = $false
    if ($Link) {
        try {
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $Source -ErrorAction Stop | Out-Null
            $linked = $true
            Write-Host "[link] $($Target.Harness): $targetPath -> $Source"
        }
        catch {
            Write-Warning "[link] $($Target.Harness): symlink failed ($($_.Exception.Message)). Falling back to copy."
        }
    }

    if (-not $linked) {
        Copy-Item -Path $Source -Destination $targetPath -Recurse -Force
        Write-Host "[copy] $($Target.Harness): $targetPath"
    }

    Write-Host "       invoke: $($Target.Invoke)"
}

$targets = Get-Targets -Scope $Scope -Harnesses $Harnesses -HomeDir $HomeDir -ProjectRoot $ProjectRoot
if (-not $targets -or $targets.Count -eq 0) {
    throw 'No install targets selected.'
}

Write-Host "MendixND installer"
Write-Host "  source: $Source"
Write-Host "  scope:  $Scope"
Write-Host "  mode:   $(if ($Link) { 'link (fallback: copy)' } else { 'copy' })"
Write-Host ''

foreach ($target in $targets) {
    Install-Skill -Target $target -Source $Source -Force:$Force.IsPresent -Link:$Link.IsPresent -DryRun:$DryRun.IsPresent
}

Write-Host ''
Write-Host 'Done. Restart or reload the harness if the skill does not appear immediately.'
