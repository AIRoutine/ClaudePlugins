# Development Workflow

Analysiere das Feature/die Änderung: $ARGUMENTS

## 1. Backend oder Frontend?

Entscheide: Braucht es Änderungen im...
- [ ] Backend (API/Handler)
- [ ] Frontend (UI/ViewModel)
- [ ] Beides

## 2. Library-Analyse

- Welche Library/Projekt ist betroffen?
- Muss eine neue Library verwendet werden?

## 3. Backend-Änderungen

Falls Backend betroffen:
- Braucht es einen neuen Handler?
- Muss ein bestehender Handler aktualisiert werden?

→ Falls ja: Nutze den **api-endpoint-authoring** Skill

## 4. Frontend: View/Page

Falls Frontend betroffen:
- Muss eine bestehende Page/View geändert werden?
- Muss eine neue Page/View erstellt werden?

→ Falls ja: Nutze den **xaml-authoring** Skill

## 5. Frontend: ViewModel

- Muss ein bestehendes ViewModel geändert werden?
- Muss ein neues ViewModel erstellt werden?

→ Falls ja: Nutze den **viewmodel-authoring** Skill

## 6. Mediator-Pattern

Analysiere was vom Shiny.Mediator Pattern gebraucht wird:
- Events (State-Änderungen broadcasten)
- Commands (Aktionen ohne Antwort)
- Requests (Abfragen mit Antwort)

→ Falls relevant: Nutze den **mediator-authoring** Skill
