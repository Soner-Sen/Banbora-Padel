import 'package:sonrize_padel/core/game_engine/game_engine.dart';

import 'americano_participant.dart';
import 'court_position.dart';
import 'serving_state.dart';

/// A single match/round in an Americano session
class AmericanoMatch {
  AmericanoMatch({
    required this.id,
    required this.roundNumber,
    required this.teamA,
    required this.teamB,
    required this.targetPoints,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.status = MatchStatus.active,
    this.isComplete = false,
    this.winnerSide,
    this.pairingReason = '',
    this.servingTeam = TeamSide.a,
    this.serverRotationOrder = const [],
    this.pointsPlayed = 0,
    ServingState? servingState,
    CourtPosition? courtPosition,
    List<AmericanoParticipant>? benchPlayers,
  }) : benchPlayers = benchPlayers ?? [],
       servingState =
           servingState ??
           ServingState.initial(
             serverRotationOrder: const [
               'player0',
               'player1',
               'player2',
               'player3',
             ],
             initialServingTeam: TeamSide.a,
           ),
       courtPosition =
           courtPosition ??
           _computeInitialCourtPosition(
             teamA,
             teamB,
             serverRotationOrder,
             servingState,
           );

  final String id;
  final int roundNumber;
  final List<AmericanoParticipant> teamA;
  final List<AmericanoParticipant> teamB;
  final int targetPoints;
  final int teamAScore;
  final int teamBScore;
  final MatchStatus status;
  final bool isComplete;
  final TeamSide? winnerSide;
  final String pairingReason;

  /// Which team serves first (determined by coin toss)
  final TeamSide servingTeam;

  /// Server rotation order: [Player0_ID, Player2_ID, Player1_ID, Player3_ID]
  /// This defines who serves in sequence: 0→1→2→3→0 (repeating every 8 points)
  /// Where Player0,Player1 are Team A and Player2,Player3 are Team B
  final List<String> serverRotationOrder;

  /// Total points played in this match
  final int pointsPlayed;

  /// Current serving state computed from pointsPlayed
  final ServingState servingState;

  /// Current court positions for all 4 players
  final CourtPosition courtPosition;

  final List<AmericanoParticipant> benchPlayers;

  AmericanoMatch copyWith({
    String? id,
    int? roundNumber,
    List<AmericanoParticipant>? teamA,
    List<AmericanoParticipant>? teamB,
    int? targetPoints,
    int? teamAScore,
    int? teamBScore,
    MatchStatus? status,
    bool? isComplete,
    TeamSide? winnerSide,
    String? pairingReason,
    TeamSide? servingTeam,
    List<String>? serverRotationOrder,
    int? pointsPlayed,
    ServingState? servingState,
    CourtPosition? courtPosition,
    List<AmericanoParticipant>? benchPlayers,
  }) => AmericanoMatch(
    id: id ?? this.id,
    roundNumber: roundNumber ?? this.roundNumber,
    teamA: teamA ?? this.teamA,
    teamB: teamB ?? this.teamB,
    targetPoints: targetPoints ?? this.targetPoints,
    teamAScore: teamAScore ?? this.teamAScore,
    teamBScore: teamBScore ?? this.teamBScore,
    status: status ?? this.status,
    isComplete: isComplete ?? this.isComplete,
    winnerSide: winnerSide ?? this.winnerSide,
    pairingReason: pairingReason ?? this.pairingReason,
    servingTeam: servingTeam ?? this.servingTeam,
    serverRotationOrder: serverRotationOrder ?? this.serverRotationOrder,
    pointsPlayed: pointsPlayed ?? this.pointsPlayed,
    servingState: servingState ?? this.servingState,
    courtPosition: courtPosition ?? this.courtPosition,
    benchPlayers: benchPlayers ?? this.benchPlayers,
  );

  /// Calculate points earned by each player based on match score
  /// Team A wins 16:7 → Player A+B each get 16 points, Player C+D each get 7
  Map<String, int> getPointsForPlayers() {
    final points = <String, int>{};
    for (final player in teamA) {
      points[player.id] = teamAScore;
    }
    for (final player in teamB) {
      points[player.id] = teamBScore;
    }
    return points;
  }

  List<AmericanoParticipant> get allPlayers => [...teamA, ...teamB];

  /// Returns the serving player based on servingState
  AmericanoParticipant? get currentServer {
    if (serverRotationOrder.isEmpty) {
      return null;
    }

    final serverIndex = servingState.currentServerIndex;
    if (serverIndex >= serverRotationOrder.length) {
      return null;
    }

    final serverId = serverRotationOrder[serverIndex];
    return [
      ...teamA,
      ...teamB,
    ].firstWhere((p) => p.id == serverId, orElse: () => teamA.first);
  }

  CompletedRound toCompletedRound() => CompletedRound(
    roundNumber: roundNumber,
    teamAPlayerIds: teamA.map((p) => p.id).toList(),
    teamBPlayerIds: teamB.map((p) => p.id).toList(),
    benchPlayerIds: benchPlayers.map((p) => p.id).toList(),
    teamAScore: teamAScore,
    teamBScore: teamBScore,
    winnerSide: winnerSide,
  );

  /// Computes initial court position from serving state
  static CourtPosition _computeInitialCourtPosition(
    List<AmericanoParticipant> teamA,
    List<AmericanoParticipant> teamB,
    List<String> serverRotationOrder,
    ServingState? servingState,
  ) {
    if (teamA.length < 2 || teamB.length < 2) {
      return CourtPosition(
        teamALeftPlayerId: teamA.isNotEmpty ? teamA[0].id : '',
        teamARightPlayerId: teamA.length > 1 ? teamA[1].id : '',
        teamBLeftPlayerId: teamB.isNotEmpty ? teamB[0].id : '',
        teamBRightPlayerId: teamB.length > 1 ? teamB[1].id : '',
      );
    }

    final state =
        servingState ??
        ServingState.initial(
          serverRotationOrder: serverRotationOrder,
          initialServingTeam: TeamSide.a,
        );

    const helper = CourtPositionHelper();
    return helper.compute(
      teamA: teamA,
      teamB: teamB,
      servingState: state,
      serverRotationOrder: serverRotationOrder,
    );
  }
}

enum MatchStatus { pending, active, paused, completed }
