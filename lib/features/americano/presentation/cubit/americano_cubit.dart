import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';
import 'americano_state.dart';

class AmericanoCubit extends Cubit<AmericanoState> {
  AmericanoCubit() : super(const AmericanoState());

  final Random _random = Random();
  final FairRotationAlgorithm _rotationAlgorithm =
      const FairRotationAlgorithm();
  final ComputeServingStateUseCase _computeServingState =
      const ComputeServingStateUseCase();
  final CourtPositionHelper _courtPositionHelper = const CourtPositionHelper();

  /// Add a participant to the lobby
  void addParticipant(AmericanoParticipant participant) {
    final currentSession = state.session;
    if (currentSession == null) {
      emit(
        state.copyWith(
          session: AmericanoSession(
            id: _generateId(),
            participants: [participant],
            targetPoints: state.selectedTargetPoints,
            status: SessionStatus.lobby,
            createdAt: DateTime.now(),
          ),
          status: AmericanoStatus.lobby,
        ),
      );
    } else {
      if (currentSession.participants.length >= 10) {
        emit(state.copyWith(errorMessage: 'Maximum 10 players allowed'));
        return;
      }
      if (currentSession.participants.any((p) => p.id == participant.id)) {
        emit(state.copyWith(errorMessage: 'Player already added'));
        return;
      }
      emit(
        state.copyWith(
          session: currentSession.copyWith(
            participants: [...currentSession.participants, participant],
          ),
        ),
      );
    }
  }

  /// Remove a participant from the lobby
  void removeParticipant(String participantId) {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    final updatedParticipants = currentSession.participants
        .where((p) => p.id != participantId)
        .toList();

    emit(
      state.copyWith(
        session: currentSession.copyWith(participants: updatedParticipants),
      ),
    );
  }

  /// Update target points for the session
  void setTargetPoints(int points) {
    emit(state.copyWith(selectedTargetPoints: points));
    final currentSession = state.session;
    if (currentSession != null) {
      emit(
        state.copyWith(session: currentSession.copyWith(targetPoints: points)),
      );
    }
  }

  /// Start the Americano session
  void startSession() {
    final currentSession = state.session;
    if (currentSession == null) {
      emit(state.copyWith(errorMessage: 'No session to start'));
      return;
    }
    if (currentSession.participants.length < 4) {
      emit(state.copyWith(errorMessage: 'Need at least 4 players'));
      return;
    }

    // Create initial leaderboard
    final initialLeaderboard = _createLeaderboard(currentSession, []);

    emit(
      state.copyWith(
        session: currentSession.copyWith(
          status: SessionStatus.inProgress,
          currentRoundNumber: 1,
        ),
        status: AmericanoStatus.inProgress,
        leaderboard: initialLeaderboard,
      ),
    );

    // Create first match
    _createNextMatch();
  }

  /// Create the next match with fair rotation
  void _createNextMatch() {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    final completedRounds = currentSession.matches
        .where((m) => m.isComplete)
        .map((m) => m.toCompletedRound())
        .toList();

    final allPlayers = currentSession.participants
        .map((p) => p.toPlayer())
        .toList();

    final constraints = RotationConstraints(
      matchesPlayed: _buildMatchesPlayedMap(currentSession),
      benchCount: _buildBenchCountMap(currentSession),
    );

    final rotationResult = _rotationAlgorithm.calculateNextRound(
      allPlayers: allPlayers,
      completedRounds: completedRounds,
      constraints: constraints,
    );

    // Map back to AmericanoParticipants
    final teamAParticipants = rotationResult.teamA.players
        .map(
          (p) => currentSession.participants.firstWhere((ap) => ap.id == p.id),
        )
        .toList();
    final teamBParticipants = rotationResult.teamB.players
        .map(
          (p) => currentSession.participants.firstWhere((ap) => ap.id == p.id),
        )
        .toList();

    // Bench players are those not currently playing
    final benchParticipants = rotationResult.benchPlayers
        .map(
          (p) => currentSession.participants.firstWhere((ap) => ap.id == p.id),
        )
        .toList();

    // Determine initial serving team via coin toss
    final initialServingTeam = _coinTossForInitialServer();

    // Build server rotation order: [TeamA_player0, TeamB_player0, TeamA_player1, TeamB_player1]
    // This creates the pattern: P0 → P2 → P1 → P3 → P0 (repeating)
    final serverRotationOrder = [
      teamAParticipants[0].id,
      teamBParticipants[0].id,
      if (teamAParticipants.length > 1)
        teamAParticipants[1].id
      else
        teamAParticipants[0].id,
      if (teamBParticipants.length > 1)
        teamBParticipants[1].id
      else
        teamBParticipants[0].id,
    ];

    // Compute initial serving state
    final initialServingState = _computeServingState.execute(
      pointsPlayed: 0,
      serverRotationOrder: serverRotationOrder,
      initialServingTeam: initialServingTeam,
    );

    final newMatch = AmericanoMatch(
      id: _generateId(),
      roundNumber: currentSession.currentRoundNumber,
      teamA: teamAParticipants,
      teamB: teamBParticipants,
      targetPoints: currentSession.targetPoints,
      pairingReason: rotationResult.pairingReason,
      benchPlayers: benchParticipants,
      servingTeam: initialServingTeam,
      serverRotationOrder: serverRotationOrder,
      pointsPlayed: 0,
      servingState: initialServingState,
    );

    final updatedMatches = [...currentSession.matches, newMatch];

    emit(
      state.copyWith(
        session: currentSession.copyWith(matches: updatedMatches),
        currentMatch: newMatch,
        status: AmericanoStatus.inProgress,
      ),
    );
  }

  /// Add a point to Team A
  void addPointTeamA() {
    _addPoint(state.currentMatch?.teamA ?? [], TeamSide.a);
  }

  /// Add a point to Team B
  void addPointTeamB() {
    _addPoint(state.currentMatch?.teamB ?? [], TeamSide.b);
  }

  void _addPoint(List<AmericanoParticipant> scoringTeam, TeamSide scoringSide) {
    final currentMatch = state.currentMatch;
    final currentSession = state.session;
    if (currentMatch == null || currentSession == null) {
      return;
    }
    if (currentMatch.isComplete) {
      return;
    }

    final isTeamA = scoringSide == TeamSide.a;
    final newTeamAScore = isTeamA
        ? currentMatch.teamAScore + 1
        : currentMatch.teamAScore;
    final newTeamBScore = !isTeamA
        ? currentMatch.teamBScore + 1
        : currentMatch.teamBScore;

    // Check if match is complete based on game mode
    // Americano: combined points = target (e.g., target 12 → 6:6, 11:1, 4:8)
    // Liga: one team reaches target (e.g., target 14 → 14:0, 14:9)
    bool isMatchComplete;
    TeamSide? winnerSide;

    if (state.gameMode == GameModeType.americano) {
      // Match ends when combined score reaches target
      isMatchComplete =
          newTeamAScore + newTeamBScore >= currentMatch.targetPoints;
      if (isMatchComplete) {
        // Determine winner: draw when scores are equal, otherwise higher score wins
        if (newTeamAScore > newTeamBScore) {
          winnerSide = TeamSide.a;
        } else if (newTeamBScore > newTeamAScore) {
          winnerSide = TeamSide.b;
        } else {
          winnerSide = null; // Draw - 6:6, 7:7, etc.
        }
      }
    } else {
      // Liga: match ends when one team reaches target
      isMatchComplete =
          newTeamAScore >= currentMatch.targetPoints ||
          newTeamBScore >= currentMatch.targetPoints;
      if (isMatchComplete) {
        winnerSide = newTeamAScore >= currentMatch.targetPoints
            ? TeamSide.a
            : TeamSide.b;
      }
    }

    // Compute new serving state using the use case
    final newPointsPlayed = currentMatch.pointsPlayed + 1;
    final newServingState = isMatchComplete
        ? currentMatch.servingState
        : _computeServingState.execute(
            pointsPlayed: newPointsPlayed,
            serverRotationOrder: currentMatch.serverRotationOrder,
            initialServingTeam: currentMatch.servingTeam,
          );

    // Compute new court position if match is not complete
    final newCourtPosition = isMatchComplete
        ? currentMatch.courtPosition
        : _courtPositionHelper.compute(
            teamA: currentMatch.teamA,
            teamB: currentMatch.teamB,
            servingState: newServingState,
            serverRotationOrder: currentMatch.serverRotationOrder,
          );

    final updatedMatch = currentMatch.copyWith(
      teamAScore: newTeamAScore,
      teamBScore: newTeamBScore,
      isComplete: isMatchComplete,
      status: isMatchComplete ? MatchStatus.completed : MatchStatus.active,
      winnerSide: winnerSide,
      pointsPlayed: newPointsPlayed,
      servingState: newServingState,
      courtPosition: newCourtPosition,
    );

    // Update session matches
    final updatedMatches = currentSession.matches
        .map((m) => m.id == updatedMatch.id ? updatedMatch : m)
        .toList();

    emit(
      state.copyWith(
        session: currentSession.copyWith(matches: updatedMatches),
        currentMatch: updatedMatch,
        status: isMatchComplete
            ? AmericanoStatus.matchComplete
            : AmericanoStatus.inProgress,
      ),
    );

    if (isMatchComplete) {
      _updateLeaderboardAfterMatch(updatedMatch);
    }
  }

  void _updateLeaderboardAfterMatch(AmericanoMatch completedMatch) {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    final pointsEarned = completedMatch.getPointsForPlayers();
    final winnerSide = completedMatch.winnerSide;

    final updatedParticipants = currentSession.participants.map((p) {
      final points = pointsEarned[p.id] ?? 0;
      final won =
          winnerSide != null &&
          ((winnerSide == TeamSide.a &&
                  completedMatch.teamA.any((tp) => tp.id == p.id)) ||
              (winnerSide == TeamSide.b &&
                  completedMatch.teamB.any((tp) => tp.id == p.id)));

      return p.copyWith(
        totalPoints: p.totalPoints + points,
        matchesPlayed: p.matchesPlayed + 1,
        matchesWon: won ? p.matchesWon + 1 : p.matchesWon,
      );
    }).toList();

    final updatedSession = currentSession.copyWith(
      participants: updatedParticipants,
    );
    final updatedLeaderboard = _createLeaderboard(
      updatedSession,
      currentSession.matches,
    );

    emit(
      state.copyWith(session: updatedSession, leaderboard: updatedLeaderboard),
    );
  }

  AmericanoLeaderboard _createLeaderboard(
    AmericanoSession session,
    List<AmericanoMatch> matches,
  ) {
    final entries = session.participants
        .map(
          (p) => AmericanoLeaderboardEntry(
            participant: p,
            totalPoints: p.totalPoints,
            matchesPlayed: p.matchesPlayed,
            matchesWon: p.matchesWon,
            averagePointsPerMatch: p.averagePointsPerMatch,
          ),
        )
        .toList();

    return AmericanoLeaderboard(
      sessionId: session.id,
      entries: entries,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, int> _buildMatchesPlayedMap(AmericanoSession session) {
    final map = <String, int>{};
    for (final p in session.participants) {
      map[p.id] = p.matchesPlayed;
    }
    return map;
  }

  Map<String, int> _buildBenchCountMap(AmericanoSession session) {
    final map = <String, int>{};
    for (final p in session.participants) {
      map[p.id] = p.benchCount;
    }
    return map;
  }

  /// Coin toss to determine which team serves first
  /// Uses Random().nextBool() for fair 50/50 distribution
  TeamSide _coinTossForInitialServer() =>
      _random.nextBool() ? TeamSide.a : TeamSide.b;

  /// Proceed to the next round
  void nextRound() {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    emit(
      state.copyWith(
        session: currentSession.copyWith(
          currentRoundNumber: currentSession.currentRoundNumber + 1,
        ),
        status: AmericanoStatus.inProgress,
      ),
    );

    _createNextMatch();
  }

  /// Show the leaderboard
  void showLeaderboard() {
    emit(state.copyWith(status: AmericanoStatus.matchComplete));
  }

  /// End the session
  void endSession() {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    emit(
      state.copyWith(
        session: currentSession.copyWith(status: SessionStatus.completed),
        status: AmericanoStatus.sessionComplete,
      ),
    );
  }

  /// Reset to lobby
  void reset() {
    emit(const AmericanoState());
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
