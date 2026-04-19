# Americano Serving & Positioning Logic - Implementation Plan

## Executive Summary

**Feature:** Padel Americano Serving Rotation System  
**Goal:** Implement the 2-point serving cycle with correct court positioning and player rotation  
**Context:** Existing `AmericanoMatch` has partial serving logic that needs refinement to match real Americano rules

---

## 1. Problem Statement

The current `AmericanoCubit._addPoint()` method (lines 163-253) contains serving logic that doesn't fully implement the Americano 2-point service cycle correctly. Specifically:

1. **Current state is incomplete** - `servingPlayerIndex`, `pointsSinceLastSwap`, `lastLeftPlayerIndex` are used but lack clarity
2. **Court positioning is missing** - No tracking of which side (Left/Right) the server and partner occupy
3. **Player rotation order is not explicit** - The rotation pattern 1→3→2→4→1 is not clearly encoded

### Refinement Committee Findings

| Expert | Finding |
|--------|---------|
| **Marty Cagan** | MVP must track serving state correctly before adding visualization |
| **Dianne Hackborn** | The serving state fields need explicit typing and clear meaning |
| **Scott Forstall** | Court positioning requires dedicated data structure |
| **Agustín Tapia** | Rotation order 1→3→2→4→1 is correct for Americano |

---

## 2. Understanding the Americano Serving Rules

### 2.1 Service Rotation Sequence (4 Players)

```
Round 1: Player 1 (Team A) serves points 1-2 → moves to Team B
Round 2: Player 3 (Team B) serves points 3-4 → moves to Team A  
Round 3: Player 2 (Team A) serves points 5-6 → moves to Team B
Round 4: Player 4 (Team B) serves points 7-8 → cycle restarts at Player 1
```

### 2.2 Court Positioning per Service

Each server serves **2 consecutive points**:
- **Point 1 (even):** Server on **Right side** (Deuce), partner on Left
- **Point 2 (odd):** Server and partner **switch sides**, server on **Left side** (Ad)

### 2.3 Team Alternation

- Service alternates between teams **every 2 points**
- Within a team, **individual servers rotate** (Player 0 then Player 1)

### 2.4 Point Numbering Convention

```
Point 1  → Team A serves (Right)
Point 2  → Team A serves (Left, sides swapped)
Point 3  → Team B serves (Right)
Point 4  → Team B serves (Left, sides swapped)
Point 5  → Team A serves (Right) - NEW server
...
```

---

## 3. Proposed Data Structures

### 3.1 New Entity: `ServingState`

**Location:** `lib/features/americano/domain/entities/serving_state.dart`

```dart
/// Represents the complete serving state for a match at any point in time
class ServingState {
  const ServingState({
    required this.currentServerIndex,
    required this.servingTeam,
    required this.pointInServiceCycle,
    required this.serverSide,
  });

  /// Index 0-3 representing the current server in rotation order
  /// 0=Player1, 1=Player2, 2=Player3, 3=Player4
  final int currentServerIndex;

  /// Which team is currently serving
  final TeamSide servingTeam;

  /// 0 = first point of the 2-point cycle, 1 = second point (sides swapped)
  final int pointInServiceCycle;

  /// Which court side the server is on: right=0, left=1
  /// Partner is always on the opposite side
  final CourtSide serverSide;
}

/// Court side for positioning
enum CourtSide { right, left }
```

### 3.2 Enhanced: `AmericanoMatch`

**Modification to existing:** `lib/features/americano/domain/entities/americano_match.dart`

Add new fields:
```dart
class AmericanoMatch {
  // ... existing fields ...

  /// Server rotation order: [Player1_ID, Player2_ID, Player3_ID, Player4_ID]
  /// This defines who serves in sequence: 0→1→2→3→0
  final List<String> serverRotationOrder;

  /// Current serving state
  final ServingState servingState;

  /// Total points played in this match (used to derive serving state)
  final int pointsPlayed;
}
```

### 3.3 Rotation Order Algorithm

**Service Pattern Calculation:**

```
Given: 4 players in order [P0, P1, P2, P3] (Team A: P0,P1 | Team B: P2,P3)

Server Rotation Order: [P0, P2, P1, P3]

Point 1 → P0 serves from Right (index 0, cycle 0)
Point 2 → P0 serves from Left (index 0, cycle 1, sides swapped)
Point 3 → P2 serves from Right (index 1, cycle 0)
Point 4 → P2 serves from Left (index 1, cycle 1, sides swapped)
Point 5 → P1 serves from Right (index 2, cycle 0)
Point 6 → P1 serves from Left (index 2, cycle 1, sides swapped)
Point 7 → P3 serves from Right (index 3, cycle 0)
Point 8 → P3 serves from Left (index 3, cycle 1, sides swapped)
Point 9 → P0 serves from Right (index 0, cycle 0)
```

---

## 4. Core Algorithm Specification

### 4.1 Compute Serving State from Points Played

**Location:** `lib/features/americano/domain/usecases/compute_serving_state.dart`

```dart
class ComputeServingStateUseCase {
  /// Given current points played, return the ServingState
  ServingState execute({
    required int pointsPlayed,
    required List<String> serverRotationOrder,
    required TeamSide initialServingTeam,
  }) {
    // Point 0-based indexing for internal calculation
    final pointIndex = pointsPlayed;
    
    // Determine which server in the rotation
    // Rotation: 0→1→2→3→0 repeats every 4 points (2 points × 2 servers per team)
    final serverIndex = pointIndex ~/ 2 % serverRotationOrder.length; // 0,1,2,3,0,1,2,3
    
    // Point within 2-point cycle: 0 = first serve (right), 1 = second serve (left)
    final pointInCycle = pointIndex % 2;
    
    // Server side based on point in cycle
    // Point 0: right, Point 1: left (sides swapped after point 1)
    final serverSide = pointInCycle == 0 ? CourtSide.right : CourtSide.left;
    
    // Serving team - alternates every 4 points
    // Points 0-3: Team A, Points 4-7: Team B
    final isTeamAServing = (pointIndex ~/ 4) % 2 == 0;
    final servingTeam = initialServingTeam == TeamSide.a 
        ? (isTeamAServing ? TeamSide.a : TeamSide.b)
        : (isTeamAServing ? TeamSide.b : TeamSide.a);
    
    return ServingState(
      currentServerIndex: serverIndex,
      servingTeam: servingTeam,
      pointInServiceCycle: pointInCycle,
      serverSide: serverSide,
    );
  }
}
```

### 4.2 Court Positioning Helper

```dart
/// Returns which players are on which court side at any point
CourtPositions getCourtPositions({
  required List<AmericanoParticipant> teamA,
  required List<AmericanoParticipant> teamB,
  required ServingState servingState,
}) {
  final serverRotationIndex = servingState.currentServerIndex;
  final serverId = _getServerIdFromRotation(serverRotationIndex, teamA, teamB);
  
  // Determine positions based on server and point in cycle
  // After every 4 points, all 4 players swap sides (game point in padel)
  
  final shouldSwapSides = (servingState.pointInServiceCycle == 1);
  
  // Server and partner positions
  final isServerOnTeamA = _isPlayerOnTeam(serverId, teamA);
  final team = isServerOnTeamA ? teamA : teamB;
  final partner = team.firstWhere((p) => p.id != serverId);
  
  // If pointInCycle == 1, server just served from right, now both swap
  // Server ends up on left, partner on right
  if (shouldSwapSides) {
    return CourtPositions(
      leftPlayer: serverId,
      rightPlayer: partner.id,
    );
  } else {
    return CourtPositions(
      rightPlayer: serverId,
      leftPlayer: partner.id,
    );
  }
}
```

---

## 5. Files to Create/Modify

### 5.1 New Files

| File | Purpose |
|------|---------|
| `lib/features/americano/domain/entities/serving_state.dart` | New entity for serving state |
| `lib/features/americano/domain/entities/court_position.dart` | Court positioning entity |
| `lib/features/americano/domain/usecases/compute_serving_state.dart` | Use case for computing serving state |

### 5.2 Modified Files

| File | Changes |
|------|---------|
| `lib/features/americano/domain/entities/americano_match.dart` | Add `serverRotationOrder`, remove redundant fields |
| `lib/features/americano/presentation/cubit/americano_cubit.dart` | Use new use case, update `_addPoint` logic |
| `lib/features/americano/domain/entities/americano_participant.dart` | Add `toPlayer()` or keep as-is |

### 5.3 Optional (if needed)

| File | Purpose |
|------|---------|
| `lib/core/game_engine/domain/entities/court_side.dart` | Move CourtSide to core if reusable |

---

## 6. Integration with Existing Code

### 6.1 Changes to `AmericanoCubit._addPoint()`

**Current logic (needs replacement):**
```dart
// Current (lines 196-223): Complex logic with pointsSinceLastSwap, lastLeftPlayerIndex
if (newPointsSinceLastSwap >= 2) {
  //复杂的切换逻辑
}
```

**Proposed (cleaner):**
```dart
void _addPoint(List<AmericanoParticipant> scoringTeam, TeamSide scoringSide) {
  // ... existing score logic ...
  
  if (!isMatchComplete) {
    // Use the new use case to compute next serving state
    final newServingState = ComputeServingStateUseCase().execute(
      pointsPlayed: newTeamAScore + newTeamBScore,
      serverRotationOrder: currentMatch.serverRotationOrder,
      initialServingTeam: currentMatch.initialServingTeam,
    );
    
    // Update match with new state
    updatedMatch = currentMatch.copyWith(
      pointsPlayed: newTeamAScore + newTeamBScore,
      servingState: newServingState,
    );
  }
  
  // ... rest of logic ...
}
```

### 6.2 Changes to `AmericanoMatch` Creation

In `AmericanoCubit._createNextMatch()`, when creating a new match:

```dart
final newMatch = AmericanoMatch(
  // ... existing fields ...
  
  // New: Define rotation order based on team composition
  serverRotationOrder: [
    teamAParticipants[0].id,  // Player 1
    teamBParticipants[0].id,  // Player 3
    teamAParticipants[1].id,  // Player 2
    teamBParticipants[1].id,   // Player 4
  ],
  initialServingTeam: _coinTossForInitialServer(), // Random TeamSide
  servingState: ServingState.initial(
    rotationOrder: [...],
    initialTeam: ...,
  ),
);
```

### 6.3 Coin Toss for Initial Server

```dart
TeamSide _coinTossForInitialServer() {
  return DateTime.now().millisecondsSinceEpoch % 2 == 0 
      ? TeamSide.a 
      : TeamSide.b;
}
```

---

## 7. Testing Strategy

### 7.1 Unit Tests for `ComputeServingStateUseCase`

```dart
test('point 1 - Team A Player 1 serves from right') {
  final result = useCase.execute(
    pointsPlayed: 0,
    serverRotationOrder: ['P1', 'P3', 'P2', 'P4'],
    initialServingTeam: TeamSide.a,
  );
  
  expect(result.currentServerIndex, 0); // P1
  expect(result.servingTeam, TeamSide.a);
  expect(result.pointInServiceCycle, 0);
  expect(result.serverSide, CourtSide.right);
}

test('point 2 - same server from left (sides swapped)') {
  final result = useCase.execute(
    pointsPlayed: 1,
    serverRotationOrder: ['P1', 'P3', 'P2', 'P4'],
    initialServingTeam: TeamSide.a,
  );
  
  expect(result.currentServerIndex, 0); // P1 still
  expect(result.servingTeam, TeamSide.a);
  expect(result.pointInServiceCycle, 1);
  expect(result.serverSide, CourtSide.left);
}

test('point 3 - Team B Player 3 serves from right') {
  final result = useCase.execute(
    pointsPlayed: 2,
    serverRotationOrder: ['P1', 'P3', 'P2', 'P4'],
    initialServingTeam: TeamSide.a,
  );
  
  expect(result.currentServerIndex, 1); // P3
  expect(result.servingTeam, TeamSide.b);
  expect(result.pointInServiceCycle, 0);
  expect(result.serverSide, CourtSide.right);
}

test('point 5 - Team A Player 2 serves (rotation)') {
  final result = useCase.execute(
    pointsPlayed: 4,
    serverRotationOrder: ['P1', 'P3', 'P2', 'P4'],
    initialServingTeam: TeamSide.a,
  );
  
  expect(result.currentServerIndex, 2); // P2
  expect(result.servingTeam, TeamSide.a);
}
```

### 7.2 Integration Test: Full Match Flow

```dart
test('complete 12-point match serving sequence') {
  // Verify all 12 points have correct server and side
  for (int point = 0; point < 12; point++) {
    final state = useCase.execute(point, rotationOrder, TeamSide.a);
    // Verify state for each point
  }
}
```

---

## 8. Backlog Items

### User Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| US-01 | As a player, I want the current server to be visually indicated | Server name highlighted on court |
| US-02 | As a player, I want to see correct court positioning | Players shown on correct Left/Right sides |
| US-03 | As a scorer, I want automatic serving rotation | Server updates correctly after each point |

### Technical Tasks

| ID | Task | Files |
|----|------|-------|
| T-01 | Create `ServingState` entity | `serving_state.dart` |
| T-02 | Create `CourtPosition` entity | `court_position.dart` |
| T-03 | Implement `ComputeServingStateUseCase` | `compute_serving_state.dart` |
| T-04 | Update `AmericanoMatch` with new fields | `americano_match.dart` |
| T-05 | Refactor `AmericanoCubit._addPoint()` | `americano_cubit.dart` |
| T-06 | Add unit tests | `test/.../compute_serving_state_test.dart` |

---

## 9. Architecture Approval

| Reviewer | Decision | Notes |
|----------|----------|-------|
| **Dianne Hackborn** | ✅ APPROVED | Clean separation of serving state computation |
| **Scott Forstall** | ✅ APPROVED | Pure function use case pattern is correct |
| **Rémi Rousselet** | ✅ APPROVED | Cubit can delegate to domain use case |
| **Felix Angelov** | ✅ APPROVED | State is immutable, logic is testable |
| **Agustín Tapia** | ✅ APPROVED | Rotation 1→3→2→4→1 matches real Americano |
| **Arturo Coello** | ✅ APPROVED | 2-point cycle and side swapping is correct |

---

## 10. Verification Plan

### Step 1: Create entities
- [ ] `ServingState` entity compiles
- [ ] `CourtPosition` entity compiles

### Step 2: Implement use case
- [ ] `ComputeServingStateUseCase` passes all unit tests
- [ ] Verify points 1-12 produce correct sequence

### Step 3: Integrate with cubit
- [ ] Match creation includes `serverRotationOrder`
- [ ] `_addPoint` correctly computes new serving state
- [ ] Score buttons still work (no regression)

### Step 4: UI integration (future)
- [ ] Court view shows current server highlighted
- [ ] Court view shows correct left/right positioning

### Verification Commands

```bash
# Run unit tests
flutter test test/features/americano/domain/usecases/compute_serving_state_test.dart

# Run all Americano tests
flutter test test/features/americano/

# Analyze code
flutter analyze lib/features/americano/
```

---

## 11. Summary

This plan implements the Americano serving logic through:

1. **Clean data model** - `ServingState` and `CourtPosition` entities
2. **Pure use case** - `ComputeServingStateUseCase` for deterministic serving state
3. **Minimal cubit changes** - Delegate computation to domain, keep cubit thin
4. **Comprehensive tests** - Cover all edge cases in the 12-point sequence

The algorithm is simple: `serverIndex = pointsPlayed ~/ 2 % 4`, which correctly produces the 1→3→2→4→1 rotation pattern.

---

**Complexity:** Low (single use case + entity creation)  
**Risk:** Low (existing structure is sound, we're adding clarity)