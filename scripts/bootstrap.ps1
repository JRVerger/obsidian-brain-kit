# Bootstrap Obsidian vault con la misma configuracion que el equipo principal.
# Version PowerShell (Windows nativo, sin Git Bash).
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\bootstrap-obsidian.ps1
#   powershell -ExecutionPolicy Bypass -File .\bootstrap-obsidian.ps1 -VaultPath "C:\ruta\al\vault"
#
# Es idempotente: se puede ejecutar multiples veces sin romper nada.

param(
    [string]$VaultPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$KitDir    = Split-Path -Parent $ScriptDir
$SeedsDir  = Join-Path $KitDir "seeds"
Set-Location $VaultPath

Write-Host "==> Bootstrapping Obsidian vault en: $VaultPath" -ForegroundColor Cyan
Write-Host "==> Kit en: $KitDir" -ForegroundColor Cyan

# ---------------------------------------------------------------------
# 1. Estructura de folders
# ---------------------------------------------------------------------
Write-Host "==> Creando estructura de folders..." -ForegroundColor Yellow
$folders = @(
    ".obsidian\plugins", ".obsidian\snippets",
    ".raw", "_templates",
    "wiki\daily", "wiki\weekly", "wiki\monthly", "wiki\quarterly",
    "wiki\meetings", "wiki\smart-chats",
    "wiki\projects", "wiki\concepts", "wiki\learning", "wiki\questions",
    "wiki\resources", "wiki\people", "wiki\entities", "wiki\areas",
    "wiki\goals", "wiki\sources", "wiki\meta",
    "docs", "scripts"
)
foreach ($f in $folders) { New-Item -ItemType Directory -Path $f -Force | Out-Null }

# ---------------------------------------------------------------------
# 2. Plugins — descargar 12 community plugins desde GitHub releases
# ---------------------------------------------------------------------
$plugins = @(
    @{ id = "dataview";                  repo = "blacksmithgu/obsidian-dataview" },
    @{ id = "templater-obsidian";        repo = "SilentVoid13/Templater" },
    @{ id = "obsidian-git";              repo = "Vinzent03/obsidian-git" },
    @{ id = "periodic-notes";            repo = "liamcain/obsidian-periodic-notes" },
    @{ id = "calendar-beta";             repo = "liamcain/obsidian-calendar-plugin" },
    @{ id = "obsidian-tasks-plugin";     repo = "obsidian-tasks-group/obsidian-tasks" },
    @{ id = "quickadd";                  repo = "chhoumann/quickadd" },
    @{ id = "nldates-obsidian";          repo = "argenos/nldates-obsidian" },
    @{ id = "omnisearch";                repo = "scambier/obsidian-omnisearch" },
    @{ id = "table-editor-obsidian";     repo = "tgrosinger/advanced-tables-obsidian" },
    @{ id = "obsidian-kanban";           repo = "mgmeyers/obsidian-kanban" },
    @{ id = "smart-connections";         repo = "brianpetro/obsidian-smart-connections" }
)

Write-Host "==> Descargando $($plugins.Count) plugins..." -ForegroundColor Yellow
foreach ($p in $plugins) {
    $dir = ".obsidian\plugins\$($p.id)"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "    - $($p.id) (desde $($p.repo))"
    foreach ($file in @("manifest.json", "main.js", "styles.css")) {
        $url = "https://github.com/$($p.repo)/releases/latest/download/$file"
        try {
            Invoke-WebRequest -Uri $url -OutFile "$dir\$file" -UseBasicParsing -ErrorAction Stop
        } catch {
            Write-Host "      (opcional $file no disponible, OK)" -ForegroundColor DarkGray
        }
    }
    # Validar id del manifest y renombrar folder si difiere
    $manifestPath = "$dir\manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
        if ($manifest.id -and $manifest.id -ne $p.id) {
            Write-Host "      (renombrando $($p.id) -> $($manifest.id))" -ForegroundColor DarkGray
            Rename-Item -Path $dir -NewName $manifest.id -Force
        }
    }
}

# ---------------------------------------------------------------------
# 3. Config de Obsidian
# ---------------------------------------------------------------------
Write-Host "==> Escribiendo archivos de configuracion..." -ForegroundColor Yellow

@'
[
  "dataview",
  "templater-obsidian",
  "obsidian-git",
  "periodic-notes",
  "calendar-beta",
  "obsidian-tasks-plugin",
  "quickadd",
  "nldates-obsidian",
  "omnisearch",
  "table-editor-obsidian",
  "obsidian-kanban",
  "smart-connections"
]
'@ | Out-File -Encoding utf8 .obsidian\community-plugins.json

@'
{
  "file-explorer": true, "global-search": true, "switcher": true, "graph": true,
  "backlink": true, "canvas": true, "outgoing-link": true, "tag-pane": true,
  "footnotes": true, "properties": true, "page-preview": true, "daily-notes": false,
  "templates": true, "note-composer": true, "command-palette": true, "slash-command": true,
  "editor-status": true, "bookmarks": true, "markdown-importer": true, "zk-prefixer": false,
  "random-note": true, "outline": true, "word-count": true, "slides": false,
  "audio-recorder": true, "workspaces": true, "file-recovery": true, "publish": false,
  "sync": false, "bases": true, "webviewer": true
}
'@ | Out-File -Encoding utf8 .obsidian\core-plugins.json

@'
{
  "defaultViewMode": "preview",
  "livePreview": true,
  "showFrontmatter": true,
  "foldHeading": true,
  "foldIndent": true,
  "showLineNumber": true,
  "useTab": false,
  "tabSize": 2,
  "readableLineLength": true,
  "strictLineBreaks": false,
  "autoConvertHtml": true,
  "alwaysUpdateLinks": true,
  "promptDelete": true,
  "trashOption": "local",
  "attachmentFolderPath": ".attachments",
  "newFileLocation": "folder",
  "newFileFolderPath": "wiki",
  "showUnsupportedFiles": false,
  "openBehavior": "daily"
}
'@ | Out-File -Encoding utf8 .obsidian\app.json

@'
{
  "periodic-notes:open-daily-note":   [{ "modifiers": ["Mod","Alt"],   "key": "D" }],
  "periodic-notes:open-weekly-note":  [{ "modifiers": ["Mod","Alt"],   "key": "W" }],
  "periodic-notes:open-monthly-note": [{ "modifiers": ["Mod","Alt"],   "key": "M" }],
  "periodic-notes:open-quarterly-note":[{ "modifiers": ["Mod","Alt"],  "key": "Q" }],
  "graph:open":                       [{ "modifiers": ["Mod","Shift"], "key": "G" }],
  "bookmarks:open":                   [{ "modifiers": ["Mod","Shift"], "key": "B" }],
  "switcher:open":                    [{ "modifiers": ["Mod"],         "key": "O" }],
  "command-palette:open":             [{ "modifiers": ["Mod","Shift"], "key": "P" }],
  "omnisearch:show-modal":            [{ "modifiers": ["Mod","Shift"], "key": "F" }],
  "quickadd:runQuickAdd":             [{ "modifiers": ["Mod"],         "key": "J" }],
  "obsidian-tasks-plugin:edit-task":  [{ "modifiers": ["Mod","Shift"], "key": "T" }],
  "smart-connections:open-view":      [{ "modifiers": ["Mod","Shift"], "key": "S" }],
  "calendar:show-calendar-view":      [{ "modifiers": ["Mod","Shift"], "key": "C" }],
  "editor:toggle-source":             [{ "modifiers": ["Mod","Alt"],   "key": "L" }],
  "canvas:new-file":                  [{ "modifiers": ["Mod","Alt"],   "key": "N" }]
}
'@ | Out-File -Encoding utf8 .obsidian\hotkeys.json

@'
{
  "cssTheme": "",
  "enabledCssSnippets": ["vault-colors"]
}
'@ | Out-File -Encoding utf8 .obsidian\appearance.json

@'
{ "folder": "wiki/daily",    "template": "_templates/daily.md",          "format": "YYYY-MM-DD" }
'@ | Out-File -Encoding utf8 .obsidian\daily-notes.json

@'
{ "folder": "_templates" }
'@ | Out-File -Encoding utf8 .obsidian\templates.json

# ---------------------------------------------------------------------
# 4. Plugin data.json (configuracion preset)
# ---------------------------------------------------------------------
Write-Host "==> Configurando plugins..." -ForegroundColor Yellow

@'
{
  "showGettingStartedBanner": false,
  "hasMigratedDailyNoteSettings": true,
  "hasMigratedWeeklyNoteSettings": true,
  "daily":    { "available": true,  "format": "YYYY-MM-DD",  "template": "_templates/daily.md",            "folder": "wiki/daily",     "enabled": true },
  "weekly":   { "available": true,  "format": "YYYY-[W]ww",  "template": "_templates/weekly-review.md",    "folder": "wiki/weekly",    "enabled": true },
  "monthly":  { "available": true,  "format": "YYYY-MM",     "template": "_templates/monthly-review.md",   "folder": "wiki/monthly",   "enabled": true },
  "quarterly":{ "available": true,  "format": "YYYY-[Q]Q",   "template": "_templates/quarterly-review.md", "folder": "wiki/quarterly", "enabled": true },
  "yearly":   { "available": false, "enabled": false }
}
'@ | Out-File -Encoding utf8 .obsidian\plugins\periodic-notes\data.json

if (Test-Path .obsidian\plugins\calendar-beta) {
@'
{
  "shouldConfirmBeforeCreate": true, "weekStart": "monday", "wordsPerDot": 250,
  "showWeeklyNote": true, "weeklyNoteFormat": "YYYY-[W]ww",
  "weeklyNoteTemplate": "_templates/weekly-review.md",
  "weeklyNoteFolder": "wiki/weekly", "localeOverride": "system-default"
}
'@ | Out-File -Encoding utf8 .obsidian\plugins\calendar-beta\data.json
}

@'
{
  "autocomplete": true, "autosuggestToggleLink": true, "format": "YYYY-MM-DD",
  "separator": " ", "weekStart": "Monday", "modalToggleTime": true,
  "modalToggleLink": true, "modalMomentFormat": "YYYY-MM-DD HH:mm",
  "timeFormat": "HH:mm", "isAutosuggestEnabled": true
}
'@ | Out-File -Encoding utf8 .obsidian\plugins\nldates-obsidian\data.json

@'
{
  "useCache": true, "indexedFileTypes": ["md","canvas","base"],
  "PDFIndexing": false, "imagesIndexing": false, "splitCamelCase": true,
  "vimLikeNavigationShortcut": true, "showExcerpt": true, "highlight": true,
  "fuzziness": "1", "weightBasename": 10, "weightDirectory": 7,
  "weightH1": 6, "weightH2": 5, "weightH3": 4
}
'@ | Out-File -Encoding utf8 .obsidian\plugins\omnisearch\data.json

@'
{ "formatType": "normal", "showRibbonIcon": true, "bindEnter": true, "bindTab": true }
'@ | Out-File -Encoding utf8 .obsidian\plugins\table-editor-obsidian\data.json

@'
{
  "new-note-folder": "wiki/projects",
  "new-note-template": "_templates/project.md",
  "show-checkboxes": true, "show-add-list": true, "show-archive-all": true,
  "show-board-settings": true, "show-relative-date": true, "show-search": true,
  "lane-width": 272
}
'@ | Out-File -Encoding utf8 .obsidian\plugins\obsidian-kanban\data.json

@'
{
  "folders": ["wiki"],
  "excluded_folders": [".raw",".obsidian",".archive",".attachments"],
  "folder_exclusions": ".raw,.obsidian,.archive,.attachments",
  "smart_chat_folder": "wiki/smart-chats",
  "results_count": 30, "expanded_view": true, "group_nearest_by_file": true
}
'@ | Out-File -Encoding utf8 .obsidian\plugins\smart-connections\data.json

# ---------------------------------------------------------------------
# 5. CSS snippet
# ---------------------------------------------------------------------
@'
/* Colores de carpeta */
.nav-folder-title[data-path^="wiki/concepts"]  { color: #fbbf24; }
.nav-folder-title[data-path^="wiki/projects"]  { color: #a3e635; }
.nav-folder-title[data-path^="wiki/areas"]     { color: #60a5fa; }
.nav-folder-title[data-path^="wiki/sources"]   { color: #f87171; }
.nav-folder-title[data-path^="wiki/goals"]     { color: #34d399; }
.nav-folder-title[data-path^="wiki/learning"]  { color: #c084fc; }
.nav-folder-title[data-path^="wiki/questions"] { color: #fb923c; }
.nav-folder-title[data-path^="wiki/daily"]     { color: #94a3b8; }
.nav-folder-title[data-path^="wiki/weekly"]    { color: #94a3b8; }
.nav-folder-title[data-path^="wiki/meta"]      { color: #ec4899; }

/* Callouts custom */
.callout[data-callout="contradiction"] { --callout-color: 239,68,68;    --callout-icon: zap; }
.callout[data-callout="gap"]           { --callout-color: 251,146,60;   --callout-icon: help-circle; }
.callout[data-callout="key-insight"]   { --callout-color: 52,211,153;   --callout-icon: lightbulb; }
.callout[data-callout="stale"]         { --callout-color: 148,163,184;  --callout-icon: archive; }
'@ | Out-File -Encoding utf8 .obsidian\snippets\vault-colors.css

# ---------------------------------------------------------------------
# 6. .gitignore
# ---------------------------------------------------------------------
if (-not (Test-Path .gitignore)) {
@'
# Obsidian state por equipo
.obsidian/workspace.json
.obsidian/workspace-*.json
.obsidian/workspaces.json

# Plugin caches
.obsidian/plugins/smart-connections/.smart-env/
.obsidian/plugins/omnisearch/*.json.gz
.obsidian/plugins/obsidian-git/git-logs/

# OS / editores
.DS_Store
Thumbs.db
*.swp
'@ | Out-File -Encoding utf8 .gitignore
}

# ---------------------------------------------------------------------
# 7. Copiar seeds (templates + CLAUDE.md + wiki hub files)
# ---------------------------------------------------------------------
if (Test-Path $SeedsDir) {
    $Today = (Get-Date).ToString("yyyy-MM-dd")
    Write-Host "==> Copiando seeds desde $SeedsDir..." -ForegroundColor Yellow

    # Templates — sin sobreescribir existentes
    $tplSrc = Join-Path $SeedsDir "_templates"
    if (Test-Path $tplSrc) {
        Get-ChildItem -Path $tplSrc -Filter "*.md" -File | ForEach-Object {
            $dst = Join-Path "_templates" $_.Name
            if (-not (Test-Path $dst)) {
                Copy-Item $_.FullName $dst
                Write-Host "    + _templates\$($_.Name)"
            } else {
                Write-Host "    = _templates\$($_.Name) (ya existe)" -ForegroundColor DarkGray
            }
        }
    }

    # CLAUDE.md
    $claudeSrc = Join-Path $SeedsDir "CLAUDE.md"
    if ((Test-Path $claudeSrc) -and (-not (Test-Path "CLAUDE.md"))) {
        (Get-Content $claudeSrc -Raw).Replace("[FECHA DE SETUP]", $Today) | Out-File -Encoding utf8 "CLAUDE.md"
        Write-Host "    + CLAUDE.md (recuerda rellenar Owner y Active Projects)" -ForegroundColor Yellow
    }

    # Wiki hub files (root)
    $wikiSrc = Join-Path $SeedsDir "wiki"
    if (Test-Path $wikiSrc) {
        Get-ChildItem -Path $wikiSrc -Filter "*.md" -File | ForEach-Object {
            $dst = Join-Path "wiki" $_.Name
            if (-not (Test-Path $dst)) {
                (Get-Content $_.FullName -Raw).Replace("[FECHA]", $Today) | Out-File -Encoding utf8 $dst
                Write-Host "    + wiki\$($_.Name)"
            }
        }

        # Subcarpetas (areas, goals, meta)
        foreach ($sub in @("areas", "goals", "meta")) {
            $subSrc = Join-Path $wikiSrc $sub
            if (Test-Path $subSrc) {
                Get-ChildItem -Path $subSrc -Filter "*.md" -File | ForEach-Object {
                    $dst = Join-Path "wiki\$sub" $_.Name
                    if (-not (Test-Path $dst)) {
                        (Get-Content $_.FullName -Raw).Replace("[FECHA]", $Today) | Out-File -Encoding utf8 $dst
                        Write-Host "    + wiki\$sub\$($_.Name)"
                    }
                }
            }
        }
    }
} else {
    Write-Host "==> No se encontro $SeedsDir, salto copia de seeds." -ForegroundColor DarkGray
}

# ---------------------------------------------------------------------
# 8. Resumen
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "==> Bootstrap completo." -ForegroundColor Green
Write-Host ""
Write-Host "Siguiente paso manual:" -ForegroundColor Cyan
Write-Host "  1. Abrir Obsidian y seleccionar esta carpeta como vault"
Write-Host "  2. Aprobar los plugins comunitarios (dialogo trust primera vez)"
Write-Host "  3. Editar CLAUDE.md -> rellenar Owner y tabla de Active Projects"
Write-Host "  4. Smart Connections: elegir modelo (local o remoto con API key)"
Write-Host "  5. Obsidian Git: configurar remote (opcional)"
Write-Host "  6. Primera daily note: Mod+Alt+D"
Write-Host ""
Write-Host "Plugins instalados:" -ForegroundColor Cyan
Get-ChildItem .obsidian\plugins -Directory | Select-Object -ExpandProperty Name
