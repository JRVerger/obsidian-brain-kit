---
type: meta
title: "Learning Dashboard"
created: [FECHA]
updated: [FECHA]
tags:
  - meta
  - dashboard
  - learning
status: developing
---

# Learning Dashboard

Vista de concepts, learnings, resources y questions.

## Recent Learnings (last 30 days)

```dataview
TABLE file.mtime as "Captured", related_project as Project
FROM "wiki/learning"
WHERE type = "learning" AND file.mtime >= date(today) - dur(30 days)
SORT file.mtime DESC
```

## Top Linked Concepts

```dataview
TABLE length(file.inlinks) as Inlinks
FROM "wiki/concepts"
WHERE type = "concept"
SORT length(file.inlinks) DESC
LIMIT 10
```

## Orphan Concepts (no inbound links)

```dataview
LIST
FROM "wiki/concepts"
WHERE type = "concept" AND length(file.inlinks) = 0
```

## Open Questions

```dataview
LIST
FROM "wiki/questions"
WHERE type = "question" AND status != "answered"
SORT file.ctime DESC
```
