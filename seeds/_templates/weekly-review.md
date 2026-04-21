---
type: review
title: "Week <% tp.date.now('YYYY-[W]ww') %>"
created: <% tp.date.now('YYYY-MM-DD') %>
updated: <% tp.date.now('YYYY-MM-DD') %>
tags:
  - review
  - weekly
status: developing
---

# Weekly Review — <% tp.date.now('YYYY-[W]ww') %>

> <% tp.date.now('D MMM', -6) %> → <% tp.date.now('D MMM YYYY') %>

## Wins
- <% tp.file.cursor() %>

## Challenges
-

## Projects Update

| Project | Progress This Week | Next Week |
|---------|-------------------|-----------|
| [[Aura]] | | |
| [[Inky AI Tattoo Manager]] | | |
| [[Tattoo Desk]] | | |
| [[Reestructuracion Webs]] | | |

## What I Learned
-

## Goals Check
- [[North Star]] alignment:

## Inbox Processing
- [ ] Process .raw/ sources
- [ ] Update wiki pages touched this week
- [ ] Review and link recent notes
- [ ] Archive completed items

## Next Week Priorities
1.
2.
3.

## Daily Notes This Week
```dataview
LIST FROM "wiki/daily"
WHERE date(created) >= date("<% tp.date.now('YYYY-MM-DD', -6) %>")
SORT created ASC
```
