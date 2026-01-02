---
name: api-library-authoring
description: Use this skill when creating new API feature libraries (Contracts, Handlers, Entities, Configurations) for .NET APIs with Shiny.Mediator.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# API Library Authoring

## Schnellreferenz

| Was | Wo | Beispiel |
|-----|-----|----------|
| Handler | `*.Features.X/Handlers/` | `GetItemHandler.cs` |
| Entity | `*.Features.X/Data/Entities/` | `Item.cs` |
| DI Setup | `*.Features.X/Configuration/` | `ServiceCollectionExtensions.cs` |

## 1. Projektstruktur erstellen

Für Feature `{Feature}` im Projekt `{Project}`:

```
src/Features/{Feature}/
├── {Project}.Api.Features.{Feature}/
│   ├── Configuration/ServiceCollectionExtensions.cs
│   ├── Handlers/{Action}Handler.cs
│   └── {Project}.Api.Features.{Feature}.csproj
└── {Project}.Api.Features.{Feature}.Contracts/
    ├── Mediator/Requests/{Action}Request.cs
    └── {Project}.Api.Features.{Feature}.Contracts.csproj
```

## 2. Contract Projekt (.csproj)

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="Shiny.Mediator" />
  </ItemGroup>
</Project>
```

## 3. Feature Projekt (.csproj)

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Library</OutputType>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Shiny.Extensions.DependencyInjection" />
    <PackageReference Include="Shiny.Mediator" />
    <PackageReference Include="Shiny.Mediator.AspNet" />
  </ItemGroup>
</Project>
```

## 4. ServiceCollectionExtensions

```csharp
using {Project}.Api.Core.Data;
using {Project}.Api.Features.{Feature}.Data.Configurations;
using Microsoft.Extensions.DependencyInjection;
using Shiny.Extensions.DependencyInjection;

namespace {Project}.Api.Features.{Feature}.Configuration;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection Add{Feature}Feature(this IServiceCollection services)
    {
        services.AddMediatorRegistry();
        services.AddShinyServiceRegistry();
        return services;
    }

    public static WebApplication Map{Feature}Endpoints(this WebApplication app)
    {
        app.MapGeneratedMediatorEndpoints();
        return app;
    }
}
```

## 5. Integration in Core.Startup

In `ServiceCollectionExtensions.cs`:
```csharp
services.Add{Feature}Feature();
```

In `MapEndpoints`:
```csharp
app.Map{Feature}Endpoints();
```

## 6. Solution registrieren

In `api.slnx` hinzufugen:
```xml
<Folder Name="/src/Features/{Feature}/">
  <Project Path="src/Features/{Feature}/{Project}.Api.Features.{Feature}/{Project}.Api.Features.{Feature}.csproj" />
  <Project Path="src/Features/{Feature}/{Project}.Api.Features.{Feature}.Contracts/{Project}.Api.Features.{Feature}.Contracts.csproj" />
</Folder>
```

## HTTP Attribute

| Attribut | Verwendung |
|----------|------------|
| `[MediatorHttpGet("/path")]` | GET Request |
| `[MediatorHttpPost("/path")]` | POST Request |
| `RequiresAuthorization = true` | Auth erforderlich |
| `AllowAnonymous = true` | Kein Auth |
| `OperationId = "..."` | OpenAPI Operation ID |

## Checkliste

- [ ] Contracts-Projekt erstellt
- [ ] Feature-Projekt erstellt
- [ ] `ServiceCollectionExtensions` erstellt
- [ ] In `Core.Startup` registriert
- [ ] In `.slnx` eingetragen
