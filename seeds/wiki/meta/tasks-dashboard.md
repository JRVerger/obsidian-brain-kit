---
type: meta
title: "Tasks Dashboard"
created: [FECHA]
updated: [FECHA]
tags:
  - meta
  - dashboard
  - tasks
status: developing
---

# Tasks Dashboard

Vista centralizada de todas las tareas pendientes.

## Pending Tasks — All

```tasks
not done
group by root
sort by priority, due
limit 50
```

## Due Today or Overdue

```tasks
not done
(due before tomorrow) OR no due date
group by filename
sort by priority
```

## High Priority

```tasks
not done
priority is above none
group by filename
sort by priority
```

## Completed Last 7 Days

```tasks
done after 7 days ago
group by done
sort by done
```

## Syntax tips

- `- [ ] task 📅 2026-05-01 ⏫ #project` (fecha + prioridad + tag)
- Prioridades: 🔺 highest · ⏫ high · 🔼 medium · 🔽 low · ⏬ lowest
- Recurrencia: `🔁 every week`
