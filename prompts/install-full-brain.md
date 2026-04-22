# Prompt maestro: instalar el "segundo cerebro" Obsidian en este equipo

Copia y pega el siguiente prompt completo (todo lo que hay dentro de la caja) en una sesión nueva de Claude Code dentro del equipo donde quieras instalar el cerebro. Claude Code hará todo el trabajo: diagnóstico, instalación, configuración, scaffold de proyectos, y te preguntará las 2-3 cosas que solo tú puedes decidir.

---

## Copia a partir de aquí ↓

Eres un asistente que va a instalar y configurar un "segundo cerebro" Obsidian completo en este equipo, usando el kit del repositorio `https://github.com/JRVerger/obsidian-brain-kit`. Trabaja metódicamente, diagnostica antes de actuar, y **nunca borres** carpetas que contengan código de proyectos sin confirmación explícita.

## Objetivo

Dejar este equipo con:
- Obsidian configurado con 12 plugins (Dataview, Templater, Obsidian Git, Periodic Notes, Calendar, Tasks, QuickAdd, Natural Language Dates, Omnisearch, Advanced Tables, Kanban, Smart Connections)
- Core plugins ajustados, hotkeys globales alineadas, CSS snippet activo
- 15 templates en `_templates/` (daily, weekly, monthly, quarterly, project, concept, learning, debug, adr, meeting, question, resource, source, entity, goal)
- Wiki estructurado: `Home.md`, `hot.md`, `index.md`, `log.md`, `Inbox.md`, `overview.md`, 5 areas, North Star, 4 dashboards, kanban board
- `CLAUDE.md` con 6 automatizaciones activas (auto daily note, auto research, auto learning capture, auto lint, auto project ingest, auto daily briefing)
- Una nota `.md` en `wiki/projects/` por cada carpeta de proyecto que haya en la raíz del vault

## Constraints críticos (no los violes)

1. **Windows PowerShell 5.1** como intérprete objetivo. Evita caracteres no-ASCII en los scripts que generes o ejecutes (em-dashes, comillas tipográficas, acentos en comentarios) — rompen el parser.
2. **Nunca borres** carpetas que no sean explícitamente del vault (`.obsidian/`, `wiki/`, `_templates/`, `CLAUDE.md`, `.raw/`, `.archive/`, `.attachments/`, `.trash/`, `.gitignore`). Las demás son carpetas de proyectos del usuario — **intocables**.
3. **OneDrive con cuidado**: si la ruta del vault contiene `OneDrive\`, advierte al usuario y ofrece una ruta fuera de OneDrive (p.ej. `C:\proyectos_claude`) como alternativa recomendada.
4. **Ejecuta scripts PowerShell con `powershell -ExecutionPolicy Bypass -File ...`**, no con `&`.
5. Todo idempotente — no sobreescribe archivos que ya existan.

## Plan de trabajo

Ejecuta estos pasos en orden. Reporta al usuario cada paso completado y pide confirmación solo cuando las decisiones lo requieran.

### Paso 1 — Pregunta inicial

Pregunta al usuario **la ruta del vault**. Ejemplos válidos: `C:\proyectos_claude`, `D:\brain`, `C:\Users\[usuario]\Documents\vault`.

Recomienda rutas **fuera de OneDrive** para evitar conflictos de sincronización. Si el usuario propone una ruta dentro de OneDrive, advierte del riesgo pero respeta la decisión.

### Paso 2 — Verificaciones previas

Comprueba y reporta:
- `git --version` (requerido)
- `powershell -Command "Get-Host | Select-Object Version"` (detecta PS 5.1 o 7+)
- Si la ruta del vault existe, lista qué hay dentro con `Get-ChildItem -Force`

Si no hay git, detente y pide al usuario que lo instale (`https://git-scm.com/download/win`).

### Paso 3 — Clonar el kit

Clona el repositorio en `$env:TEMP\obsidian-brain-kit`. Si ya existe, hace `git pull` en lugar de clonar:

```powershell
if (Test-Path "$env:TEMP\obsidian-brain-kit\.git") {
    cd "$env:TEMP\obsidian-brain-kit"
    git pull --quiet
} else {
    git clone --quiet https://github.com/JRVerger/obsidian-brain-kit.git $env:TEMP\obsidian-brain-kit
}
```

**Si el clone falla con `Repository not found`**, el repo es privado y la cuenta GitHub autenticada en este equipo no tiene acceso. Opciones:
- Recomendar al usuario hacer el repo público si no tiene datos sensibles
- Invitar la cuenta actual como collaborator
- Hacer logout del GCM y autenticar con la cuenta que sí tiene acceso: `git credential-manager erase` y reintentar

### Paso 4 — Crear vault si no existe

```powershell
New-Item -ItemType Directory -Path "[VAULT_PATH]" -Force
```

### Paso 5 — Ejecutar bootstrap

```powershell
powershell -ExecutionPolicy Bypass -File "$env:TEMP\obsidian-brain-kit\scripts\install-remote.ps1" -VaultPath "[VAULT_PATH]"
```

Este script:
- Descarga 12 plugins desde GitHub releases
- Escribe `.obsidian/` completo (config, plugins enabled, hotkeys, appearance, graph)
- Configura cada plugin con `data.json`
- Crea CSS snippet de folder colors
- Copia `_templates/` + `CLAUDE.md` + wiki hub files (sustituyendo `[FECHA]` con hoy)

Si PS 5.1 se queja de **Execution Policy** a pesar del `-Bypass`, usa:
```powershell
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$env:TEMP\obsidian-brain-kit\scripts\install-remote.ps1`" -VaultPath `"[VAULT_PATH]`"" -Wait
```

### Paso 6 — Scaffold de proyectos

Si hay carpetas con código en la raíz del vault (detéctalas — ignora `.obsidian`, `wiki`, `_templates`, `docs`, `scripts`, `.git`, `node_modules`, etc.):

```powershell
powershell -ExecutionPolicy Bypass -File "$env:TEMP\obsidian-brain-kit\scripts\scaffold-projects.ps1" -VaultPath "[VAULT_PATH]"
```

Este script infiere el stack de cada proyecto (Flutter, Next.js, Astro, ESP-IDF, Rust, Python, etc.) y crea `wiki/projects/[NombreCarpeta].md` con frontmatter + scaffold de secciones.

### Paso 7 — Personalizar CLAUDE.md

Lee `[VAULT_PATH]\CLAUDE.md` y **edítalo** para rellenar:
- `Owner: [TU NOMBRE]` — pregunta al usuario
- Tabla `## Active Projects` — usa los nombres de carpeta detectados en el paso 6 e infiere el stack. Ejemplo:
  ```markdown
  | Project | Path | Stack |
  |---------|------|-------|
  | mi-app-flutter | mi-app-flutter/ | Flutter |
  | mi-api-nest | mi-api-nest/ | NestJS + TypeScript |
  ```
- Fecha `Created: [FECHA DE SETUP]` — reemplaza con fecha ISO de hoy

### Paso 8 — Verificación

Ejecuta y muestra al usuario:
- `Get-ChildItem "[VAULT_PATH]\.obsidian\plugins"` — deben aparecer 12 carpetas
- `Get-ChildItem "[VAULT_PATH]\wiki\projects" -Name` — una nota por proyecto
- `Get-ChildItem "[VAULT_PATH]\_templates" -Name` — 15 templates
- Contenido de `[VAULT_PATH]\CLAUDE.md` frontmatter — confirmar Owner y Active Projects

### Paso 9 — Instrucciones finales al usuario

Muéstrale este checklist (los 3 pasos que no puedes hacer tú por ser UI):

1. Abrir Obsidian → **File → Open folder as vault** → seleccionar `[VAULT_PATH]`
2. Diálogo "Third-party plugins can run arbitrary code" → **Enable**
3. En **Smart Connections** (sidebar derecho, al primer uso): elegir modelo de embeddings:
   - **Local transformers.js (`all-MiniLM-L6-v2`)** — gratis, recomendado para empezar
   - **OpenAI `text-embedding-3-small`** — mejor calidad, requiere API key

## Flujo continuo que el usuario puede usar después

Para añadir un proyecto nuevo:
```powershell
powershell -ExecutionPolicy Bypass -File "$env:TEMP\obsidian-brain-kit\scripts\scaffold-projects.ps1" -VaultPath "[VAULT_PATH]"
```

Para actualizar el kit cuando cambien plugins/templates:
```powershell
cd $env:TEMP\obsidian-brain-kit
git pull
powershell -ExecutionPolicy Bypass -File ".\scripts\install-remote.ps1" -VaultPath "[VAULT_PATH]"
```

## Troubleshooting conocido

| Síntoma | Causa | Fix |
|---|---|---|
| `Falta el terminador "` al parsear un `.ps1` | PS 5.1 + UTF-8 sin BOM + carácter no-ASCII | Edita el .ps1 eliminando em-dashes/acentos, o reescribe con BOM |
| `Plugin X failed to load` | id en manifest difiere del nombre del folder | El script ya renombra automáticamente; si persiste, comprueba manualmente |
| `Repository not found` al clonar | Repo privado + cuenta sin acceso | Ver Paso 3 |
| Smart Connections vacío tras abrir | No se ha indexado aún | Sidebar → botón Re-index (tarda ~5 min) |
| Templater no expande `undefined` | Templater no activo antes de crear nota | Settings → Templater → Folder Templates: mapear `wiki/daily` a `_templates/daily.md` |
| Graph view con nodos huérfanos | Wikilinks en templates hardcoded a proyectos inexistentes | Edita `_templates/*-review.md` y quita filas que no apliquen |

## Éxito = cumplir TODOS estos criterios

- [ ] Carpeta vault creada con 23+ subcarpetas (wiki/, _templates/, .obsidian/, etc.)
- [ ] 12 plugins en `.obsidian/plugins/` con `manifest.json`, `main.js`, `styles.css` y `data.json`
- [ ] `community-plugins.json` lista los 12
- [ ] 15 templates en `_templates/` sin placeholders `undefined` rotos
- [ ] `CLAUDE.md` con Owner y Active Projects rellenos
- [ ] Una nota por proyecto en `wiki/projects/`
- [ ] Graph view tras abrir Obsidian muestra Home conectado con North Star, areas, proyectos, dashboards
- [ ] Usuario confirma que ve los proyectos y sus relaciones

## Reporta al final

Cuando termines, resume al usuario:
- Qué se instaló (12 plugins, 15 templates, N proyectos scaffolded)
- Qué tiene que hacer él (los 3 clics UI)
- 3 próximos pasos sugeridos para arrancar el hábito (primera daily note, primer weekly review el viernes, primera semana capturando learnings)

## Copia hasta aquí ↑

---

## Cómo usar este prompt

1. Abre Claude Code en el equipo donde quieras instalar el cerebro
2. Pega el bloque entre las líneas de "Copia a partir de aquí ↓" y "Copia hasta aquí ↑"
3. Responde las preguntas que te haga (ruta del vault, Owner, confirmar proyectos detectados)
4. Espera a que termine (~3 minutos con buena conexión)
5. Haz los 3 clics finales en Obsidian

El prompt es autocontenido: no necesitas pasarle contexto previo, no necesitas el repo clonado antes, no necesitas preparar nada. Solo pegar.

## Mantenimiento

Si en el futuro el kit crece (más plugins, nuevos templates, automatizaciones nuevas), este prompt se actualiza en el repo y puedes consultar la versión más reciente en:

`https://github.com/JRVerger/obsidian-brain-kit/blob/main/prompts/install-full-brain.md`
