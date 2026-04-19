# Padel 4 Modes Implementation Plan

## User Requirements (Confirmed Answers)

| Question | Answer |
|----------|--------|
| Americano scalability | Scalable 4-10 players - Fun team mode for quick rounds where everyone plays with and against everyone. Individual performance counts. |
| Normal mode | Official Padel Rules with counting (standard scoring) |
| Liga results | Session-based only (display only, no persistence) |
| Chaos Rally frequency | Configurable every 2, 3, or 4 points |
| Welcome screen | Replace current layout with mode selection |

---

## Phase 1: Americano ✅ COMPLETE

### Architecture Decisions
- Feature-first organization: `lib/features/americano/`
- Shared rotation algorithm moved to `lib/core/game_engine/`
- Clean Architecture: data/domain/presentation layers
- Cubit for state management

### Files Created

#### Core Game Engine
```
lib/core/game_engine/
├── domain/
│   ├── entities/
│   │   ├── game_mode_type.dart     # Enum: americano, liga, normal, chaosRally
│   │   ├── game_player.dart       # Shared player entity
│   │   ├── game_team.dart         # Team with 2 players
│   │   └── game_entities.dart      # Barrel file
│   └── usecases/
│       ├── fair_rotation_algorithm.dart  # Reusable rotation logic
│       └── game_engine.dart        # Barrel file
└── game_engine.dart                # Module barrel
```

#### Americano Feature
```
lib/features/americano/
├── domain/
│   └── entities/
│       ├── americano_participant.dart  # Player with stats
│       ├── americano_match.dart        # Single match
│       ├── americano_session.dart     # Full session
│       ├── americano_leaderboard.dart # Leaderboard
│       └── entities.dart              # Barrel
├── presentation/
│   ├── cubit/
│   │   ├── americano_cubit.dart  # State management
│   │   ├── americano_state.dart  # State classes
│   │   └── cubit.dart           # Barrel
│   ├── screens/
│   │   ├── americano_lobby_screen.dart    # Player selection, target config
│   │   ├── americano_session_screen.dart   # Score tracking, rotation
│   │   ├── americano_leaderboard_screen.dart
│   │   └── screens.dart
│   └── presentation.dart         # Barrel
└── americano.dart                  # Feature barrel
```

### Key Features Implemented
- ✅ Player selection (4-10 players) with avatar picker
- ✅ Target score presets (10, 12, 13, 16) + custom numeric input
- ✅ Fair rotation algorithm for team pairing
- ✅ Score tracking with tap-to-score UI
- ✅ Match completion with winner display
- ✅ Leaderboard sorted by points
- ✅ Info BottomSheet with rules
- ✅ AppBar with info icon on all screens

---

## Phase 2: Liga (Next)

### Differences from Americano
- Win-based ranking (wins count more than points)
- Draws are possible (both teams can "win")
- Same rotation system
- Leaderboard: wins primary, points secondary

### Implementation Notes
- Reuse `FairRotationAlgorithm` from core
- New `LigaLeaderboard` with win tracking
- Update `LeaderboardEntry` to track wins

---

## Phase 3: Normal

### Features
- Standard Padel match (4 players, 2 teams)
- Official Padel scoring rules
- Configurable target score
- No rotation (fixed teams)

### Implementation Notes
- Simpler than Americano/Liga (no rotation needed)
- Standard Padel score logic (points, games, sets)
- 2-player team selection screen

---

## Phase 4: Chaos Rally

### Challenge System Design

#### Challenge Types
1. **Mild** (more frequent)
   - Weak hand only
   - No lobs
   - Must hit between knees and shoulders
   - Ball must bounce before crossing net

2. **Medium** (less frequent)
   - No racket (hands only)
   - Only body parts (no racket)
   - Ball may bounce twice
   - Play with opposite hand

3. **Extreme** (rare)
   - Both players on same side
   - Play with eyes closed
   - No talking

#### Challenge Trigger System
- Configurable frequency: every 2, 3, or 4 points
- Random challenge selection from appropriate difficulty pool
- Clear display when challenge activates
- Visual indicator during challenge

#### UI Requirements
- Challenge banner at top of court view
- Challenge countdown/indicator
- Challenge completion animation
- Challenge history (last 3-5 challenges)

---

## Mode Selection Screen

Replaced welcome screen with beautiful 2x2 grid layout:

```
┌─────────────────────────────────┐
│         Padel App              │
│    Wähle deinen Spielmodus     │
├───────────────┬─────────────────┤
│   Americano   │      Liga       │
│   ⭐ Punkte   │   🏆 Gewinne    │
│    (info)    │     (info)      │
├───────────────┼─────────────────┤
│    Normal     │   Chaos Rally   │
│   🎾 Klassik │    🎲 Spaß      │
│    (info)    │     (info)      │
└───────────────┴─────────────────┘
```

Each mode card shows:
- Mode-specific icon with color
- Title
- Subtitle
- Info button → BottomSheet with rules

---

## Implementation Status

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Americano | ✅ COMPLETE | Fully functional |
| Phase 2: Liga | ⏳ PENDING | Reuse Americano, modify leaderboard |
| Phase 3: Normal | ⏳ PENDING | Standard match, no rotation |
| Phase 4: Chaos Rally | ⏳ PENDING | Challenge system |

---

## Design System Usage

All screens use the established design system:
- `AppColors.primary` - emerald for Americano
- `AppColors.teamB` - amber for Liga
- `AppSpacing` - 8pt scale
- `AppRadius` - rounded corners
- `AppElevation` - soft shadows
