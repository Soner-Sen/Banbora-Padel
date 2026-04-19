import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';
import 'orbit_session_state.dart';

class OrbitSessionCubit extends Cubit<OrbitSessionState> {
  OrbitSessionCubit({
    FairRotationAlgorithm? rotationAlgorithm,
    ScoreEngine? scoreEngine,
  }) : _rotationAlgorithm = rotationAlgorithm ?? FairRotationAlgorithm(),
       _scoreEngine = scoreEngine ?? ScoreEngine(),
       super(const OrbitSessionState());
  final FairRotationAlgorithm _rotationAlgorithm;
  final ScoreEngine _scoreEngine;

  String _generateSessionId() {
    final random = Random();
    final code = String.fromCharCodes(
      List.generate(6, (_) => random.nextInt(26) + 65),
    );
    return code;
  }

  void createSession({required String hostDeviceId, int targetPoints = 12}) {
    final sessionId = _generateSessionId();
    final joinCode = _generateJoinCode();

    emit(
      state.copyWith(
        status: OrbitSessionStatus.lobby,
        sessionId: sessionId,
        hostDeviceId: hostDeviceId,
        joinCode: joinCode,
        targetPoints: targetPoints,
        participants: const [],
        leaderboard: const [],
      ),
    );
  }

  String _generateJoinCode() {
    final random = Random();
    return String.fromCharCodes(
      List.generate(4, (_) => random.nextInt(10) + 48),
    );
  }

  void addParticipant({
    required String id,
    required String displayName,
    required PlayerAvatar avatar,
    bool isGuest = true,
    String? deviceId,
    int? skillLevel,
  }) {
    if (state.status == OrbitSessionStatus.sessionComplete) {
      return;
    }

    final existingIndex = state.participants.indexWhere((p) => p.id == id);
    List<Participant> updatedParticipants;

    if (existingIndex >= 0) {
      return;
    } else {
      final newParticipant = Participant(
        id: id,
        displayName: displayName,
        avatar: avatar,
        isGuest: isGuest,
        deviceId: deviceId,
        skillLevel: skillLevel,
      );
      updatedParticipants = [...state.participants, newParticipant];
    }

    emit(state.copyWith(participants: updatedParticipants));
  }

  void addGuest(String displayName) {
    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final avatarIndex = state.participants.length + 1;
    final avatar =
        PlayerAvatar.values[avatarIndex % PlayerAvatar.values.length];

    addParticipant(
      id: guestId,
      displayName: displayName.isEmpty ? 'Gast $avatarIndex' : displayName,
      avatar: avatar,
      isGuest: true,
    );
  }

  void removeParticipant(String participantId) {
    final updatedParticipants = state.participants
        .where((p) => p.id != participantId)
        .toList();
    emit(state.copyWith(participants: updatedParticipants));
  }

  void startSession() {
    if (state.participants.length < 4) {
      return;
    }

    final session = Session(
      id: state.sessionId ?? _generateSessionId(),
      mode: 'orbit',
      targetPoints: state.targetPoints,
      createdAt: DateTime.now(),
      hostDeviceId: state.hostDeviceId ?? 'unknown',
      status: SessionStatus.active,
      participants: state.participants,
      rounds: const [],
      rules: SessionModeRules.orbit,
    );

    emit(state.copyWith(status: OrbitSessionStatus.active, session: session));

    _startFirstRound();
  }

  void _startFirstRound() {
    if (state.participants.length < 4) {
      return;
    }

    final constraints = _buildConstraints();
    final rotationResult = _rotationAlgorithm.calculateNextRound(
      allParticipants: state.participants,
      completedRounds: const [],
      constraints: constraints,
      targetPoints: state.targetPoints,
    );

    final round = _rotationAlgorithm.createRound(
      roundId: 'round_1',
      roundNumber: 1,
      rotationResult: rotationResult,
      targetPoints: state.targetPoints,
    );

    emit(
      state.copyWith(
        status: OrbitSessionStatus.active,
        currentRound: round,
        lastPairingReason: rotationResult.pairingReason,
        canUndo: false,
      ),
    );
  }

  PairingConstraints _buildConstraints() {
    final partnerHistory = <String, Set<String>>{};
    final opponentHistory = <String, Set<String>>{};
    final matchesPlayed = <String, int>{};
    final benchCount = <String, int>{};

    for (final participant in state.participants) {
      partnerHistory[participant.id] = {};
      opponentHistory[participant.id] = {};
      matchesPlayed[participant.id] = 0;
      benchCount[participant.id] = 0;
    }

    if (state.session?.rounds != null) {
      for (final round in state.session!.rounds) {
        for (final player in round.teamA.players) {
          for (final partner in round.teamA.players) {
            if (partner.id != player.id) {
              partnerHistory[player.id]?.add(partner.id);
            }
          }
          for (final opponent in round.teamB.players) {
            opponentHistory[player.id]?.add(opponent.id);
          }
        }
        for (final player in round.teamB.players) {
          for (final partner in round.teamB.players) {
            if (partner.id != player.id) {
              partnerHistory[player.id]?.add(partner.id);
            }
          }
          for (final opponent in round.teamA.players) {
            opponentHistory[player.id]?.add(opponent.id);
          }
        }
        for (final benchPlayer in round.bench) {
          benchCount[benchPlayer.id] = (benchCount[benchPlayer.id] ?? 0) + 1;
        }
      }
    }

    return PairingConstraints(
      partnerHistory: partnerHistory,
      opponentHistory: opponentHistory,
      matchesPlayed: matchesPlayed,
      benchCount: benchCount,
    );
  }

  void scorePointForTeamA(Player scorer) {
    if (state.currentRound == null) {
      return;
    }

    final result = _scoreEngine.scorePoint(
      currentScore: state.currentRound!.score,
      scoringTeam: TeamSide.a,
      scorer: scorer,
    );

    final updatedServe = _scoreEngine.updateServeRotation(
      currentServe: state.currentRound!.serveState,
      round: state.currentRound!,
    );

    final updatedRound = state.currentRound!.copyWith(
      score: result.newScore,
      serveState: updatedServe,
    );

    emit(
      state.copyWith(
        currentRound: updatedRound,
        canUndo: result.canUndo,
        status: result.isRoundComplete
            ? OrbitSessionStatus.roundComplete
            : OrbitSessionStatus.active,
      ),
    );
  }

  void scorePointForTeamB(Player scorer) {
    if (state.currentRound == null) {
      return;
    }

    final result = _scoreEngine.scorePoint(
      currentScore: state.currentRound!.score,
      scoringTeam: TeamSide.b,
      scorer: scorer,
    );

    final updatedServe = _scoreEngine.updateServeRotation(
      currentServe: state.currentRound!.serveState,
      round: state.currentRound!,
    );

    final updatedRound = state.currentRound!.copyWith(
      score: result.newScore,
      serveState: updatedServe,
    );

    emit(
      state.copyWith(
        currentRound: updatedRound,
        canUndo: result.canUndo,
        status: result.isRoundComplete
            ? OrbitSessionStatus.roundComplete
            : OrbitSessionStatus.active,
      ),
    );
  }

  void undoLastPoint() {
    if (state.currentRound == null || !state.canUndo) {
      return;
    }

    final result = _scoreEngine.undoLastPoint(
      currentScore: state.currentRound!.score,
    );

    final updatedRound = state.currentRound!.copyWith(score: result.newScore);

    emit(
      state.copyWith(
        currentRound: updatedRound,
        canUndo: result.canUndo,
        status: OrbitSessionStatus.active,
      ),
    );
  }

  void startNextRound() {
    if (state.currentRound == null) {
      return;
    }

    final updatedRounds = [
      ...state.session?.rounds ?? [],
      state.currentRound!.copyWith(status: RoundStatus.completed),
    ];

    final constraints = _buildConstraints();
    final rotationResult = _rotationAlgorithm.calculateNextRound(
      allParticipants: state.participants,
      completedRounds: updatedRounds,
      constraints: constraints,
      targetPoints: state.targetPoints,
    );

    final nextRoundNumber = (state.session?.rounds.length ?? 0) + 1;
    final round = _rotationAlgorithm.createRound(
      roundId: 'round_$nextRoundNumber',
      roundNumber: nextRoundNumber,
      rotationResult: rotationResult,
      targetPoints: state.targetPoints,
    );

    _updateLeaderboard(rotationResult);

    emit(
      state.copyWith(
        status: OrbitSessionStatus.active,
        currentRound: round,
        lastPairingReason: rotationResult.pairingReason,
        canUndo: false,
      ),
    );
  }

  void _updateLeaderboard(RotationResult rotationResult) {
    final entries = <LeaderboardEntry>[];

    for (final participant in state.participants) {
      final isInRound = rotationResult.courtPlayers.any(
        (p) => p.id == participant.id,
      );
      final isOnBench = rotationResult.benchPlayers.any(
        (p) => p.id == participant.id,
      );

      final roundPoints = isInRound
          ? state.currentRound?.score.teamAPoints ?? 0
          : 0;
      final wasOnWinningTeam =
          state.currentRound != null &&
          ((state.currentRound!.score.teamAPoints >=
                      state.currentRound!.score.targetPoints &&
                  rotationResult.teamA.players.any(
                    (p) => p.id == participant.id,
                  )) ||
              (state.currentRound!.score.teamBPoints >=
                      state.currentRound!.score.targetPoints &&
                  rotationResult.teamB.players.any(
                    (p) => p.id == participant.id,
                  )));

      final currentEntry = state.leaderboard
          .where((e) => e.playerId == participant.id)
          .firstOrNull;

      entries.add(
        LeaderboardEntry(
          playerId: participant.id,
          displayName: participant.displayName,
          avatar: participant.avatar,
          totalPoints: (currentEntry?.totalPoints ?? 0) + roundPoints,
          roundsWon:
              (currentEntry?.roundsWon ?? 0) + (wasOnWinningTeam ? 1 : 0),
          matchesPlayed:
              (currentEntry?.matchesPlayed ?? 0) + (isInRound ? 1 : 0),
          benchCount: (currentEntry?.benchCount ?? 0) + (isOnBench ? 1 : 0),
        ),
      );
    }

    entries.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));

    emit(state.copyWith(leaderboard: entries));
  }

  void endSession() {
    emit(state.copyWith(status: OrbitSessionStatus.sessionComplete));
  }

  void resetSession() {
    emit(const OrbitSessionState());
  }
}
