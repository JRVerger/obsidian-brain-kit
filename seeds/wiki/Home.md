---
type: hub
title: "Home"
created: [FECHA]
updated: [FECHA]
tags:
  - hub
status: developing
---

# Home

Central hub del segundo cerebro.

## Inicio rapido

- [[Inbox]] — captura rapida (pendiente de procesar)
- [[hot]] — contexto reciente
- [[index]] — catalogo completo de paginas
- [[log]] — historial cronologico de operaciones
- [[overview]] — resumen ejecutivo

## Active Focus

> Tareas activas de la semana

- [ ] (vacio — llenar al arrancar)

## Navegacion

### Areas
- [[Health]] · [[Career]] · [[Finances]] · [[Creative]] · [[Learning]]

### Goals
- [[North Star]]

### Projects
```dataview
LIST FROM "wiki/projects"
WHERE type = "project"
SORT priority DESC, status ASC
LIMIT 15
```

### Reviews
- Weekly: `wiki/weekly/`
- Monthly: `wiki/monthly/`
- Quarterly: `wiki/quarterly/`

### MOCs
- (los MOCs se crean a medida que nace cada dominio)

### Dashboards
- [[tasks-dashboard]]
- [[projects-dashboard]]
- [[learning-dashboard]]
- [[projects-board]] (kanban)

## Atajos de Teclado

| Atajo | Accion |
|-------|--------|
| Mod+Alt+D/W/M/Q | Daily / Weekly / Monthly / Quarterly note |
| Mod+J | QuickAdd (captura rapida) |
| Mod+Shift+F | Omnisearch |
| Mod+Shift+S | Smart Connections |
| Mod+Shift+C | Calendar |
| Mod+O | Quick Switcher |
| Mod+Shift+P | Command Palette |
