---
name: store-authoring
description: Use this skill when creating persistent state with Shiny Stores.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Store Authoring

## Pattern

```csharp
[Reflector]  // Required for AOT
public partial class UserSettings : ObservableObject
{
    [ObservableProperty]
    private string _theme = "dark";

    [ObservableProperty]
    private bool _notificationsEnabled = true;
}
```

## Registration

```csharp
services.AddPersistentService<UserSettings>("secure");
```

## Store Aliases

| Alias | Backend |
|-------|---------|
| `settings` | Native Preferences (default) |
| `secure` | Secure Storage |
| `session` | Session Storage (WASM) |
| `Memory` | In-Memory (testing) |

## Injection

```csharp
public class MyViewModel(UserSettings settings)
{
    // Properties auto-persist on change
    settings.Theme = "light";
}
```
