---
name: mediator-authoring
description: Use this skill when creating Commands, Events, or Requests with Shiny.Mediator in Uno.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Mediator Authoring

## Regeln

### 1. Immer Contract UND Handler erstellen

- **Contract** in `*.Contracts` Projekt
- **Handler** in `*.Features.*\Mediator\Requests\`

### 2. Wann welchen Typ verwenden

- **Event** (`IEvent`): State-Änderungen broadcasten (1:N)
- **Command** (`ICommand`): für Aktionen ohne Antwort (1:1)
- **Request** (`IRequest<T>`): Abfrage mit Antwort (1:1)

### 3. Beispiel Command

**Contract:**
```csharp
public record SyncDataCommand(Guid UserId) : Shiny.Mediator.ICommand;
```

**Handler:**
```csharp
public sealed class SyncDataHandler : Shiny.Mediator.ICommandHandler<SyncDataCommand>
{
    public Task Handle(SyncDataCommand command, IMediatorContext context, CancellationToken cancellationToken)
    {
        // Sync durchführen
        return Task.CompletedTask;
    }
}
```

### 4. Beispiel Request

**Contract:**
```csharp
public record GetUserProfileRequest(Guid UserId) : IRequest<UserProfileResponse>;
public record UserProfileResponse(string Name, string Email)
{
    public static UserProfileResponse Empty { get; } = new(string.Empty, string.Empty);
}
```

**Handler:**
```csharp
public sealed class GetUserProfileHandler : IRequestHandler<GetUserProfileRequest, UserProfileResponse>
{
    public Task<UserProfileResponse> Handle(GetUserProfileRequest request, IMediatorContext context, CancellationToken cancellationToken)
    {
        return Task.FromResult(new UserProfileResponse("Max", "max@example.com"));
    }
}
```

### 5. Beispiel Event

**Contract:**
```csharp
public record UserLoggedInEvent(Guid UserId, string Email) : IEvent;
```

**Handler (im ViewModel):**
```csharp
public partial class DashboardViewModel : PageViewModel, IEventHandler<UserLoggedInEvent>
{
    public Task Handle(UserLoggedInEvent @event, IMediatorContext context, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
```
