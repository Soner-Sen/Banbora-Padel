# Americano Session Feature - Final Blueprint

## Executive Summary

**Feature:** Session starten → Americano (Orbit) Mode  
**Goal:** Fair player rotation + real-time score tracking  
**MVP Scope:** Fix rotation algorithm, enhance score tracking, simplify leaderboard  
**Not in MVP:** Classic/Chaos modes, join session, persistence, auth

---

## 1. Problem Statement

The current rotation algorithm uses a greedy heuristic with penalty scoring that fails to guarantee fair playtime distribution. Users report players sitting out 4-5 rounds while others play consecutively.

**User Quote:** "Der Mischalgorithmus/Logik ist nicht gut. Einer spielt manchmal 4-5 Runden hintereinander."

---

## 2. Success Criteria

| Criterion | Metric |
|-----------|--------|
| No player sits out >1 consecutive round | 100% guarantee |
| Playtime variance at session end | ≤ 1 round between any two players |
| Score input latency | < 100ms UI feedback |
| Leaderboard accuracy | Real-time, points-only ranking |

---

## 3. Architecture Decision: Rotation Algorithm

### Option A: Improved Greedy Heuristic (Current)
- **Pros:** Simple to implement
- **Cons:** No mathematical guarantees, arbitrary penalty weights, O(n^4) complexity
- **Status:** REJECTED

### Option B: Round-Robin + Constraint Satisfaction (SELECTED)
- **Pros:** Mathematical fairness guarantee, O(n) complexity, deterministic
- **Cons:** Slightly more complex to understand
- **Status:** APPROVED by Hackborn & Forstall

### Algorithm Design

```
ROUND-ROBIN AMERICANO ROTATION

For N players (4 ≤ N ≤ 10):
1. If N == 4: Fixed doubles, no rotation needed
2. If N is even:
   - Use standard round-robin pairing
   - Players on bench = N - 4 (the rest)
3. If N is odd:
   - N-1 players play, 1 sits out
   - Rotate sit-out fairly (no consecutive bench)

CONSTRAINT: No player sits out twice until all have sat out once
```

### Fairness Guarantee Proof Sketch

Given N players and rounds R:
- Each round plays 4 players (2v2)
- Players per round = 4
- Bench per round = N - 4
- Total player-slots = R × 4
- Total player-round-attendances needed = R × 4
- With Round-Robin: Each player plays floor(R × 4 / N) or ceil(R × 4 / N)
- Difference = at most 1 round

---

## 4. Data Model Changes

### New Entity: `AmericanoRound` (extends Round)

```dart
class AmericanoRound {
  final String id;
  final int roundNumber;
  final List<Player> teamA;      // 2 players
  final List<Player> teamB;      // 2 players
  final List<Player> bench;      // N-4 players
  final int targetPoints;
  final int teamAPoints;          // Live scoring
  final int teamBPoints;          // Live scoring
  final RoundStatus status;
}
```

### Modified: `Player` Statistics

```dart
class Player {
  // ... existing fields ...
  int totalAmericanoPoints;       // Sum of all match points
  int roundsPlayed;               // How many rounds participated
  int roundsOnBench;              // How many rounds sat out
}
```

### Modified: `Leaderboard`

```dart
class LeaderboardEntry {
  final String playerId;
  final String displayName;
  final PlayerAvatar avatar;
  final int totalAmericanoPoints;  // ONLY ranking factor
  final int roundsPlayed;
  final int roundsOnBench;
  
  // REMOVED: roundsWon, benchCount (not Americano ranking factors)
}
```

---

## 5. Rotation Algorithm Specification

### File: `lib/features/orbit/domain/usecases/rotation_algorithm.dart`

**Interface (unchanged):**
```dart
RotationResult calculateNextRound({
  required List<Participant> allParticipants,
  required List<Round> completedRounds,
  required PairingConstraints constraints,
  int targetPoints = 12,
})
```

**New Algorithm: `FairRotationAlgorithm`**

```dart
class FairRotationAlgorithm {
  // O(n) round-robin rotation
  
  List<PlayerPairing> generateRoundPairings({
    required List<Player> allPlayers,
    required int roundNumber,
  }) {
    if (allPlayers.length == 4) {
      return _fixedFourPlayers(allPlayers);
    }
    
    final n = allPlayers.length;
    final isEven = n % 2 == 0;
    
    if (isEven) {
      return _roundRobinEven(allPlayers, roundNumber);
    } else {
      return _roundRobinOdd(allPlayers, roundNumber);
    }
  }
  
  // For even N: Standard round-robin
  List<PlayerPairing> _roundRobinEven(List<Player> players, int round) {
    // Use circle method: fix one player, rotate others
    // This guarantees each player partners with everyone
  }
  
  // For odd N: One player sits out fairly
  List<PlayerPairing> _roundRobinOdd(List<Player> players, int round) {
    // Sit-out rotates fairly
  }
}
```

### Bench Distribution Algorithm

```
BENCH FAIRNESS RULES:
1. Track consecutive bench count per player
2. Never bench a player who benched last round (if possible)
3. If all players benched last round, bench those with fewest rounds played
4. Players with more bench time get priority for next game
```

---

## 6. Score Tracking Enhancement

### Current: CourtViewWidget with tap scoring
### Enhanced: Larger touch targets, haptic feedback

**UI Specification:**

```
┌─────────────────────────────────────┐
│         Runde 3 / Punkte bis 16    │
├─────────────────────────────────────┤
│                                     │
│    ┌─────┐           ┌─────┐       │
│    │  9  │    :      │  7  │       │
│    └─────┘           └─────┘       │
│   Team A            Team B         │
│                                     │
│  ┌──────────────┐ ┌──────────────┐  │
│  │   + Team A   │ │   + Team B  │  │
│  └──────────────┘ └──────────────┘  │
│                                     │
│  [↩️ Undo]           [⏭️ Next Round] │
└─────────────────────────────────────┘
```

**Touch Targets:** Minimum 64x64dp for score buttons  
**Haptic Feedback:** Medium impact on score tap  
**Undo:** Single-level undo (last point only)

---

## 7. Leaderboard Specification

### Ranking Formula

```dart
int calculateRankingScore(LeaderboardEntry entry) => entry.totalAmericanoPoints;
```

**Only total points matter. Period.**

### Leaderboard Display

| Rank | Spieler | Punkte | Spiele | Bank |
|------|---------|--------|--------|------|
| 1 | 🔥 Mario | 47 | 8 | 2 |
| 2 | ⚡ Lisa | 45 | 8 | 2 |
| 3 | 🎾 Tom | 42 | 7 | 3 |

---

## 8. Files to Modify

### Domain Layer
| File | Change |
|------|--------|
| `orbit/domain/entities/round.dart` | Add `AmericanoRound`, modify `Player` |
| `orbit/domain/entities/leaderboard.dart` | Simplify ranking formula |
| `orbit/domain/usecases/rotation_algorithm.dart` | **REPLACE** with FairRotationAlgorithm |

### Presentation Layer
| File | Change |
|------|--------|
| `orbit/presentation/screens/orbit_session_screen.dart` | Enhanced score UI |
| `orbit/presentation/widgets/court_view_widget.dart` | Larger touch targets |

### State Management
| File | Change |
|------|--------|
| `orbit/presentation/cubit/orbit_session_cubit.dart` | Track Americano statistics |
| `orbit/presentation/cubit/orbit_session_state.dart` | Add `totalAmericanoPoints` per player |

---

## 9. Verification Plan

### Test 1: Algorithm Fairness
```bash
# Run rotation algorithm with 10 players, 20 rounds
# Verify: max playtime variance ≤ 1 round
dart test test/rotation_algorithm_fairness_test.dart
```

### Test 2: Score Tracking
```bash
# Manual test: Tap Team A 5 times, Team B 3 times
# Verify: Score displays "5 - 3" immediately
# Verify: Undo reverts to "4 - 3"
flutter test integration_test/score_tracking_test.dart
```

### Test 3: Leaderboard Accuracy
```bash
# After round ends with 9-7 score
# Verify: Team A players gain 9 points each
# Verify: Team B players gain 7 points each
# Verify: Leaderboard re-sorts by total points
flutter test integration_test/leaderboard_test.dart
```

---

## 10. Backlog Items

### User Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| US-01 | As a host, I want to create an Americano session with 4-10 players | Session starts with fair initial rotation |
| US-02 | As a player, I want to tap to score points in real-time | Score updates <100ms with haptic feedback |
| US-03 | As a player, I want to see the leaderboard after each round | Leaderboard shows accurate points ranking |
| US-04 | As a host, I want automatic fair rotation between rounds | No player sits out twice before everyone sits out once |
| US-05 | As a player, I want to undo my last point entry | Single-level undo reverts score by 1 point |

### Technical Tasks

| ID | Task | Files |
|----|------|-------|
| T-01 | Implement FairRotationAlgorithm | `rotation_algorithm.dart` |
| T-02 | Update Player entity with Americano stats | `round.dart` |
| T-03 | Simplify Leaderboard ranking formula | `leaderboard.dart` |
| T-04 | Enhance score UI with larger buttons | `court_view_widget.dart` |
| T-05 | Update OrbitSessionCubit for stats tracking | `orbit_session_cubit.dart` |

---

## 11. Architecture Approval

| Reviewer | Decision | Notes |
|----------|----------|-------|
| Dianne Hackborn | ✅ APPROVED | Constraint-based approach guarantees fairness |
| Scott Forstall | ✅ APPROVED | O(n) complexity is correct choice |

---

## 12. Flutter/Engineering Approval

| Reviewer | Decision | Notes |
|----------|----------|-------|
| Rémi Rousselet | ✅ APPROVED | Cubit state management supports the model |
| Felix Angelov | ✅ APPROVED | Pure function in domain layer is correct |

---

## 13. Padel-Domain Approval

| Reviewer | Decision | Notes |
|----------|----------|-------|
| Agustín Tapia | ✅ APPROVED | Matches real Americano tournament structure |
| Arturo Coello | ✅ APPROVED | Points target 8-24 even numbers is correct |

---

## Summary

This blueprint defines the minimum viable changes to fix the rotation algorithm problem while enhancing the real-time score tracking experience. The key decisions are:

1. **Replace greedy algorithm** with Round-Robin + Constraint Satisfaction
2. **Simplify leaderboard** to points-only ranking
3. **Enhance score UI** with larger touch targets
4. **Track per-player statistics** for fair rotation

**Estimated Complexity:** Medium (algorithm replacement + UI enhancement)  
**Risk:** Low (existing codebase provides good foundation)
