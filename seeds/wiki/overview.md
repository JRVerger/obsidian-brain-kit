---
type: meta
title: "Wiki Overview"
created: [FECHA]
updated: [FECHA]
tags:
  - meta
  - overview
status: developing
---

# Wiki Overview

Resumen ejecutivo del vault. Actualiza tras cada weekly review.

## Stats

```dataview
TABLE length(rows) as Count
FROM "wiki"
GROUP BY type
SORT length(rows) DESC
```

## Active Areas

- [[Health]]
- [[Career]]
- [[Finances]]
- [[Creative]]
- [[Learning]]

## North Star

Ver [[North Star]].

## Recent Activity

```dataview
TABLE file.mtime as Updated, type, status
FROM "wiki"
WHERE file.mtime >= date(today) - dur(7 days)
SORT file.mtime DESC
LIMIT 20
```

## Health Indicators

- Daily notes hábito: ver `wiki/daily/`
- Inbox procesado esta semana: ver [[Inbox]]
- Proyectos activos: ver [[projects-dashboard]]
- Lint status: ver último lint report en `wiki/meta/`
