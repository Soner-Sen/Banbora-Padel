import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/features/orbit/presentation/cubit/orbit_state.dart';

class OrbitCubit extends Cubit<OrbitState> {
  OrbitCubit() : super(const OrbitState());

  List<String> _allPlayers = [];
  int _currentRotationIndex = 0;

  void initializeSession({
    required String mode,
    required int targetPoints,
    required List<String> players,
  }) {
    _allPlayers = List.from(players);
    emit(
      state.copyWith(
        status: OrbitStatus.loading,
        mode: mode,
        targetPoints: targetPoints,
      ),
    );

    // Start first round
    _startRound();
  }

  void _startRound() {
    final newRound = state.currentRound + 1;
    final playersForRound = _getNextPlayers();

    if (playersForRound.length < 4) {
      emit(
        state.copyWith(
          status: OrbitStatus.sessionComplete,
          errorMessage: 'Nicht genug Spieler für eine Runde',
        ),
      );
      return;
    }

    final teamAPlayer1 = playersForRound[0];
    final teamAPlayer2 = playersForRound[1];
    final teamBPlayer1 = playersForRound[2];
    final teamBPlayer2 = playersForRound[3];

    final waitingPlayers = playersForRound.length > 4
        ? playersForRound.sublist(4)
        : <String>[];

    emit(
      state.copyWith(
        status: OrbitStatus.roundInProgress,
        currentRound: newRound,
        teamAScore: 0,
        teamBScore: 0,
        teamAPlayer1: teamAPlayer1,
        teamAPlayer2: teamAPlayer2,
        teamBPlayer1: teamBPlayer1,
        teamBPlayer2: teamBPlayer2,
        waitingPlayers: waitingPlayers,
        serverIndex: 0,
        scoreHistory: [],
      ),
    );

    _updateLeaderboard();
  }

  List<String> _getNextPlayers() {
    if (_allPlayers.length <= 4) {
      return List.from(_allPlayers);
    }

    // Fair rotation algorithm
    final result = <String>[];
    final available = List<String>.from(_allPlayers);

    // Simple round-robin with fairness consideration
    // Pick 4 players who haven't played together recently
    for (int i = 0; i < 4 && available.isNotEmpty; i++) {
      // For MVP: just rotate through the list
      final index = (_currentRotationIndex + i) % available.length;
      result.add(available.removeAt(index));
    }

    _currentRotationIndex = (_currentRotationIndex + 4) % _allPlayers.length;

    return result;
  }

  void scorePoint({required bool isTeamA}) {
    if (state.status != OrbitStatus.roundInProgress) {
      return;
    }

    final newScoreHistory = List<ScoreEvent>.from(state.scoreHistory)
      ..add(ScoreEvent(isTeamA: isTeamA, timestamp: DateTime.now()));

    if (isTeamA) {
      final newScore = state.teamAScore + 1;
      final isComplete = newScore >= state.targetPoints;

      emit(
        state.copyWith(
          teamAScore: newScore,
          scoreHistory: newScoreHistory,
          status: isComplete
              ? OrbitStatus.roundComplete
              : OrbitStatus.roundInProgress,
        ),
      );
    } else {
      final newScore = state.teamBScore + 1;
      final isComplete = newScore >= state.targetPoints;

      emit(
        state.copyWith(
          teamBScore: newScore,
          scoreHistory: newScoreHistory,
          status: isComplete
              ? OrbitStatus.roundComplete
              : OrbitStatus.roundInProgress,
        ),
      );
    }
  }

  void undoLastPoint() {
    if (!state.canUndo) {
      return;
    }

    final newHistory = List<ScoreEvent>.from(state.scoreHistory)..removeLast();
    final lastEvent = state.scoreHistory.last;

    if (lastEvent.isTeamA) {
      emit(
        state.copyWith(
          teamAScore: state.teamAScore - 1,
          scoreHistory: newHistory,
          status: OrbitStatus.roundInProgress,
        ),
      );
    } else {
      emit(
        state.copyWith(
          teamBScore: state.teamBScore - 1,
          scoreHistory: newHistory,
          status: OrbitStatus.roundInProgress,
        ),
      );
    }
  }

  void startNextRound() {
    // Update leaderboard with round results
    _updateLeaderboardAfterRound();

    // Rotate waiting players back if any
    if (state.waitingPlayers.isNotEmpty && _allPlayers.length > 4) {
      // Move waiting players back to available pool
      // This is simplified - real implementation would use more complex rotation
    }

    _startRound();
  }

  void _updateLeaderboard() {
    // Initialize leaderboard if empty
    if (state.leaderboard.isEmpty) {
      final entries = _allPlayers
          .map(
            (name) => LeaderboardEntry(
              playerName: name,
              totalPoints: 0,
              wins: 0,
              matchesPlayed: 0,
            ),
          )
          .toList();

      emit(state.copyWith(leaderboard: entries));
    }
  }

  void _updateLeaderboardAfterRound() {
    final winningTeamIsA = state.teamAScore >= state.targetPoints;
    final winningPlayers = winningTeamIsA
        ? [state.teamAPlayer1, state.teamAPlayer2]
        : [state.teamBPlayer1, state.teamBPlayer2];

    final pointsToAdd = winningTeamIsA ? state.teamAScore : state.teamBScore;

    final updatedLeaderboard = state.leaderboard.map((entry) {
      if (winningPlayers.contains(entry.playerName)) {
        return LeaderboardEntry(
          playerName: entry.playerName,
          totalPoints: entry.totalPoints + pointsToAdd,
          wins: entry.wins + 1,
          matchesPlayed: entry.matchesPlayed + 1,
        );
      } else {
        return LeaderboardEntry(
          playerName: entry.playerName,
          totalPoints: entry.totalPoints,
          wins: entry.wins,
          matchesPlayed: entry.matchesPlayed + 1,
        );
      }
    }).toList();

    // Sort by total points
    updatedLeaderboard.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    emit(state.copyWith(leaderboard: updatedLeaderboard));
  }

  void addGuestPlayer(String name) {
    if (!_allPlayers.contains(name) && _allPlayers.length < 10) {
      _allPlayers.add(name);
    }
  }

  void removePlayer(String name) {
    _allPlayers.remove(name);
  }

  void endSession() {
    emit(state.copyWith(status: OrbitStatus.sessionComplete));
  }
}
