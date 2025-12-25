---
name: viewmodel-authoring
description: Use this skill when creating ViewModels for Uno Platform apps.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# ViewModel Authoring

## Regeln

### 1. Immer die richtige Basisklasse verwenden

- Für Pages: `PageViewModel`
- Für Regions/Controls: `RegionViewModel`

```csharp
public partial class MyPageViewModel(BaseServices baseServices) : PageViewModel(baseServices);
public partial class MyRegionViewModel(BaseServices baseServices) : RegionViewModel(baseServices);
```

### 2. Für Commands immer `[UnoCommand]` verwenden

Niemals manuell ICommand/RelayCommand erstellen. Immer das `[UnoCommand]` Attribut:

```csharp
[UnoCommand]
private async Task SaveAsync() { }

[UnoCommand(Busy = BusyMode.Local, BusyMessage = "Saving...")]
private async Task SaveWithBusyAsync() { }
```
