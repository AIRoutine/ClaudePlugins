---
name: entity-authoring
description: Use this skill when creating or editing Entity Framework Core entities and their configurations for .NET APIs.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Entity Authoring

## Schnellreferenz

| Was | Wo | Beispiel |
|-----|-----|----------|
| BaseEntity | `*.Core.Data/Entities/` | `BaseEntity.cs` |
| Feature Entity | `*.Features.X/Data/Entities/` | `Item.cs` |
| Configuration | `*.Features.X/Data/Configurations/` | `ItemConfiguration.cs` |

## 1. BaseEntity (bereits vorhanden)

Alle Entities erben von `BaseEntity`:

```csharp
public abstract class BaseEntity
{
    public Guid Id { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? UpdatedAt { get; set; }
}
```

> Timestamps werden automatisch vom `AppDbContext` verwaltet.

## 2. Entity erstellen

**Pfad:** `Features/{Feature}/{Project}.Api.Features.{Feature}/Data/Entities/{EntityName}.cs`

### Einfache Entity

```csharp
using {Project}.Api.Core.Data.Entities;

namespace {Project}.Api.Features.{Feature}.Data.Entities;

public class {EntityName} : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}
```

### Entity mit Beziehung

```csharp
using {Project}.Api.Core.Data.Entities;

namespace {Project}.Api.Features.{Feature}.Data.Entities;

public class {EntityName} : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    // Foreign Key
    public Guid CategoryId { get; set; }

    // Navigation Property
    public Category Category { get; set; } = null!;
}
```

### Entity mit Collection

```csharp
public class Category : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    // One-to-Many
    public ICollection<Item> Items { get; set; } = [];
}
```

## 3. Entity Configuration erstellen

**Pfad:** `Features/{Feature}/{Project}.Api.Features.{Feature}/Data/Configurations/{EntityName}Configuration.cs`

```csharp
using {Project}.Api.Features.{Feature}.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace {Project}.Api.Features.{Feature}.Data.Configurations;

public class {EntityName}Configuration : IEntityTypeConfiguration<{EntityName}>
{
    public void Configure(EntityTypeBuilder<{EntityName}> builder)
    {
        // Tabelle
        builder.ToTable("{EntityName}s");

        // Primary Key
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("{EntityName}Id");

        // Properties
        builder.Property(x => x.Name)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(x => x.Description)
            .HasMaxLength(1000);

        // Indices
        builder.HasIndex(x => x.Name).IsUnique();
    }
}
```

### Configuration mit Beziehung

```csharp
public class ItemConfiguration : IEntityTypeConfiguration<Item>
{
    public void Configure(EntityTypeBuilder<Item> builder)
    {
        builder.ToTable("Items");

        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("ItemId");

        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();

        // Relationship
        builder.HasOne(x => x.Category)
            .WithMany(x => x.Items)
            .HasForeignKey(x => x.CategoryId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

## 4. Configuration registrieren

In `Features/{Feature}/Configuration/ServiceCollectionExtensions.cs`:

```csharp
using {Project}.Api.Core.Data;
using {Project}.Api.Features.{Feature}.Data.Configurations;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection Add{Feature}Feature(this IServiceCollection services)
    {
        // Entity Configurations registrieren
        AppDbContext.RegisterConfigurations(typeof({EntityName}Configuration).Assembly);

        services.AddMediatorRegistry();
        services.AddShinyServiceRegistry();
        return services;
    }
}
```

## 5. Entity im Handler verwenden

```csharp
[MediatorScoped]
public class Create{EntityName}Handler(AppDbContext data)
    : IRequestHandler<Create{EntityName}Request, {EntityName}Response>
{
    public async Task<{EntityName}Response> Handle(
        Create{EntityName}Request request,
        IMediatorContext context,
        CancellationToken ct)
    {
        var entity = new {EntityName}
        {
            Id = Guid.NewGuid(),
            Name = request.Name
        };

        data.Set<{EntityName}>().Add(entity);
        await data.SaveChangesAsync(ct);

        return new {EntityName}Response(entity.Id, entity.Name);
    }
}
```

## Property-Typen Referenz

| C# Typ | EF Config | SQL Typ |
|--------|-----------|---------|
| `string` | `.HasMaxLength(n)` | `nvarchar(n)` |
| `string?` | `.HasMaxLength(n)` | `nvarchar(n) NULL` |
| `int` | - | `int` |
| `decimal` | `.HasPrecision(18, 2)` | `decimal(18,2)` |
| `bool` | - | `bit` |
| `DateTimeOffset` | - | `datetimeoffset` |
| `Guid` | - | `uniqueidentifier` |
| `byte[]` | `.HasMaxLength(n)` | `varbinary(n)` |

## Beziehungstypen

| Beziehung | Entity | Configuration |
|-----------|--------|---------------|
| One-to-Many | `ICollection<T>` | `.HasMany().WithOne()` |
| Many-to-One | `T` + `Guid TId` | `.HasOne().WithMany()` |
| One-to-One | `T` + `Guid TId` | `.HasOne().WithOne()` |

## Delete Behavior

| Verhalten | Verwendung |
|-----------|------------|
| `Cascade` | Child löschen wenn Parent gelöscht wird |
| `Restrict` | Löschen verbieten wenn Children existieren |
| `SetNull` | FK auf NULL setzen (FK muss nullable sein) |
| `NoAction` | Keine automatische Aktion |

## Checkliste

- [ ] Entity erbt von `BaseEntity`
- [ ] Entity in `Data/Entities/` Ordner
- [ ] Configuration implementiert `IEntityTypeConfiguration<T>`
- [ ] Configuration in `Data/Configurations/` Ordner
- [ ] Tabellen- und Spaltennames explizit gesetzt
- [ ] MaxLength für alle Strings definiert
- [ ] Indices für häufig gesuchte Felder
- [ ] Beziehungen mit DeleteBehavior konfiguriert
- [ ] Configuration Assembly in `ServiceCollectionExtensions` registriert
