#!/usr/bin/env bash
# Bootstrap Obsidian vault con la misma configuracion que el equipo principal.
#
# Uso:
#   chmod +x bootstrap-obsidian.sh
#   ./bootstrap-obsidian.sh [VAULT_PATH]
#
# Ejecutalo desde el root del vault o pasa el path como argumento.
# Funciona en Git Bash (Windows), WSL, macOS y Linux.
# Requisitos: curl, bash 4+.
#
# Es idempotente: puedes correrlo multiples veces sin romper nada.

set -euo pipefail

VAULT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(dirname "$SCRIPT_DIR")"
SEEDS_DIR="$KIT_DIR/seeds"

cd "$VAULT"

echo "==> Bootstrapping Obsidian vault en: $VAULT"
echo "==> Kit en: $KIT_DIR"
echo

# ----------------------------------------------------------------------
# 1. Estructura de folders del vault
# ----------------------------------------------------------------------
echo "==> Creando estructura de folders..."
mkdir -p \
  .obsidian/plugins \
  .obsidian/snippets \
  .raw \
  _templates \
  wiki/daily \
  wiki/weekly \
  wiki/monthly \
  wiki/quarterly \
  wiki/meetings \
  wiki/smart-chats \
  wiki/projects \
  wiki/concepts \
  wiki/learning \
  wiki/questions \
  wiki/resources \
  wiki/people \
  wiki/entities \
  wiki/areas \
  wiki/goals \
  wiki/sources \
  wiki/meta \
  docs \
  scripts

# ----------------------------------------------------------------------
# 2. Plugins — descargar los 9 community plugins desde GitHub releases
# ----------------------------------------------------------------------
# Formato: id|owner/repo
PLUGINS=(
  "dataview|blacksmithgu/obsidian-dataview"
  "templater-obsidian|SilentVoid13/Templater"
  "obsidian-git|Vinzent03/obsidian-git"
  "periodic-notes|liamcain/obsidian-periodic-notes"
  "calendar-beta|liamcain/obsidian-calendar-plugin"
  "obsidian-tasks-plugin|obsidian-tasks-group/obsidian-tasks"
  "quickadd|chhoumann/quickadd"
  "nldates-obsidian|argenos/nldates-obsidian"
  "omnisearch|scambier/obsidian-omnisearch"
  "table-editor-obsidian|tgrosinger/advanced-tables-obsidian"
  "obsidian-kanban|mgmeyers/obsidian-kanban"
  "smart-connections|brianpetro/obsidian-smart-connections"
)

echo "==> Descargando ${#PLUGINS[@]} plugins..."
for entry in "${PLUGINS[@]}"; do
  id="${entry%%|*}"
  repo="${entry#*|}"
  dir=".obsidian/plugins/$id"
  mkdir -p "$dir"
  echo "    - $id (desde $repo)"
  for file in manifest.json main.js styles.css; do
    url="https://github.com/$repo/releases/latest/download/$file"
    curl -sSL --fail -o "$dir/$file" "$url" 2>/dev/null || \
      echo "      (opcional $file no disponible, OK)"
  done
  # Verificar que el id del manifest coincide; si no, renombrar folder
  if [[ -f "$dir/manifest.json" ]]; then
    actual_id=$(grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' "$dir/manifest.json" | sed 's/.*"\([^"]*\)"$/\1/')
    if [[ -n "$actual_id" && "$actual_id" != "$id" ]]; then
      echo "      (renombrando $id -> $actual_id para coincidir con manifest)"
      mv "$dir" ".obsidian/plugins/$actual_id"
    fi
  fi
done

# ----------------------------------------------------------------------
# 3. Enable community plugins
# ----------------------------------------------------------------------
echo "==> Escribiendo community-plugins.json..."
cat > .obsidian/community-plugins.json <<'EOF'
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
EOF

# ----------------------------------------------------------------------
# 4. Core plugins
# ----------------------------------------------------------------------
echo "==> Escribiendo core-plugins.json..."
cat > .obsidian/core-plugins.json <<'EOF'
{
  "file-explorer": true,
  "global-search": true,
  "switcher": true,
  "graph": true,
  "backlink": true,
  "canvas": true,
  "outgoing-link": true,
  "tag-pane": true,
  "footnotes": true,
  "properties": true,
  "page-preview": true,
  "daily-notes": false,
  "templates": true,
  "note-composer": true,
  "command-palette": true,
  "slash-command": true,
  "editor-status": true,
  "bookmarks": true,
  "markdown-importer": true,
  "zk-prefixer": false,
  "random-note": true,
  "outline": true,
  "word-count": true,
  "slides": false,
  "audio-recorder": true,
  "workspaces": true,
  "file-recovery": true,
  "publish": false,
  "sync": false,
  "bases": true,
  "webviewer": true
}
EOF

# ----------------------------------------------------------------------
# 5. App settings
# ----------------------------------------------------------------------
echo "==> Escribiendo app.json..."
cat > .obsidian/app.json <<'EOF'
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
  "userIgnoreFilters": [
    "node_modules",
    ".git",
    ".next",
    ".turbo",
    "build",
    "dist",
    ".dart_tool",
    ".gradle",
    "android/app",
    "ios/Pods"
  ],
  "openBehavior": "daily"
}
EOF

# ----------------------------------------------------------------------
# 6. Hotkeys globales
# ----------------------------------------------------------------------
echo "==> Escribiendo hotkeys.json..."
cat > .obsidian/hotkeys.json <<'EOF'
{
  "periodic-notes:open-daily-note": [
    { "modifiers": ["Mod", "Alt"], "key": "D" }
  ],
  "periodic-notes:open-weekly-note": [
    { "modifiers": ["Mod", "Alt"], "key": "W" }
  ],
  "periodic-notes:open-monthly-note": [
    { "modifiers": ["Mod", "Alt"], "key": "M" }
  ],
  "periodic-notes:open-quarterly-note": [
    { "modifiers": ["Mod", "Alt"], "key": "Q" }
  ],
  "graph:open": [
    { "modifiers": ["Mod", "Shift"], "key": "G" }
  ],
  "bookmarks:open": [
    { "modifiers": ["Mod", "Shift"], "key": "B" }
  ],
  "switcher:open": [
    { "modifiers": ["Mod"], "key": "O" }
  ],
  "command-palette:open": [
    { "modifiers": ["Mod", "Shift"], "key": "P" }
  ],
  "omnisearch:show-modal": [
    { "modifiers": ["Mod", "Shift"], "key": "F" }
  ],
  "quickadd:runQuickAdd": [
    { "modifiers": ["Mod"], "key": "J" }
  ],
  "obsidian-tasks-plugin:edit-task": [
    { "modifiers": ["Mod", "Shift"], "key": "T" }
  ],
  "smart-connections:open-view": [
    { "modifiers": ["Mod", "Shift"], "key": "S" }
  ],
  "calendar:show-calendar-view": [
    { "modifiers": ["Mod", "Shift"], "key": "C" }
  ],
  "editor:toggle-source": [
    { "modifiers": ["Mod", "Alt"], "key": "L" }
  ],
  "canvas:new-file": [
    { "modifiers": ["Mod", "Alt"], "key": "N" }
  ]
}
EOF

# ----------------------------------------------------------------------
# 7. Appearance (dark theme predeterminado)
# ----------------------------------------------------------------------
echo "==> Escribiendo appearance.json..."
cat > .obsidian/appearance.json <<'EOF'
{
  "cssTheme": "",
  "enabledCssSnippets": [
    "vault-colors"
  ]
}
EOF

# ----------------------------------------------------------------------
# 8. Graph view con grupos de color
# ----------------------------------------------------------------------
echo "==> Escribiendo graph.json..."
cat > .obsidian/graph.json <<'EOF'
{
  "collapse-filter": true,
  "search": "path:wiki",
  "showTags": false,
  "showAttachments": false,
  "hideUnresolved": false,
  "showOrphans": true,
  "collapse-color-groups": false,
  "colorGroups": [
    { "query": "path:wiki/concepts", "color": { "a": 1, "rgb": 16505870 } },
    { "query": "path:wiki/projects", "color": { "a": 1, "rgb": 10748144 } },
    { "query": "path:wiki/areas",    "color": { "a": 1, "rgb": 5420768  } },
    { "query": "path:wiki/sources",  "color": { "a": 1, "rgb": 15557383 } },
    { "query": "path:wiki/goals",    "color": { "a": 1, "rgb": 65344    } }
  ],
  "collapse-display": false,
  "showArrow": false,
  "textFadeMultiplier": 0,
  "nodeSizeMultiplier": 1,
  "lineSizeMultiplier": 1,
  "collapse-forces": true,
  "centerStrength": 0.5,
  "repelStrength": 10,
  "linkStrength": 1,
  "linkDistance": 250,
  "scale": 1,
  "close": false
}
EOF

# ----------------------------------------------------------------------
# 9. CSS snippet (folder colors + callouts custom)
# ----------------------------------------------------------------------
echo "==> Escribiendo CSS snippet..."
cat > .obsidian/snippets/vault-colors.css <<'EOF'
/* Colores de carpeta en el file explorer */
.nav-folder-title[data-path^="wiki/concepts"]    { color: #fbbf24; }
.nav-folder-title[data-path^="wiki/projects"]    { color: #a3e635; }
.nav-folder-title[data-path^="wiki/areas"]       { color: #60a5fa; }
.nav-folder-title[data-path^="wiki/sources"]     { color: #f87171; }
.nav-folder-title[data-path^="wiki/goals"]       { color: #34d399; }
.nav-folder-title[data-path^="wiki/learning"]    { color: #c084fc; }
.nav-folder-title[data-path^="wiki/questions"]   { color: #fb923c; }
.nav-folder-title[data-path^="wiki/daily"]       { color: #94a3b8; }
.nav-folder-title[data-path^="wiki/weekly"]      { color: #94a3b8; }
.nav-folder-title[data-path^="wiki/meta"]        { color: #ec4899; }

/* Callouts custom */
.callout[data-callout="contradiction"] { --callout-color: 239, 68, 68;  --callout-icon: zap;   }
.callout[data-callout="gap"]           { --callout-color: 251, 146, 60; --callout-icon: help-circle; }
.callout[data-callout="key-insight"]   { --callout-color: 52, 211, 153; --callout-icon: lightbulb; }
.callout[data-callout="stale"]         { --callout-color: 148, 163, 184; --callout-icon: archive; }
EOF

# ----------------------------------------------------------------------
# 10. Plugin data.json — configuracion de cada plugin
# ----------------------------------------------------------------------
echo "==> Configurando plugins..."

# Periodic Notes
cat > .obsidian/plugins/periodic-notes/data.json <<'EOF'
{
  "showGettingStartedBanner": false,
  "hasMigratedDailyNoteSettings": true,
  "hasMigratedWeeklyNoteSettings": true,
  "daily":    { "available": true,  "format": "YYYY-MM-DD",  "template": "_templates/daily.md",             "folder": "wiki/daily",     "enabled": true },
  "weekly":   { "available": true,  "format": "YYYY-[W]ww",  "template": "_templates/weekly-review.md",     "folder": "wiki/weekly",    "enabled": true },
  "monthly":  { "available": true,  "format": "YYYY-MM",     "template": "_templates/monthly-review.md",    "folder": "wiki/monthly",   "enabled": true },
  "quarterly":{ "available": true,  "format": "YYYY-[Q]Q",   "template": "_templates/quarterly-review.md",  "folder": "wiki/quarterly", "enabled": true },
  "yearly":   { "available": false, "enabled": false }
}
EOF

# Calendar
[[ -d .obsidian/plugins/calendar-beta ]] && cat > .obsidian/plugins/calendar-beta/data.json <<'EOF'
{
  "shouldConfirmBeforeCreate": true,
  "weekStart": "monday",
  "wordsPerDot": 250,
  "showWeeklyNote": true,
  "weeklyNoteFormat": "YYYY-[W]ww",
  "weeklyNoteTemplate": "_templates/weekly-review.md",
  "weeklyNoteFolder": "wiki/weekly",
  "localeOverride": "system-default"
}
EOF

# Natural Language Dates
cat > .obsidian/plugins/nldates-obsidian/data.json <<'EOF'
{
  "autocomplete": true,
  "autosuggestToggleLink": true,
  "format": "YYYY-MM-DD",
  "separator": " ",
  "weekStart": "Monday",
  "modalToggleTime": true,
  "modalToggleLink": true,
  "modalMomentFormat": "YYYY-MM-DD HH:mm",
  "timeFormat": "HH:mm",
  "isAutosuggestEnabled": true
}
EOF

# Omnisearch
cat > .obsidian/plugins/omnisearch/data.json <<'EOF'
{
  "useCache": true,
  "indexedFileTypes": ["md", "canvas", "base"],
  "PDFIndexing": false,
  "imagesIndexing": false,
  "splitCamelCase": true,
  "vimLikeNavigationShortcut": true,
  "showExcerpt": true,
  "highlight": true,
  "fuzziness": "1",
  "weightBasename": 10,
  "weightDirectory": 7,
  "weightH1": 6,
  "weightH2": 5,
  "weightH3": 4
}
EOF

# Advanced Tables
cat > .obsidian/plugins/table-editor-obsidian/data.json <<'EOF'
{
  "formatType": "normal",
  "showRibbonIcon": true,
  "bindEnter": true,
  "bindTab": true
}
EOF

# Kanban
cat > .obsidian/plugins/obsidian-kanban/data.json <<'EOF'
{
  "new-note-folder": "wiki/projects",
  "new-note-template": "_templates/project.md",
  "show-checkboxes": true,
  "show-add-list": true,
  "show-archive-all": true,
  "show-board-settings": true,
  "show-relative-date": true,
  "show-search": true,
  "lane-width": 272
}
EOF

# Smart Connections
cat > .obsidian/plugins/smart-connections/data.json <<'EOF'
{
  "folders": ["wiki"],
  "excluded_folders": [".raw", ".obsidian", ".archive", ".attachments"],
  "folder_exclusions": ".raw,.obsidian,.archive,.attachments",
  "smart_chat_folder": "wiki/smart-chats",
  "results_count": 30,
  "expanded_view": true,
  "group_nearest_by_file": true
}
EOF

# Daily Notes core plugin settings (por si se activa)
cat > .obsidian/daily-notes.json <<'EOF'
{
  "folder": "wiki/daily",
  "template": "_templates/daily.md",
  "format": "YYYY-MM-DD"
}
EOF

# Templates core plugin
cat > .obsidian/templates.json <<'EOF'
{
  "folder": "_templates"
}
EOF

# ----------------------------------------------------------------------
# 11. .gitignore para el vault (si no existe)
# ----------------------------------------------------------------------
if [[ ! -f .gitignore ]]; then
  echo "==> Creando .gitignore..."
  cat > .gitignore <<'EOF'
# Obsidian state por equipo
.obsidian/workspace.json
.obsidian/workspace-*.json
.obsidian/workspaces.json

# Caches de plugins
.obsidian/plugins/smart-connections/.smart-env/
.obsidian/plugins/omnisearch/*.json.gz
.obsidian/plugins/obsidian-git/git-logs/

# Attachments grandes (opcional — quitar si quieres versionar imagenes)
# wiki/.attachments/

# OS / editores
.DS_Store
Thumbs.db
*.swp
EOF
fi

# ----------------------------------------------------------------------
# 12. Copiar seeds (templates + CLAUDE.md + wiki hub files)
# ----------------------------------------------------------------------
if [[ -d "$SEEDS_DIR" ]]; then
  TODAY="$(date +%Y-%m-%d)"
  echo "==> Copiando seeds desde $SEEDS_DIR..."

  # Templates — solo si no existen ya (no sobreescribe personalizaciones)
  if [[ -d "$SEEDS_DIR/_templates" ]]; then
    for tpl in "$SEEDS_DIR/_templates"/*.md; do
      name="$(basename "$tpl")"
      if [[ ! -f "_templates/$name" ]]; then
        cp "$tpl" "_templates/$name"
        echo "    + _templates/$name"
      else
        echo "    = _templates/$name (ya existe, no sobreescribo)"
      fi
    done
  fi

  # CLAUDE.md — solo si no existe
  if [[ -f "$SEEDS_DIR/CLAUDE.md" && ! -f "CLAUDE.md" ]]; then
    sed "s/\[FECHA DE SETUP\]/$TODAY/g" "$SEEDS_DIR/CLAUDE.md" > CLAUDE.md
    echo "    + CLAUDE.md (recuerda rellenar Owner y Active Projects)"
  fi

  # Wiki hub files y estructura
  if [[ -d "$SEEDS_DIR/wiki" ]]; then
    # Archivos de root (Home, hot, index, log, Inbox, overview)
    for f in "$SEEDS_DIR/wiki"/*.md; do
      [[ -f "$f" ]] || continue
      name="$(basename "$f")"
      if [[ ! -f "wiki/$name" ]]; then
        sed "s/\[FECHA\]/$TODAY/g" "$f" > "wiki/$name"
        echo "    + wiki/$name"
      fi
    done

    # Subcarpetas (areas, goals, meta)
    for sub in areas goals meta; do
      if [[ -d "$SEEDS_DIR/wiki/$sub" ]]; then
        for f in "$SEEDS_DIR/wiki/$sub"/*.md; do
          [[ -f "$f" ]] || continue
          name="$(basename "$f")"
          if [[ ! -f "wiki/$sub/$name" ]]; then
            sed "s/\[FECHA\]/$TODAY/g" "$f" > "wiki/$sub/$name"
            echo "    + wiki/$sub/$name"
          fi
        done
      fi
    done
  fi
else
  echo "==> No se encontro $SEEDS_DIR, salto copia de seeds."
fi

# ----------------------------------------------------------------------
# 13. Resumen final
# ----------------------------------------------------------------------
echo
echo "==> Bootstrap completo."
echo
echo "Siguiente paso manual:"
echo "  1. Abrir Obsidian y seleccionar esta carpeta como vault"
echo "  2. Aprobar los plugins comunitarios (dialogo 'trust' primera vez)"
echo "  3. Editar CLAUDE.md -> rellenar Owner y tabla de Active Projects"
echo "  4. En Smart Connections: elegir modelo (local o remoto con API key)"
echo "  5. En Obsidian Git: configurar remote (opcional)"
echo "  6. Primera daily note: Mod+Alt+D"
echo
echo "Plugins instalados:"
ls -1 .obsidian/plugins
