# Instalador remoto de Obsidian Brain Kit
# Clona el repo en temporal, corre el bootstrap en el vault especificado, limpia el temporal.
#
# Uso en el otro equipo (una sola linea):
#   iwr https://raw.githubusercontent.com/JRVerger/obsidian-brain-kit/main/scripts/install-remote.ps1 -OutFile install.ps1; .\install.ps1
#
# O si el repo es privado y no tienes PAT listo, usa git clone:
#   git clone https://github.com/JRVerger/obsidian-brain-kit.git $env:TEMP\obsidian-kit; & "$env:TEMP\obsidian-kit\scripts\install-remote.ps1"

param(
    [string]$VaultPath = "$env:USERPROFILE\Desktop\proyectos claude",
    [string]$RepoUrl   = "https://github.com/JRVerger/obsidian-brain-kit.git"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Obsidian Brain Kit — Instalador Remoto ===" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------
# 1. Localizar el kit (si el script se ejecuta desde dentro del repo, usarlo;
#    si se ejecuta descargado suelto, clonar el repo en temporal)
# ---------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$KitDir    = Split-Path -Parent $ScriptDir
$IsInRepo  = (Test-Path (Join-Path $KitDir "seeds")) -and (Test-Path (Join-Path $KitDir ".git"))

if ($IsInRepo) {
    Write-Host "Usando kit desde: $KitDir" -ForegroundColor Green
} else {
    $tmp = Join-Path $env:TEMP "obsidian-brain-kit"
    if (Test-Path $tmp) {
        Write-Host "Actualizando kit en $tmp (git pull)..." -ForegroundColor Yellow
        Set-Location $tmp
        git pull --quiet
    } else {
        Write-Host "Clonando kit en $tmp..." -ForegroundColor Yellow
        git clone --quiet $RepoUrl $tmp
    }
    $KitDir = $tmp
    Write-Host "Kit listo en: $KitDir" -ForegroundColor Green
}

# ---------------------------------------------------------------------
# 2. Crear vault si no existe
# ---------------------------------------------------------------------
if (-not (Test-Path $VaultPath)) {
    Write-Host "Creando vault en: $VaultPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $VaultPath -Force | Out-Null
}

# ---------------------------------------------------------------------
# 3. Ejecutar bootstrap sobre el vault
# ---------------------------------------------------------------------
$bootstrapScript = Join-Path $KitDir "scripts\bootstrap.ps1"
if (-not (Test-Path $bootstrapScript)) {
    throw "No encontrado: $bootstrapScript"
}

Write-Host ""
Write-Host "Ejecutando bootstrap sobre: $VaultPath" -ForegroundColor Cyan
Write-Host ""
& $bootstrapScript -VaultPath $VaultPath

# ---------------------------------------------------------------------
# 4. Resumen final
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "=== Instalacion completa ===" -ForegroundColor Green
Write-Host ""
Write-Host "Vault configurado en: $VaultPath" -ForegroundColor Cyan
Write-Host "Kit clonado en: $KitDir (guardalo para updates futuros)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Siguientes pasos:" -ForegroundColor Yellow
Write-Host "  1. Abre Obsidian -> Open folder as vault -> selecciona $VaultPath"
Write-Host "  2. Aprueba los plugins comunitarios (dialogo trust la primera vez)"
Write-Host "  3. Edita CLAUDE.md -> rellena Owner y tabla de Active Projects"
Write-Host "  4. Smart Connections -> elige modelo (local o con API key)"
Write-Host ""
Write-Host "Para actualizar en el futuro:" -ForegroundColor Yellow
Write-Host "  cd $KitDir"
Write-Host "  git pull"
Write-Host "  .\scripts\bootstrap.ps1 -VaultPath '$VaultPath'"
