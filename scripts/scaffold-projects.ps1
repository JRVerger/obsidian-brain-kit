# Scaffold de notas de proyecto en wiki/projects/
# Detecta carpetas del vault root e infiere el stack por los archivos
# clave que contengan (package.json, pubspec.yaml, CMakeLists.txt, etc.).
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\scripts\scaffold-projects.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\scaffold-projects.ps1 -VaultPath "C:\ruta\al\vault"
#
# Idempotente: no sobreescribe notas de proyecto que ya existan.

param(
    [string]$VaultPath = (Get-Location).Path,
    [string[]]$ExtraExcludes = @()
)

$ErrorActionPreference = "Stop"
Set-Location $VaultPath

$projectsDir = Join-Path $VaultPath "wiki\projects"
if (-not (Test-Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir -Force | Out-Null
}

$today = (Get-Date).ToString("yyyy-MM-dd")

# Carpetas que NO son proyectos
$excluded = @(
    ".obsidian", ".raw", ".archive", ".attachments", ".git", ".trash",
    "wiki", "_templates", "docs", "scripts", "obsidian-kit",
    "node_modules", ".next", ".turbo", "build", "dist",
    ".dart_tool", ".gradle", ".vscode", ".idea", "out", "bin", "obj"
) + $ExtraExcludes

function Get-ProjectStack {
    param([string]$ProjectPath)

    $stack = [PSCustomObject]@{
        Primary = "Unknown"
        Tags    = New-Object System.Collections.ArrayList
    }

    $files = Get-ChildItem -Path $ProjectPath -Force -ErrorAction SilentlyContinue
    $fileNames = @($files | Select-Object -ExpandProperty Name)

    function Has {
        param([string[]]$Names, [string]$Pattern)
        return ($Names | Where-Object { $_ -like $Pattern }).Count -gt 0
    }

    # Node / JS / TS ecosystem
    if ($fileNames -contains "package.json") {
        [void]$stack.Tags.Add("javascript")
        if (Has $fileNames "tsconfig*") { [void]$stack.Tags.Add("typescript") }

        if ($fileNames -contains "app.json" -and ($fileNames -contains "eas.json" -or (Has $fileNames "app.config*"))) {
            $stack.Primary = "Expo / React Native"
            [void]$stack.Tags.AddRange(@("expo", "react-native", "mobile"))
        } elseif (Has $fileNames "next.config*") {
            $stack.Primary = "Next.js"
            [void]$stack.Tags.AddRange(@("next", "react", "web"))
        } elseif (Has $fileNames "astro.config*") {
            $stack.Primary = "Astro"
            [void]$stack.Tags.AddRange(@("astro", "web"))
        } elseif (Has $fileNames "nuxt.config*") {
            $stack.Primary = "Nuxt"
            [void]$stack.Tags.AddRange(@("nuxt", "vue", "web"))
        } elseif ($fileNames -contains "nest-cli.json") {
            $stack.Primary = "NestJS"
            [void]$stack.Tags.AddRange(@("nest", "backend"))
        } elseif (Has $fileNames "svelte.config*") {
            $stack.Primary = "Svelte / SvelteKit"
            [void]$stack.Tags.AddRange(@("svelte", "web"))
        } elseif (Has $fileNames "vite.config*") {
            $stack.Primary = "Vite"
            [void]$stack.Tags.AddRange(@("vite", "web"))
        } else {
            $stack.Primary = "Node.js"
        }
    }
    # Flutter / Dart
    elseif ($fileNames -contains "pubspec.yaml") {
        $stack.Primary = "Flutter"
        [void]$stack.Tags.AddRange(@("flutter", "dart", "mobile"))
    }
    # ESP32 / ESP-IDF
    elseif ($fileNames -contains "CMakeLists.txt") {
        if (Has $fileNames "sdkconfig*") {
            $stack.Primary = "ESP-IDF (ESP32)"
            [void]$stack.Tags.AddRange(@("esp32", "embedded", "cpp"))
        } else {
            $stack.Primary = "C/C++ (CMake)"
            [void]$stack.Tags.AddRange(@("cpp", "cmake"))
        }
    }
    # Arduino
    elseif (Has $fileNames "*.ino") {
        $stack.Primary = "Arduino"
        [void]$stack.Tags.AddRange(@("arduino", "embedded"))
    }
    # Rust
    elseif ($fileNames -contains "Cargo.toml") {
        $stack.Primary = "Rust"
        [void]$stack.Tags.Add("rust")
    }
    # Go
    elseif ($fileNames -contains "go.mod") {
        $stack.Primary = "Go"
        [void]$stack.Tags.Add("go")
    }
    # Python
    elseif ($fileNames -contains "pyproject.toml" -or $fileNames -contains "requirements.txt" -or $fileNames -contains "setup.py") {
        $stack.Primary = "Python"
        [void]$stack.Tags.Add("python")
        if ($fileNames -contains "manage.py") { [void]$stack.Tags.Add("django") }
        if (Has $fileNames "*.ipynb") { [void]$stack.Tags.Add("jupyter") }
    }
    # Ruby
    elseif ($fileNames -contains "Gemfile") {
        $stack.Primary = "Ruby"
        [void]$stack.Tags.Add("ruby")
    }
    # PHP
    elseif ($fileNames -contains "composer.json") {
        $stack.Primary = "PHP"
        [void]$stack.Tags.Add("php")
    }
    # C# / .NET
    elseif ((Has $fileNames "*.csproj") -or (Has $fileNames "*.sln")) {
        $stack.Primary = "C# / .NET"
        [void]$stack.Tags.AddRange(@("dotnet", "csharp"))
    }
    # Java / Gradle / Maven
    elseif ($fileNames -contains "build.gradle" -or $fileNames -contains "build.gradle.kts" -or $fileNames -contains "pom.xml") {
        $stack.Primary = "Java / JVM"
        [void]$stack.Tags.Add("java")
    }
    # Swift / Xcode
    elseif ((Has $fileNames "*.xcodeproj") -or (Has $fileNames "*.xcworkspace") -or ($fileNames -contains "Package.swift")) {
        $stack.Primary = "Swift / Xcode"
        [void]$stack.Tags.AddRange(@("swift", "ios"))
    }
    # Static HTML
    elseif (Has $fileNames "*.html") {
        $stack.Primary = "Static HTML"
        [void]$stack.Tags.AddRange(@("web", "html"))
    }
    # Mood board / assets
    elseif ((Has $fileNames "*.png") -or (Has $fileNames "*.jpg") -or (Has $fileNames "*.avif") -or (Has $fileNames "*.webp")) {
        $stack.Primary = "Assets / Mood board"
        [void]$stack.Tags.AddRange(@("assets", "mood-board"))
    }

    return $stack
}

$template = @'
---
type: project
title: "__NOTENAME__"
created: __TODAY__
updated: __TODAY__
tags:
__TAGS_YAML__
status: seed
path: "__FOLDER__/"
stack: "__STACK__"
related: []
sources: []
priority: medium
---

# __NOTENAME__

Descripcion breve del proyecto (completar).

## Que Hace

## Arquitectura

```
(diagrama opcional)
```

## Tech Stack

Detectado automaticamente: **__STACK__**

| Capa | Tecnologia |
|------|------------|
|  |  |

## Estado

Seed - recien scaffolded por scaffold-projects.ps1. Completar manualmente.

## Siguiente Hito

- [ ] Completar "Que Hace" con 1-2 frases
- [ ] Documentar arquitectura real
- [ ] Anadir entry point y como ejecutar

## Related Knowledge

```dataview
LIST FROM "wiki/concepts" OR "wiki/sources"
WHERE contains(file.outlinks, this.file.link) OR contains(this.file.outlinks, file.link)
SORT file.name ASC
```

## Recent Learnings

```dataview
LIST FROM "wiki" WHERE type = "learning" AND contains(related_project, "__NOTENAME__")
SORT created DESC LIMIT 5
```
'@

# ---------------------------------------------------------------------
# Scanear carpetas
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "=== Scaffold de Proyectos ===" -ForegroundColor Cyan
Write-Host "Vault: $VaultPath" -ForegroundColor DarkGray
Write-Host ""

$folders = Get-ChildItem -Path $VaultPath -Directory -Force |
    Where-Object { $excluded -notcontains $_.Name }

if ($folders.Count -eq 0) {
    Write-Host "No se encontraron carpetas candidatas." -ForegroundColor Yellow
    exit 0
}

Write-Host "Carpetas candidatas: $($folders.Count)" -ForegroundColor Yellow
Write-Host ""

$created = 0
$skipped = 0

foreach ($folder in $folders) {
    $noteName = $folder.Name -replace '[<>:"/\\|?*]', '_'
    $notePath = Join-Path $projectsDir "$noteName.md"

    if (Test-Path $notePath) {
        Write-Host "  = $noteName (ya existe)" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    $stack = Get-ProjectStack -ProjectPath $folder.FullName
    $allTags = @($stack.Tags) + @("project") | Sort-Object -Unique
    $tagsYaml = ($allTags | ForEach-Object { "  - $_" }) -join "`n"

    $content = $template `
        -replace '__NOTENAME__', $noteName `
        -replace '__TODAY__', $today `
        -replace '__TAGS_YAML__', $tagsYaml `
        -replace '__FOLDER__', $folder.Name `
        -replace '__STACK__', $stack.Primary

    $content | Out-File -Encoding utf8 -FilePath $notePath
    Write-Host "  + $noteName ($($stack.Primary))" -ForegroundColor Green
    $created++
}

Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan
Write-Host "  Creadas:  $created" -ForegroundColor Green
Write-Host "  Saltadas: $skipped (ya existian)" -ForegroundColor DarkGray
Write-Host ""

if ($created -gt 0) {
    Write-Host "Siguiente paso:" -ForegroundColor Yellow
    Write-Host "  1. Abre Obsidian y revisa wiki/projects/"
    Write-Host "  2. Completa 'Que Hace' y tabla de Tech Stack en cada nota"
    Write-Host "  3. Re-abre Graph View - los proyectos apareceran como nodos"
}
