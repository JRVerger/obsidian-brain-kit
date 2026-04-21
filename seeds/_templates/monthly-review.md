---
type: review
title: "Month <% tp.date.now('YYYY-MM') %>"
created: <% tp.date.now('YYYY-MM-DD') %>
updated: <% tp.date.now('YYYY-MM-DD') %>
tags:
  - review
  - monthly
status: developing
---

# Monthly Review — <% tp.date.now('MMMM YYYY') %>

> <% tp.date.now('D MMM YYYY', -30) %> → <% tp.date.now('D MMM YYYY') %>

## Highlights

What were the biggest wins this month?
- <% tp.file.cursor() %>

## Theme
> One sentence that captures this month.

## Projects Shipped / Progress

| Project | Status Start | Status End | Key Changes |
|---------|--------------|------------|-------------|
| [[Aura]] | | | |
| [[Inky AI Tattoo Manager]] | | | |
| [[Tattoo Desk]] | | | |
| [[Reestructuracion Webs]] | | | |

## Goals Progress

- [[North Star]]: on track / off track / blocked — why?

## What I Learned This Month

Top 3 learnings:
1.
2.
3.

## People & Network
- Conversations worth remembering:
- New connections:

## Books / Courses / Sources Ingested
```dataview
LIST FROM "wiki/sources" OR "wiki/resources"
WHERE date(created) >= date("<% tp.date.now('YYYY-MM-DD', -30) %>")
SORT created DESC
```

## Numbers

| Metric | Value | vs Last Month |
|--------|-------|---------------|
| Daily notes | | |
| New concepts | | |
| New projects | | |
| Wiki pages total | | |

## What's Not Working

Honest inventory — what needs to change?
-

## Next Month Focus

Top 3 priorities:
1.
2.
3.

## Weekly Reviews This Month
```dataview
LIST FROM "wiki/weekly"
WHERE date(created) >= date("<% tp.date.now('YYYY-MM-DD', -30) %>")
SORT created ASC
```

## Links
- Previous: [[<% tp.date.now('YYYY-MM', 0, tp.date.now('YYYY-MM-DD', -30), 'YYYY-MM-DD') %>]]
- Quarterly: [[<% tp.date.now('YYYY-[Q]Q') %>]]
