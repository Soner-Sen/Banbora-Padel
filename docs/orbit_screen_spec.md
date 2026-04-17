# Orbit Screen Specifications

## Screen 1: Entry / Start Screen

### Purpose
Maximal schneller Einstieg ohne Home-Screen-Ballast.

### Layout
```
┌──────────────────────────────┐
│                              │
│         ORBIT LOGO           │
│                              │
│   Spontane Padel-Sessions    │
│   Schnell. Fair.             │
│   Ohne Login.                │
│                              │
│   ┌────────────────────┐      │
│   │   Orbit starten    │      │  ← Primary CTA
│   └────────────────────┘      │
│                              │
│   ┌────────────────────┐      │
│   │  Session beitreten │      │  ← Secondary CTA
│   └────────────────────┘      │
│                              │
│   ┌────────────────────┐      │
│   │   Classic spielen  │      │  ← Tertiary CTA
│   └────────────────────┘      │
│                              │
│   Wie Orbit funktioniert     │  ← Ghost Link
│                              │
└──────────────────────────────┘
```

### State Matrix
| State | Condition | UI |
|-------|-----------|-----|
| Default | App gestartet | Alle CTAs aktiv |
| Loading | QR-Code Generierung | Orbit starten → spinner |
| Error | Netzwerkfehler | Snackbar + Retry |

### Components
- `OrbitLogoWidget` - App branding
- `ModeHeroCard` - Orbit Start CTA
- `SecondaryActionCard` - Join CTA
- `TertiaryActionCard` - Classic CTA
- `InfoLinkChip` - "Wie Orbit funktioniert"

---

## Screen 2: Session Erstellen

### Purpose
1-Screen-Setup ohne Form-Orgie.

### Layout
```
┌──────────────────────────────┐
│  ← Zurück                    │
│                              │
│  Neue Session                │
│                              │
│  Modus                       │
│  ┌──────────────────────┐    │
│  │ ◉ Orbit   ○ Classic   │    │
│  └──────────────────────┘    │
│                              │
│  Zielpunkte                  │
│  ┌────┐ ┌────┐ ┌────────┐    │
│  │ 12 │ │ 16 │ │ Eigene │    │
│  └────┘ └────┘ └────────┘    │
│                              │
│  Fairness                    │
│  ┌────────────────────┐      │
│  │ Locker │ Normal │ Strikt│ │
│  └────────────────────┘      │
│                              │
│  ┌────────────────────┐      │
│  │   Session starten  │      │
│  └────────────────────┘      │
│                              │
└──────────────────────────────┘
```

### State Matrix
| State | Condition | UI |
|-------|-----------|-----|
| Default | Keine Auswahl | Session starten disabled |
| Valid | Modus + Punkte gewählt | Session starten enabled |
| Loading | Session wird erstellt | Loading overlay |
| Error | Creation failed | Error snackbar |

### Components
- `ModeSelectorCard` - Orbit/Classic toggle
- `PointTargetSelector` - 12/16/Custom chips
- `FairnessSelector` - Locker/Normal/Strikt
- `PrimaryButton` - "Session starten"

---

## Screen 3: Lobby

### Purpose
Spieler sammeln ohne Friktion.

### Layout
```
┌──────────────────────────────┐
│  Orbit Session    ⋮ Mehr    │
├──────────────────────────────┤
│                              │
│  ┌──────────────────────┐    │
│  │                      │    │
│  │      QR CODE         │    │
│  │                      │    │
│  └──────────────────────┘    │
│                              │
│  Code: 7K4P        [Teilen]   │
│                              │
│  ─────────────────────────── │
│                              │
│  Spieler (6/4 minimum)       │
│                              │
│  ● Kim        Bereit         │
│  ● Soner      Bereit         │
│  ● Alex       Bereit         │
│  ● Mia        Bereit         │
│  ○ Lea        Wartet         │
│  ○ Tom        Wartet         │
│                              │
│  [+ Gast hinzufügen]         │
│                              │
├──────────────────────────────┤
│  ┌────────────────────┐       │
│  │   Runde starten   │       │  ← Sticky CTA
│  └────────────────────┘       │
│  Noch 2 Spieler bis Runde    │  ← Microcopy
└──────────────────────────────┘
```

### State Matrix
| State | Condition | UI |
|-------|-----------|-----|
| Empty | 0 Spieler | "Warte auf Spieler..." + QR prominent |
| Waiting | 1-3 Spieler | Teilnehmerliste + Countdown |
| Ready | 4+ Spieler | "Runde starten" enabled |
| Starting | Host startet | Loading state |
| Error | Join failed | Error banner |

### Components
- `SessionShareCard` - QR + Code
- `ShareCodeDisplay` - 4-6 Zeichen Code
- `ParticipantTile` - Avatar + Name + Status
- `ParticipantStatus` - Bereit/Wartet/OnCourt
- `GuestQuickAddSheet` - Bottom sheet für Gast
- `StartRoundButton` - Primary sticky CTA
- `PlayerCountHint` - "Noch X bis Runde"

### Host-Only Actions
- Spieler entfernen
- Session beenden
- Runde starten

---

## Screen 4: Live Court (Hero Screen)

### Purpose
Zentraler Orbit-Screen mit maximaler Lesbarkeit.

### Layout
```
┌──────────────────────────────┐
│ ← │ Orbit · Runde 3 │ Teilen ⋮│
├──────────────────────────────┤
│                              │
│         ┌────────────┐       │
│         │            │       │
│         │  A1   B1   │       │
│         │            │       │
│         │            │       │
│         │  A2   B2   │       │
│         └────────────┘       │
│                              │
│     Serve: Soner → diagonal  │
│                              │
│  ┌────────────────────────┐  │
│  │   Team A    8 : 6   Team B│ │
│  └────────────────────────┘  │
│                              │
├──────────────────────────────┤
│                              │
│  Wartet: Lea • Tom           │
│  Nächste: Lea + Kim vs       │
│          Soner + Tom         │
│  ┌────────────────────────