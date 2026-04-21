---
type: review
title: "Quarter <% tp.date.now('YYYY-[Q]Q') %>"
created: <% tp.date.now('YYYY-MM-DD') %>
updated: <% tp.date.now('YYYY-MM-DD') %>
tags:
  - review
  - quarterly
status: developing
---

# Quarterly Review — <% tp.date.now('YYYY-[Q]Q') %>

> <% tp.date.now('D MMM YYYY', -90) %> → <% tp.date.now('D MMM YYYY') %>

## Executive Summary

Three sentences about this quarter:
1.
2.
3.

## North Star Alignment
- [[North Star]] — did this quarter's work move it forward?

## Big Wins
- <% tp.file.cursor() %>

## Big Misses
- What didn't happen that should have?

## Projects Portfolio

| Project | Status Q Start | Status Q End | Shipped? |
|---------|---------------|--------------|----------|
| [[Aura]] | | | |
| [[Inky AI Tattoo Manager]] | | | |
| [[Tattoo Desk]] | | | |
| [[Reestructuracion Webs]] | | | |
| [[Puzzle Deslizante]] | | | |
| [[Xiaozhi ESP32]] | | | |
| [[Museo Virtual]] | | | |
| [[Tocadiscos]] | | | |
| [[App Lista de Difusion]] | | | |
| [[Test Capacidades HBDI]] | | | |

## Identity / Skills Growth
- What am I better at now than 90 days ago?

## Relationships
- Investments that paid off:
- People to re-engage:

## Money / Career
- Income sources:
- Career moves:

## Health / Energy
- Physical:
- Mental:
- Sleep/routine:

## Pivots
What changed my mind this quarter?

## Looking Ahead

**Next quarter theme:**

**Top 3 outcomes (specific, measurable):**
1.
2.
3.

**Weekly targets to hit those:**
-

## Links
- Monthly reviews in Q:
```dataview
LIST FROM "wiki/monthly"
WHERE date(created) >= date("<% tp.date.now('YYYY-MM-DD', -90) %>")
SORT created ASC
```
