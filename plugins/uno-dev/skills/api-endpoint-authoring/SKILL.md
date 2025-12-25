---
name: api-endpoint-authoring
description: Use this skill when creating API endpoints with Shiny.Mediator.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# API Endpoint Authoring

## Regeln

### 1. Immer Contract UND Handler erstellen

- **Contract** in `*.Contracts` Projekt (Request/Command + Response)
- **Handler** in `*.Handlers` Projekt

### 2. Request vs Command

- `IRequest<TResult>` für Abfragen mit Antwort
- `ICommand` für Aktionen ohne Antwort

### 3. Handler Attribute

- `[MediatorScoped]` auf jeder Handler-Klasse
- `[MediatorHttpPost("/path")]` oder `[MediatorHttpGet("/path")]` für HTTP

### 4. Beispiel Request

**Contract:**
```csharp
public record GetItemRequest(Guid Id) : IRequest<ItemResponse>;
public record ItemResponse(Guid Id, string Name);
```

**Handler:**
```csharp
[MediatorScoped]
public class GetItemHandler(AppDbContext db) : IRequestHandler<GetItemRequest, ItemResponse>
{
    [MediatorHttpGet("/items/{Id}", OperationId = "GetItem")]
    public async Task<ItemResponse> Handle(GetItemRequest request, IMediatorContext context, CancellationToken ct)
    {
        var item = await db.Items.FindAsync([request.Id], ct);
        return new ItemResponse(item.Id, item.Name);
    }
}
```

### 5. Beispiel Command

**Contract:**
```csharp
public record DeleteItemCommand(Guid Id) : ICommand;
```

**Handler:**
```csharp
[MediatorScoped]
public class DeleteItemHandler(AppDbContext db) : ICommandHandler<DeleteItemCommand>
{
    [MediatorHttpPost("/items/{Id}/delete", OperationId = "DeleteItem", RequiresAuthorization = true)]
    public async Task Handle(DeleteItemCommand command, IMediatorContext context, CancellationToken ct)
    {
        await db.Items.Where(x => x.Id == command.Id).ExecuteDeleteAsync(ct);
    }
}
```

### 6. Stream Request (SSE)

**Contract:**
```csharp
public record TickerStreamRequest(string Symbol) : IStreamRequest<TickerResult>;
public record TickerResult(decimal Price, DateTime Timestamp);
```

**Handler:**
```csharp
[MediatorScoped]
public class TickerStreamHandler : IStreamRequestHandler<TickerStreamRequest, TickerResult>
{
    public async IAsyncEnumerable<TickerResult> Handle(TickerStreamRequest request, IMediatorContext context, [EnumeratorCancellation] CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            yield return new TickerResult(123.45m, DateTime.UtcNow);
            await Task.Delay(1000, ct);
        }
    }
}
```

**Endpoint:**
```csharp
app.MapGet("/sse", ([FromServices] IMediator mediator, [FromServices] IHttpContextAccessor context, [AsParameters] TickerStreamRequest request)
    => mediator.RequestServerSentEvents(request, context));
```

### 7. Event Stream (SSE)

```csharp
public record PriceChangedEvent(string Symbol, decimal Price) : IEvent;

app.MapGet("/subscribe", ([FromServices] IMediator mediator, [FromServices] IHttpContextAccessor context)
    => mediator.EventStreamToServerSentEvents<PriceChangedEvent>(context));
```
