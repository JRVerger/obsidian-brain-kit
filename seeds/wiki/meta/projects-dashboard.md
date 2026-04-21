---
type: meta
title: "Projects Dashboard"
created: [FECHA]
updated: [FECHA]
tags:
  - meta
  - dashboard
  - projects
status: developing
---

# Projects Dashboard

Vista global del portfolio.

## All Projects

```dataview
TABLE status, priority, file.mtime as "Last updated"
FROM "wiki/projects"
WHERE type = "project"
SORT priority DESC, status ASC
```

## Active (developing)

```dataview
TABLE priority, file.mtime as "Last updated"
FROM "wiki/projects"
WHERE type = "project" AND status = "developing"
SORT priority DESC
```

## Seed (decide-or-drop)

```dataview
TABLE file.mtime as "Last updated"
FROM "wiki/projects"
WHERE type = "project" AND status = "seed"
```

## Touched This Week

```dataview
TABLE file.mtime as "Modified"
FROM "wiki/projects"
WHERE file.mtime >= date(today) - dur(7 days)
SORT file.mtime DESC
```
