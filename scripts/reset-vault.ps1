# Reset del Vault - limpieza segura de estado Obsidian sin tocar proyectos
#
# Borra: .obsidian/, wiki/, _templates/, CLAUDE.md, .raw/, .archive/, .attachments/, .trash/
# Preserva: todo lo demas (tus carpetas de proyectos con codigo, git, assets, etc.)
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\scripts\reset-vault.ps1 -VaultPath "C:\ruta\al\vault"
#
# Opciones:
#   -Yes              Auto-confirma sin preguntar (peligroso, solo si sabes lo que haces)
#   -NoBackup         No crea backup zip (por defecto si lo crea)
#   -IncludeDocs      Tambien borra ./docs/
#   -IncludeScripts   Tambien borra ./scripts/ (la copia local, no el kit en TEMP)
#   -AlsoRemove       Lista adicional de carpetas/archivos a borrar (ej: "ClaudeBrain","otro.md")

param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,

    [switch]$Yes = $false,
    [switch]$NoBackup = $false,
    [switch]$IncludeDocs = $false,
    [switch]$IncludeScripts = $false,
    [string[]]$AlsoRemove = @()
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $VaultPath)) {
    Write-Host "ERROR: No existe la ruta $VaultPath" -ForegroundColor Red
    exit 1
}

Set-Location $VaultPath

# Items que SIEMPRE son del vault Obsidian / kit
$coreItems = @(
    ".obsidian",
    "_templates",
    "wiki",
    "CLAUDE.md",
    ".raw",
    ".archive",
    ".attachments",
    ".trash",
    ".gitignore"
)

if ($IncludeDocs)    { $coreItems += "docs" }
if ($IncludeScripts) { $coreItems += "scripts" }

$coreItems += $AlsoRemove

# Filtrar a los que realmente existen
$toDelete = @()
foreach ($item in $coreItems) {
    $p = Join-Path $VaultPath $item
    if (Test-Path $p) { $toDelete += $item }
}

# Lo que se preserva
$allRootItems = @(Get-ChildItem -Path $VaultPath -Force | Select-Object -ExpandProperty Name)
$toPreserve   = $allRootItems | Where-Object { $coreItems -notcontains $_ }

Write-Host ""
Write-Host "=== Reset del Vault ===" -ForegroundColor Cyan
Write-Host "Vault: $VaultPath" -ForegroundColor DarkGray
Write-Host ""

if ($toDelete.Count -eq 0) {
    Write-Host "Nada que limpiar - el vault ya esta vacio." -ForegroundColor Yellow
    exit 0
}

Write-Host "SE VA A BORRAR ($($toDelete.Count) items):" -ForegroundColor Red
foreach ($item in $toDelete) {
    Write-Host "  - $item" -ForegroundColor Red
}

Write-Host ""
Write-Host "SE PRESERVARA ($($toPreserve.Count) items, tus proyectos entre ellos):" -ForegroundColor Green
foreach ($item in $toPreserve) {
    Write-Host "  + $item" -ForegroundColor Green
}

Write-Host ""

# Confirmacion
if (-not $Yes) {
    $confirm = Read-Host "Continuar? (escribe SI en mayusculas para proceder)"
    if ($confirm -ne "SI") {
        Write-Host "Cancelado. Nada modificado." -ForegroundColor Yellow
        exit 0
    }
}

# Backup
if (-not $NoBackup) {
    $parentDir  = Split-Path $VaultPath -Parent
    $vaultName  = Split-Path $VaultPath -Leaf
    $timestamp  = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $backupPath = Join-Path $parentDir "$vaultName-backup-$timestamp.zip"

    Write-Host ""
    Write-Host "Creando backup en: $backupPath" -ForegroundColor Cyan

    $tempBackupDir = Join-Path $env:TEMP "vault-backup-$timestamp"
    New-Item -ItemType Directory -Path $tempBackupDir -Force | Out-Null

    foreach ($item in $toDelete) {
        $src = Join-Path $VaultPath $item
        $dst = Join-Path $tempBackupDir $item
        try {
            if (Test-Path $src -PathType Container) {
                Copy-Item -Path $src -Destination $dst -Recurse -Force -ErrorAction Continue
            } else {
                Copy-Item -Path $src -Destination $dst -Force -ErrorAction Continue
            }
        } catch {
            Write-Host "  (aviso) no se pudo copiar $item al backup: $_" -ForegroundColor DarkYellow
        }
    }

    try {
        Compress-Archive -Path "$tempBackupDir\*" -DestinationPath $backupPath -Force
        Write-Host "Backup OK: $backupPath" -ForegroundColor Green
    } catch {
        Write-Host "ERROR al crear zip: $_" -ForegroundColor Red
        Write-Host "El backup sin comprimir quedo en: $tempBackupDir" -ForegroundColor Yellow
        Write-Host "Cancelado para no perder datos." -ForegroundColor Red
        exit 1
    }

    Remove-Item -Path $tempBackupDir -Recurse -Force
}

# Borrar
Write-Host ""
Write-Host "Borrando..." -ForegroundColor Yellow
foreach ($item in $toDelete) {
    $p = Join-Path $VaultPath $item
    try {
        Remove-Item -Path $p -Recurse -Force -ErrorAction Stop
        Write-Host "  x $item" -ForegroundColor DarkGray
    } catch {
        Write-Host "  ! no se pudo borrar $item ($_)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Vault limpio ===" -ForegroundColor Green
Write-Host ""
Write-Host "Tus carpetas de proyectos siguen intactas." -ForegroundColor Cyan
Write-Host ""
Write-Host "Siguiente paso - re-ejecutar el bootstrap para un vault fresco:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  cd `$env:TEMP\obsidian-brain-kit"
Write-Host "  git pull"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\scripts\install-remote.ps1 -VaultPath `"$VaultPath`""
Write-Host ""
Write-Host "Y en Obsidian: File -> Close vault -> Open folder as vault -> $VaultPath" -ForegroundColor Yellow
