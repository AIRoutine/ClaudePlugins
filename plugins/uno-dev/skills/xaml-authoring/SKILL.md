---
name: xaml-authoring
description: Use this skill when creating XAML Views, Pages, UserControls, or any UI elements for Uno Platform apps.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# XAML Authoring

## Regeln

### 1. Nutze Uno Mcp für die Umsetzung

### 2. Jedes Element MUSS einen Style haben

Keine Attributte selbst setzten. Such die Styles im Styles csproj, dort werden alle verwaltet. Immer `Style="{StaticResource ...}"` verwenden für JEDES Element. Falls es den Style den du brauchst nicht gib leg ihn an in Styles csproj.

### 3. Bei der Erstellung Page: Welche Teile der Page können in einzelne Regions gepackt werden?

Gestalte Page modular so das das Uno Region System hergenommen wird. Teile Page auf in Regions mit eigener View und ViewModel.

### 4. Bei Views/Pages: Responsive Design für alle Geräte?

Frag dich: Funktioniert dieses Layout auf Phone, Tablet und Desktop? Wenn nein, mach es responsive.
