---
name: uno-development
description: Use this skill when developing Uno Platform cross-platform apps, creating XAML UI, implementing MVUX patterns, configuring Material themes, or working with .NET MAUI embedding. Activates for tasks involving WinUI, responsive layouts, platform-specific code, or Uno Toolkit controls.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Uno Platform Development

## Instructions

When working on Uno Platform projects, follow these guidelines:

### Project Structure
- Main app project: `*.csproj` with `Uno.Sdk`
- Shared code in the main project or shared library
- Platform-specific code using `#if` directives or partial classes

### XAML Best Practices
- Use `x:Uid` for localization on all user-visible text
- Prefer Material theme resources over hardcoded colors
- Use `AutoLayout` from Uno Toolkit for responsive layouts
- Never use hardcoded hex colors - always use theme resources

### Data Binding
- Use MVUX with `IState<T>` and `IListState<T>` for reactive state
- Binding from `bool` to `Visibility` is implicit (no converter needed)
- Never use `{Binding StringFormat=...}` - use multiple `<Run>` elements instead

### Styling
- Define custom styles in `App.xaml` or dedicated resource dictionaries
- Prefer existing TextBlock styles over explicit FontSize/FontWeight
- Use ThemeShadow with Translation Z for elevation effects

### Commands & Actions
- Use `CommandExtensions` from Uno Toolkit for button commands
- Never use `AppBarButton` outside of `CommandBar`

### Running the App
- Build: `dotnet build`
- Run with Hot Reload: Set `DOTNET_MODIFIABLE_ASSEMBLIES=debug` then `dotnet run`
- Target frameworks: `net9.0-desktop`, `net9.0-browserwasm`, `net9.0-ios`, `net9.0-android`

## Examples

### Responsive Grid with Material Theme
```xml
<Page xmlns:utu="using:Uno.Toolkit.UI">
    <Grid utu:AutoLayout.PrimaryAxisAlignment="Center"
          Padding="16">
        <TextBlock Text="Hello Uno"
                   Style="{StaticResource HeadlineMedium}" />
    </Grid>
</Page>
```

### MVUX State Management
```csharp
public partial record MainModel
{
    public IState<string> Name => State.Value(this, () => "");
    public IListState<Item> Items => ListState.Empty(this, () => default(Item));
}
```
