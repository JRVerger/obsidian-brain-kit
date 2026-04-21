# Personal Dev Wiki

Mode: D (Personal / Second Brain) + Developer Projects
Purpose: Personal second brain for organizing life, learning, and developer projects
Owner: [TU NOMBRE]
Created: [FECHA DE SETUP]

## Quick Start for Claude

**ALWAYS start a session by reading `wiki/hot.md`** (~500 words, instant context).

If you need more:
1. `wiki/hot.md` — what happened recently
2. `wiki/index.md` — full catalog of all pages
3. `wiki/Home.md` — hub with navigation to everything
4. `wiki/MOC *.md` — Maps of Content by domain

## Structure

```
vault/
├── .raw/              # source documents (immutable, never modify)
├── wiki/
│   ├── Home.md        # central hub — start here
│   ├── index.md       # master catalog of all pages
│   ├── log.md         # chronological operations log (append-only, newest on top)
│   ├── hot.md         # hot cache (~500 words recent context)
│   ├── overview.md    # executive summary
│   ├── MOC *.md       # Maps of Content by domain
│   ├── goals/         # personal and professional goals
│   ├── learning/      # concepts being mastered
│   ├── people/        # relationships, contacts
│   ├── areas/         # life areas: health, career, finances, creative, learning
│   ├── resources/     # books, courses, tools
│   ├── projects/      # developer projects portfolio
│   ├── questions/     # filed answers to queries
│   ├── sources/       # one summary per raw source
│   ├── concepts/      # ideas, patterns, frameworks
│   ├── entities/      # people, orgs, products
│   ├── daily/         # daily notes
│   ├── weekly/        # weekly reviews (Periodic Notes)
│   ├── monthly/       # monthly reviews (Periodic Notes)
│   ├── quarterly/     # quarterly reviews (Periodic Notes)
│   ├── meetings/      # meeting notes (QuickAdd)
│   ├── smart-chats/   # Smart Connections chat sessions
│   └── meta/          # dashboards (.base + .md), lint reports
├── _templates/        # note templates
├── docs/              # plans and specs
└── CLAUDE.md          # this file
```

## Automated Brain Behaviors

These behaviors run automatically. No user action needed.

### 1. Auto Daily Note
When starting a work session, check if `wiki/daily/YYYY-MM-DD.md` exists for today. If not, create it using the daily template.

### 2. Auto Research
When the user asks about a topic and no relevant pages exist in the wiki:
1. Search the wiki first (`wiki/concepts/`, `wiki/sources/`)
2. If no relevant page exists → automatically run `/autoresearch [topic]`
3. Tell the user: "No tenia info sobre esto en el brain, estoy investigando..."

### 3. Auto Learning Capture
After explaining a significant concept, solving a non-trivial problem, or teaching something new:
1. Create a learning note in `wiki/learning/` using the learning template
2. Fill in: what was learned, key concepts, practical application, related project
3. Update `wiki/index.md` and `wiki/hot.md`
4. Tell the user: "Guardado en el brain: [[Learning Name]]"

Skip for trivial things (typo fixes, simple questions).

### 4. Auto Lint (counter-based)
Track operations in `wiki/hot.md` under `## Ops Counter`. Increment after every ingest, page creation, or significant edit.
When counter reaches 15:
1. Automatically run `lint the wiki`
2. Reset counter to 0
3. Tell the user: "Auto-lint ejecutado, N issues encontrados"

### 5. Auto Project Ingest
When editing, creating, or meaningfully touching code in any Active Project (table below), at end of session:
1. Identify which project was touched
2. Update the corresponding `wiki/projects/[Project].md`:
   - Append dated entry to `## Change Log` (create if missing)
   - Update `## Siguiente Hito`
   - If non-obvious insight → trigger automation #3 linked to project
   - Bump `updated:` date in frontmatter
3. Tell the user: "Proyecto [[Name]] actualizado en el brain"

Skip trivial edits (typos, single-line fixes without context).

### 6. Auto Daily Briefing
When starting a session and today's daily note has empty `## Focus`, suggest 3 bullets from:
- Open items in `## Siguiente Hito` of active projects
- Overdue tasks from Tasks queries
- Weekly review `## Next Week Priorities`

Ask: "Propongo estos 3 focos para hoy, OK?"

## Plugins & Tooling

12 community plugins instalados:

**Core + PKM:**
- `dataview` · `templater-obsidian` · `obsidian-git` · `periodic-notes` · `calendar-beta` · `nldates-obsidian` · `omnisearch` · `table-editor-obsidian`

**Workflow:**
- `obsidian-tasks-plugin` · `quickadd` (5 choices: Inbox, Concept, Question, Learning, Meeting) · `obsidian-kanban`

**AI:**
- `smart-connections` (embeddings locales + chat con el vault)

Hotkeys clave:
- `Mod+Alt+D/W/M/Q` → daily/weekly/monthly/quarterly notes
- `Mod+J` → QuickAdd (captura rápida)
- `Mod+Shift+F` → Omnisearch
- `Mod+Shift+S` → Smart Connections
- `Mod+Shift+C` → Calendar

## Conventions

- All notes use YAML frontmatter: type, status, created, updated, tags (minimum)
- Wikilinks use [[Note Name]] format: filenames are unique, no paths needed
- .raw/ contains source documents: never modify them
- wiki/index.md is the master catalog: update on every ingest
- wiki/log.md is append-only: never edit past entries
- New log entries go at the TOP of the file
- Status values: seed → developing → mature → evergreen
- Always update wiki/hot.md after significant operations

## Operations

| Action | How |
|--------|-----|
| **Ingest** | Drop source in `.raw/`, say "ingest [filename]" |
| **Query** | Ask any question — Claude reads hot.md → index → drills in |
| **Lint** | Say "lint the wiki" for health check |
| **Daily note** | Periodic Notes: Mod+Alt+D |
| **Weekly/Monthly/Quarterly** | Mod+Alt+W / M / Q |
| **Quick capture** | QuickAdd: Mod+J → elegir choice |
| **Full-text search** | Omnisearch: Mod+Shift+F |
| **Semantic search** | Smart Connections sidebar: Mod+Shift+S |
| **Save insight** | `/save` command |
| **Research** | `/autoresearch [topic]` |
| **Archive** | Move cold sources to `.archive/` |

## Cross-Project Brain

This wiki serves as shared context for ALL projects in this equipo. Each project folder should have a `CLAUDE.md` pointing to its page:

```markdown
# Proyecto X

Shared brain at: `[VAULT_PATH]/wiki/projects/X.md`
Recent context: `[VAULT_PATH]/wiki/hot.md`
Hub: `[VAULT_PATH]/wiki/Home.md`
```

## Active Projects

> **RELLENAR al configurar este equipo** con los proyectos reales que viven aquí.

| Project | Path | Stack |
|---------|------|-------|
| [Proyecto 1] | [carpeta/] | [stack] |
| [Proyecto 2] | [carpeta/] | [stack] |

---

**Setup:** este archivo viene de `obsidian-kit`. Adapta la tabla de Active Projects, el Owner, la fecha de Created y cualquier nota específica del equipo.
