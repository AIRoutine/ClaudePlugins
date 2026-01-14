---
name: navigation
description: Use this skill when implementing navigation in Uno Platform apps - covers Frame, Region, NavigationView, and TabBar patterns.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Navigation in Uno Platform

## Wichtigste Erkenntnis

**NIEMALS `Region.Attached="True"` in Shell.xaml oder ExtendedSplashScreen verwenden!**

Der Navigation Host ist waehrend der Shell-Konstruktion noch nicht bereit. Regions muessen auf echten Pages (z.B. `MainPage`) definiert werden.

## Navigations-Typen

### 1. Content-Based Navigation

Verwendet Content-Bereich zum Anzeigen der aktuellen View.

| Control | Verhalten |
|---------|-----------|
| **ContentControl** | Navigation erstellt Instanz und setzt als Content |
| **Panel (Grid)** | Setzt Child auf Visible, versteckt vorheriges |
| **Frame** | Stack-basiert: Forward fuegt hinzu, Back entfernt |

### 2. Selection-Based Navigation

Hat selektierbare Items.

| Control | Verhalten |
|---------|-----------|
| **NavigationView** | Selektiert NavigationViewItem mit passendem Region.Name |
| **TabBar** | Selektiert TabBarItem mit passendem Region.Name |

### 3. Prompt-Based (Modal)

Modaler Stil, typischerweise fuer User-Input.

| Control | Verhalten |
|---------|-----------|
| **ContentDialog** | Forward oeffnet, Backward schliesst |
| **Flyout/Popup** | Forward oeffnet, Backward schliesst |

## Wann welche Navigation verwenden?

### Frame Navigation
- **Wann:** Klassische Seiten-Navigation mit Back-Stack
- **Beispiel:** Wizard, Detail-Seiten von Listen
- Verwendet `Frame.Navigate()` oder `INavigator.NavigateViewModelAsync()`

### Region Navigation mit Visibility
- **Wann:** Tabs, Sidebar-Navigation, Content-Bereiche die nebeneinander existieren
- **Beispiel:** NavigationView mit mehreren Seiten, TabBar
- Verwendet `Region.Navigator="Visibility"` - schaltet Visibility der Child-Elemente

### Region Navigation mit ContentControl
- **Wann:** Dynamisch geladene Inhalte, Regionen die Views nachladen
- **Beispiel:** Shell mit wechselndem Hauptinhalt
- Page implementiert `IContentControlProvider`

## Korrekte App-Struktur

### Falsch (Navigation funktioniert nicht)

```
Shell.xaml (mit Region.Attached="True" und NavigationView)
  -> Nested Routes direkt in Shell
```

### Richtig (Navigation funktioniert)

```
Shell.xaml (nur ContentControl Container)
  -> MainPage.xaml (mit Region.Attached="True" und NavigationView)
     -> Nested Routes unter MainPage
```

## Code-Beispiele

### App.xaml.cs - Route Registration

```csharp
private static void RegisterRoutes(IViewRegistry views, IRouteRegistry routes)
{
    views.Register(
        new ViewMap(ViewModel: typeof(ShellViewModel)),
        new ViewMap<MainPage, MainViewModel>(),
        new ViewMap<ProductsPage, ProductsViewModel>(),
        new ViewMap<SettingsPage, SettingsViewModel>()
    );

    routes.Register(
        new RouteMap("", View: views.FindByViewModel<ShellViewModel>(),
            Nested:
            [
                // MainPage hostet die NavigationView
                new RouteMap("Main", View: views.FindByViewModel<MainViewModel>(),
                    Nested:
                    [
                        new("Products", View: views.FindByViewModel<ProductsViewModel>(), IsDefault: true),
                        new("Settings", View: views.FindByViewModel<SettingsViewModel>())
                    ]
                )
            ]
        )
    );
}
```

### Shell.xaml - Nur Container

```xml
<UserControl x:Class="MyApp.Presentation.Shell"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">

    <Grid Background="{ThemeResource BackgroundBrush}">
        <!-- Nur ContentControl - KEINE Region.Attached hier! -->
        <ContentControl x:Name="NavigationContent"
                        HorizontalAlignment="Stretch"
                        VerticalAlignment="Stretch"
                        HorizontalContentAlignment="Stretch"
                        VerticalContentAlignment="Stretch" />
    </Grid>
</UserControl>
```

### Shell.xaml.cs

```csharp
public sealed partial class Shell : UserControl, IContentControlProvider
{
    public ContentControl ContentControl => NavigationContent;

    public Shell()
    {
        this.InitializeComponent();
    }
}
```

### MainPage.xaml - Mit NavigationView

```xml
<Page x:Class="MyApp.Presentation.MainPage"
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:uen="using:Uno.Extensions.Navigation.UI"
      xmlns:muxc="using:Microsoft.UI.Xaml.Controls"
      Background="{ThemeResource BackgroundBrush}">

    <!-- Aeusseres Grid mit Region.Attached -->
    <Grid uen:Region.Attached="True">

        <muxc:NavigationView x:Name="NavView"
                             uen:Region.Attached="True"
                             PaneDisplayMode="LeftCompact"
                             IsBackButtonVisible="Collapsed"
                             IsSettingsVisible="False">
            <muxc:NavigationView.MenuItems>
                <!-- Region.Name muss mit Route-Namen uebereinstimmen -->
                <muxc:NavigationViewItem Content="Products" uen:Region.Name="Products">
                    <muxc:NavigationViewItem.Icon>
                        <FontIcon Glyph="&#xE7BF;" />
                    </muxc:NavigationViewItem.Icon>
                </muxc:NavigationViewItem>
                <muxc:NavigationViewItem Content="Settings" uen:Region.Name="Settings">
                    <muxc:NavigationViewItem.Icon>
                        <FontIcon Glyph="&#xE713;" />
                    </muxc:NavigationViewItem.Icon>
                </muxc:NavigationViewItem>
            </muxc:NavigationView.MenuItems>

            <muxc:NavigationView.Content>
                <!-- Content Grid mit Visibility Navigator -->
                <Grid uen:Region.Attached="True"
                      uen:Region.Navigator="Visibility">
                    <ContentControl x:Name="NavigationContent"
                                    HorizontalAlignment="Stretch"
                                    VerticalAlignment="Stretch"
                                    HorizontalContentAlignment="Stretch"
                                    VerticalContentAlignment="Stretch" />
                </Grid>
            </muxc:NavigationView.Content>
        </muxc:NavigationView>

    </Grid>
</Page>
```

### MainPage.xaml.cs

```csharp
public sealed partial class MainPage : Page, IContentControlProvider
{
    public ContentControl ContentControl => NavigationContent;

    public MainPage()
    {
        this.InitializeComponent();
    }
}
```

### ShellViewModel - Start Navigation

```csharp
public class ShellViewModel
{
    private readonly INavigator _navigator;

    public ShellViewModel(INavigator navigator)
    {
        _navigator = navigator;
    }

    public async Task Start()
    {
        // Navigiere zu MainViewModel beim Start
        await _navigator.NavigateViewModelAsync<MainViewModel>(this);
    }
}
```

## TabBar Alternative

Fuer Bottom-Navigation auf Mobile:

```xml
<Grid uen:Region.Attached="True">
    <Grid.RowDefinitions>
        <RowDefinition Height="*" />
        <RowDefinition Height="Auto" />
    </Grid.RowDefinitions>

    <!-- Content Area -->
    <Grid uen:Region.Attached="True"
          uen:Region.Navigator="Visibility" />

    <!-- TabBar -->
    <utu:TabBar Grid.Row="1"
                uen:Region.Attached="True"
                Style="{StaticResource BottomTabBarStyle}">
        <utu:TabBarItem Content="Home" uen:Region.Name="Home">
            <utu:TabBarItem.Icon>
                <FontIcon Glyph="&#xE80F;" />
            </utu:TabBarItem.Icon>
        </utu:TabBarItem>
        <utu:TabBarItem Content="Search" uen:Region.Name="Search">
            <utu:TabBarItem.Icon>
                <FontIcon Glyph="&#xE721;" />
            </utu:TabBarItem.Icon>
        </utu:TabBarItem>
    </utu:TabBar>
</Grid>
```

## Responsive Navigation Shell

Kombiniere NavigationView (Desktop) mit TabBar (Mobile):

```xml
<!-- Desktop: NavigationView sichtbar -->
<muxc:NavigationView Visibility="{utu:Responsive Normal=Collapsed, Wide=Visible}"
                     uen:Region.Attached="True">
    ...
</muxc:NavigationView>

<!-- Mobile: TabBar sichtbar -->
<utu:TabBar Visibility="{utu:Responsive Normal=Visible, Wide=Collapsed}"
            uen:Region.Attached="True">
    ...
</utu:TabBar>
```

## Checkliste bei Navigation-Problemen

1. [ ] `Region.Attached="True"` NICHT in Shell.xaml?
2. [ ] Route-Namen stimmen mit `Region.Name` ueberein?
3. [ ] `IContentControlProvider` implementiert?
4. [ ] Nested Routes korrekt verschachtelt in `RegisterRoutes`?
5. [ ] ShellViewModel navigiert zu MainViewModel beim Start?
6. [ ] Content Grid hat `Region.Navigator="Visibility"`?

## Haeufige Fehler

### Navigation reagiert nicht auf Klicks
- **Ursache:** `Region.Attached` in Shell.xaml
- **Loesung:** NavigationView in MainPage verschieben

### Default-Route wird nicht geladen
- **Ursache:** `IsDefault: true` fehlt
- **Loesung:** Bei nested routes die Default-Route markieren

### Content wird nicht angezeigt
- **Ursache:** `IContentControlProvider` nicht implementiert
- **Loesung:** Page muss Interface implementieren und ContentControl exposen

## Referenzen

- [Navigation Design](https://platform.uno/docs/articles/external/uno.extensions/doc/Reference/Navigation/Design.html)
- [Define Regions](https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Navigation/Walkthrough/DefineRegions.html)
- [Define Routes](https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Navigation/Walkthrough/DefineRoutes.html)
- [Creating a Responsive Navigation Shell](https://platform.uno/docs/articles/external/uno.chefs/doc/toolkit/NavigationShell.html)
