# Obsidian Kit

Kit portable para arrancar un vault Obsidian con la misma configuración y sistema en cualquier equipo. Pensado para contextos con proyectos **distintos** en cada equipo pero mismo workflow de segundo cerebro.

## Qué hace

Deja cualquier carpeta con:

- **12 plugins comunitarios** descargados de GitHub releases oficiales y preconfigurados:
  Dataview · Templater · Obsidian Git · Periodic Notes · Calendar · Tasks · QuickAdd · Natural Language Dates · Omnisearch · Advanced Tables · Kanban · Smart Connections
- **Core plugins ajustados** (slash-command, random-note, audio-recorder, webviewer, bases activos; daily-notes core desactivado a favor de Periodic Notes)
- **Hotkeys globales** alineadas (`Mod+Alt+D/W/M/Q`, `Mod+J` QuickAdd, `Mod+Shift+F` Omnisearch, `Mod+Shift+S` Smart Connections...)
- **CSS snippet** con colores semánticos por carpeta y callouts custom
- **15 templates** en `_templates/` (daily, weekly, monthly, quarterly, project, concept, learning, debug, adr, meeting, question, resource, source, entity, goal)
- **Estructura de wiki** lista: Home, hot, index, log, Inbox, overview, 5 areas, North Star template, 3 dashboards (tasks, projects, learning), kanban board
- **CLAUDE.md genérico** con 6 automatizaciones configuradas (daily note, auto-research, learning capture, auto-lint, auto-project-ingest, auto-daily-briefing)

## Qué NO hace

- No copia proyectos específicos de otro equipo (por diseño — cada equipo tiene los suyos)
- No lleva claves API ni secretos
- No sobreescribe archivos que ya existan (es seguro re-ejecutar)

## Uso rápido — one-liner remoto (recomendado)

**Windows PowerShell (una sola línea):**

```powershell
git clone https://github.com/JRVerger/obsidian-brain-kit.git $env:TEMP\obsidian-brain-kit; powershell -ExecutionPolicy Bypass -File "$env:TEMP\obsidian-brain-kit\scripts\install-remote.ps1"
```

Con ruta de vault custom:

```powershell
git clone https://github.com/JRVerger/obsidian-brain-kit.git $env:TEMP\obsidian-brain-kit; powershell -ExecutionPolicy Bypass -File "$env:TEMP\obsidian-brain-kit\scripts\install-remote.ps1" -VaultPath "D:\mis-notas"
```

> **Por qué `-ExecutionPolicy Bypass`:** Windows bloquea scripts `.ps1` por defecto. El flag lo ignora solo para este proceso, sin cambiar la política global del sistema.

> **Si el repo está privado:** el primer `git clone` abre ventana del navegador → inicia sesión con la cuenta que tiene acceso. Git Credential Manager guarda la sesión para la próxima.

## Uso manual (si ya tienes el kit local)

**Bash (Git Bash en Windows / WSL / macOS / Linux):**

```bash
mkdir -p "C:/Users/[tuuser]/Desktop/proyectos claude"
cd "C:/Users/[tuuser]/Desktop/proyectos claude"
bash "/ruta/a/obsidian-kit/scripts/bootstrap.sh" .
```

**PowerShell (Windows nativo):**

```powershell
New-Item -ItemType Directory -Path "C:\Users\[tuuser]\Desktop\proyectos claude" -Force
Set-Location "C:\Users\[tuuser]\Desktop\proyectos claude"
powershell -ExecutionPolicy Bypass -File "C:\ruta\a\obsidian-kit\scripts\bootstrap.ps1"
```

El script:
1. Crea toda la estructura de folders del vault
2. Descarga los 12 plugins desde GitHub releases
3. Escribe toda la config de Obsidian
4. Copia los 15 templates (si no existen)
5. Copia `CLAUDE.md` con marcador para rellenar
6. Copia los wiki hub files (con fecha de hoy sustituyendo `[FECHA]`)

### 3. Abre Obsidian

- "Open folder as vault" → selecciona la carpeta
- Aparecerá diálogo "Third-party plugins can run arbitrary code" → **Enable**

### 4. Personaliza CLAUDE.md

Abre `CLAUDE.md` y rellena:

- `Owner: [TU NOMBRE]`
- La tabla `## Active Projects` con los proyectos reales de **ese equipo** (el kit la deja vacía)

Todo lo demás (6 automatizaciones, hotkeys, plugins) ya está listo.

### 5. Smart Connections

La primera vez que abras el sidebar de Smart Connections te pedirá elegir modelo de embeddings:

- **Local (transformers.js, `all-MiniLM-L6-v2`)** — gratis, CPU, 384 dim. **Recomendado** para empezar.
- **Remoto (OpenAI `text-embedding-3-small`)** — mejor calidad, ~0.02$/1M tokens. Requiere API key.

### 6. Obsidian Git (opcional)

Si quieres sync del wiki a GitHub privado (útil solo si quieres sincronizar entre equipos):

- Settings → Obsidian Git → Auto commit and push interval: 10 min
- Configura remote apuntando a tu repo privado

## Estructura del kit

```
obsidian-kit/
├── README.md                           # este archivo
├── scripts/
│   ├── bootstrap.sh                    # instalador Bash
│   └── bootstrap.ps1                   # instalador PowerShell
└── seeds/
    ├── CLAUDE.md                       # CLAUDE.md genérico con 6 automatizaciones
    ├── _templates/                     # 15 templates (daily, project, etc.)
    └── wiki/
        ├── Home.md                     # hub central
        ├── hot.md                      # hot cache inicial
        ├── index.md                    # índice vacío estructurado
        ├── log.md                      # log con entrada inicial
        ├── Inbox.md                    # inbox de captura
        ├── overview.md                 # resumen ejecutivo
        ├── areas/                      # 5 areas seed (Health, Career, etc.)
        ├── goals/                      # North Star template
        └── meta/                       # 4 dashboards + kanban
```

## Cómo mantener los dos equipos alineados

Este kit es una **plantilla**, no un mecanismo de sync. Cada equipo tendrá wiki distinto porque tiene proyectos distintos. Opciones si quieres que la **config** de Obsidian se mantenga en paralelo:

1. **Version control del kit**: guarda `obsidian-kit/` en un repo privado. Cuando actualices plugins o hotkeys en un equipo, haz commit al kit, pull en el otro y re-ejecuta el script (es idempotente).
2. **Cambios manuales en paralelo**: si instalas un plugin nuevo en equipo A, edita `scripts/bootstrap.*` y `seeds/` del kit, muévelo al equipo B y re-ejecuta.

## Actualizar plugins

Re-ejecutar el script descarga la versión más reciente (`releases/latest`). Perfectamente seguro.

```bash
bash obsidian-kit/scripts/bootstrap.sh /ruta/al/vault
```

## Troubleshooting

**"Plugin X failed to load":** el `id` en `manifest.json` no coincide con el folder. El script detecta y renombra automáticamente (ejemplo: `calendar-beta` vs `calendar`).

**Templater no expande `undefined`:** Settings → Templater → Folder Templates → mapear `wiki/daily` a `_templates/daily.md`. Templater debe estar activo antes de crear la nota.

**Smart Connections vacío:** sidebar → botón "Re-index". Tarda varios minutos la primera vez.

**Queres empezar de cero:** borra `.obsidian/`, `_templates/`, `wiki/`, `CLAUDE.md`. Re-ejecuta el script.

## Requisitos

- Bash 4+ y `curl` (para `bootstrap.sh`)
- PowerShell 5.1+ (para `bootstrap.ps1`)
- Conexión a internet (para descargar plugins)
- Obsidian 1.7+
