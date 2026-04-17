# Widget Inventory

## Design System Komponenten

### Buttons

#### PrimaryButton
- **Verwendung:** Hauptaktionen (Orbit starten, Runde starten)
- **States:** Default, Pressed, Disabled, Loading
- **Spezifikation:**
  - Height: 56px
  - Border-Radius: 18px
  - Background: orbitPrimary
  - Text: orbitOnPrimary, labelLarge

#### SecondaryButton  
- **Verwendung:** Wichtige aber nicht dominante Aktionen (Session beitreten)
- **States:** Default, Pressed, Disabled
- **Spezifikation:**
  - Height: 56px
  - Border-Radius: 18px
  - Background: elevated
  - Border: 1px orbitPrimary/20%
  - Text: textPrimary

#### GhostButton
- **Verwendung:** Unterstützende Aktionen (Regeln, Später)
- **States:** Default, Pressed
- **Spezifikation:**
  - Kein Background
  - Text: orbitPrimary oder textSecondary
  - Font: labelLarge

#### ScoreButton
- **Verwendung:** Punktzählung im Live Court
- **States:** Default, Pressed, Disabled
- **Spezifikation:**
  - Height: 64px (minimum)
  - Width: Equal split 50/50
  - Border-Radius: 24px (unten)
  - Farbe: Team A = orbitPrimary, Team B = accentAmber
  - Text: "Punkt für Team A/B", bold

---

### Cards

#### OrbitHeroCard
- **Verwendung:** Start Screen Orbit CTA
- **Props:** title, subtitle, onTap
- **Spezifikation:**
  - Padding: 20px
  - Border-Radius: 24px
  - Background: surface mit Gradient-Akzent
  - Hover/Press: elevated

#### SessionShareCard
- **Verwendung:** QR-Code und Code-Anzeige in der Lobby
- **Props:** qrCode, sessionCode, onShare
- **Spezifikation:**
  - QR-Size: 180x180px
  - Code: 4-6 Zeichen, monospace
  - Padding: 16px

#### ModeChip
- **Verwendung:** Modus-Auswahl (Orbit/Classic/Chaos)
- **Props:** mode, status, isSelected
- **States:** Available, Selected, Disabled
- **Spezifikation:**
  - Border-Radius: pill
  - Padding: 8px 16px
  - Mode-spezifische Farben

#### PointTargetChip
- **Verwendung:** Zielpunkte-Auswahl (12/16/Custom)
- **Props:** points, isSelected, onTap
- **States:** Default, Selected
- **Spezifikation:**
  - Border-Radius: 14px
  - Min-Width: 56px

---

### Player Components

#### PlayerAvatar
- **Verwendung:** Spieler-Indikator an Positionen
- **Props:** name, avatarUrl, team, position, isServing
- **States:** Active, Waiting, Bench, Serving
- **Spezifikation:**
  - Size: 48px (Court), 40px (Bench)
  - Border: 3px solid (Team-Farbe)
  - Ring-Style: solid (Team A), dashed (Team B)
  - Initialen wenn kein Avatar

#### PlayerAvatarChip
- **Verwendung:** Kompakte Spieler-Darstellung in Listen
- **Props:** name, status, team
- **Spezifikation:**
  - Height: 40px
  - Border-Radius: pill
  - Avatar + Name + Status-Badge

#### ParticipantTile
- **Verwendung:** Spieler in der Lobby-Liste
- **Props:** name, avatarUrl, status, isHost, onRemove
- **States:** Ready, Waiting, OnCourt
- **Spezifikation:**
  - Height: 56px
  - Leading: PlayerAvatar
  - Title: Name
  - Trailing: Status Badge
  - Optional: Remove-Button (Host only)

#### ParticipantStatus
- **Verwendung:** Status-Badge für Spieler
- **Props:** status
- **States:** Ready (grün), Waiting (amber), OnCourt (cyan)
- **Spezifikation:**
  - Border-Radius: pill
  - Font: labelSmall

---

### Court Components

#### CourtView
- **Verwendung:** Top-down Court-Visualisierung
- **Props:** teamAPlayers, teamBPlayers, servePosition, score
- **Spezifikation:**
  - Aspect-Ratio: ~1.5:1
  - Court-Farbe: courtBase (#0F6D64)
  - Linien: courtLine (#DCE7F5)
  - Netz: courtNet (#94A3B8)
  - 4 Spieler-Positionen mit Team-Markierung

#### CourtPlayerSlot
- **Verwendung:** Einzelne Position auf dem Court
- **Props:** player, team, isServing, isReturning
- **Spezifikation:**
  - Size: 56x56px
  - Team-Ring: solid (A) / dashed (B)
  - Serve-Marker: Pulsing dot
  - Return-Marker: Kleinere, gestrichelte Position

#### ServeIndicator
- **Verwendung:** Anzeige wer serviert
- **Props:** serverName, side (left/right)
- **Spezifikation:**
  - Position: Unter dem Court
  - Icon: Tennisball + Pfeil
  - Text: "Serve: {Name}"

---

### Queue & Rotation

#### BenchRail
- **Verwendung:** Horizontale Anzeige wartender Spieler
- **Props:** players, order
- **Spezifikation:**
  - Horizontal scroll
  - PlayerAvatar mit Name
  - Pfeil zur nächsten Runde

#### NextUpCard
- **Verwendung:** Vorschau der nächsten Runde
- **Props:** teamA, teamB, reasons
- **Spezifikation:**
  - Zeigt nächste 4 Spieler
  - Team A / Team B Aufteilung
  - Fairness-Hinweise

#### WhyThisPairingBanner
- **Verwendung:** Erklärung der Rotation
- **Props:** reasons (List)
- **Mögliche Reasons:**
  - Neue Partnerkombination
  - Bench fair ausgeglichen
  - Direktes Rematch vermieden
- **Spezifikation:**
  - Background: elevated
  - Icon + Text pro Reason
  - Border-Radius: 14px

---

### Score Components

#### ScoreBar
- **Verwendung:** Haupt-Score-Anzeige
- **Props:** teamAScore, teamBScore, targetScore
- **Spezifikation:**
  - Team A links, Team B rechts
  - Score: 36px, tabular figures
  - Team-Labels: 14px
  - ": " als Separator

#### ScoreButtonBar
- **Verwendung:** Sticky Bottom Bar für Scoring
- **Props:** onScoreA, onScoreB, onUndo, canUndo
- **Spezifikation:**
  - Fixed bottom
  - 2 große Buttons (50/50 split)
  - Undo-Button darunter (kleiner)
  - Safe-Area aware

---

### Navigation

#### SessionAppBar
- **Verwendung:** Top Navigation während Session
- **Props:** mode, roundNumber, onBack, onShare, onMore
- **Spezifikation:**
  - Height: 56px
  - Leading: Back/Leave
  - Title: "Orbit · Runde X"
  - Trailing: Share, More

#### BottomSheetHandle
- **Verwendung:** Grabber für Bottom Sheets
- **Spezifikation:**
  - Width: 40px
  - Height: 4px
  - Color: textMuted
  - Border-Radius: 2px

---

### Feedback & States

#### InlineInfoBanner
- **Verwendung:** Kontextbezogene Hinweise
- **Props:** message, type (info/success/warning/error), icon
- **Spezifikation:**
  - Border-Radius: 12px
  - Icon links
  - Text: bodyMedium
  - Type-spezifische Farben

#### LoadingIndicator
- **Verwendung:** Ladezustände
- **Props:** message
- **Spezifikation:**
  - CircularProgressIndicator in orbitPrimary
  - Optionaler Text darunter

#### EmptyStateWidget
- **Verwendung:** Leere Zustände
- **Props:** icon, title, subtitle, action
- **Spezifikation:**
  - Zentriert
  - Icon: 64px
  - Title: headlineSmall
  - Subtitle: bodyMedium

#### ErrorStateWidget
- **Verwendung:** Fehlerzustände
- **Props:** message, onRetry
- **Spezifikation:**
  - Error-Icon
  - Fehlermeldung
  - Retry-Button

---

### Forms

#### AppTextField
- **Verwendung:** Texteingabe
- **Props:** label, hint, controller, validator
- **States:** Default, Focused, Error, Disabled
- **Spezifikation:**
  - Height: 56px
  - Border-Radius: 14px
  - Background: elevated
  - Label: bodySmall über dem Field

#### GuestQuickAddSheet
- **Verwendung:** Schnell Gast hinzufügen
- **Props:** onAdd
- **Spezifikation:**
  - Bottom Sheet
  - TextField für Name
  - Optional: Farbauswahl
  - PrimaryButton "Hinzufügen"

---

### Modals

#### ConfirmationDialog
- **Verwendung:** Bestätigungsanfragen
-