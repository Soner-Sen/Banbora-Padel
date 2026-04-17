import '../entities/entities.dart';

class ScoreUpdateResult {
  const ScoreUpdateResult({
    required this.newScore,
    this.event,
    this.canUndo = true,
    this.isRoundComplete = false,
  });
  final Score newScore;
  final ScoreEvent? event;
  final bool canUndo;
  final bool isRoundComplete;
}

class ScoreEngine {
  static const int _pointsPerRally = 1;
  static const int _servesPerTurn = 2;

  ScoreUpdateResult scorePoint({
    required Score currentScore,
    required TeamSide scoringTeam,
    required Player scorer,
  }) {
    if (currentScore.status != ScoreStatus.active) {
      return ScoreUpdateResult(
        newScore: currentScore,
        canUndo: false,
        isRoundComplete: currentScore.status == ScoreStatus.completed,
      );
    }

    final timeline = List<ScoreEvent>.from(currentScore.timeline);
    final newServeCount = currentScore.serveCount + 1;

    final teamAPointsBefore = currentScore.teamAPoints;
    final teamBPointsBefore = currentScore.teamBPoints;

    int newTeamAPoints = teamAPointsBefore;
    int newTeamBPoints = teamBPointsBefore;

    if (scoringTeam == TeamSide.a) {
      newTeamAPoints = teamAPointsBefore + _pointsPerRally;
    } else {
      newTeamBPoints = teamBPointsBefore + _pointsPerRally;
    }

    final event = ScoreEvent(
      playerId: scorer.id,
      scoringTeam: scoringTeam,
      teamAPointsBefore: teamAPointsBefore,
      teamBPointsBefore: teamBPointsBefore,
      teamAPointsAfter: newTeamAPoints,
      teamBPointsAfter: newTeamBPoints,
      timestamp: DateTime.now(),
    );
    timeline.add(event);

    final targetReached =
        newTeamAPoints >= currentScore.targetPoints ||
        newTeamBPoints >= currentScore.targetPoints;

    final newScore = currentScore.copyWith(
      teamAPoints: newTeamAPoints,
      teamBPoints: newTeamBPoints,
      timeline: timeline,
      serveCount: newServeCount,
      status: targetReached ? ScoreStatus.completed : ScoreStatus.active,
    );

    return ScoreUpdateResult(
      newScore: newScore,
      event: event,
      canUndo: true,
      isRoundComplete: targetReached,
    );
  }

  ScoreUpdateResult undoLastPoint({required Score currentScore}) {
    if (currentScore.timeline.isEmpty) {
      return ScoreUpdateResult(
        newScore: currentScore,
        canUndo: false,
        isRoundComplete: currentScore.status == ScoreStatus.completed,
      );
    }

    final timeline = List<ScoreEvent>.from(currentScore.timeline);
    final lastEvent = timeline.removeLast();

    final undoneEvent = ScoreEvent(
      playerId: lastEvent.playerId,
      scoringTeam: lastEvent.scoringTeam,
      teamAPointsBefore: lastEvent.teamAPointsBefore,
      teamBPointsBefore: lastEvent.teamBPointsBefore,
      teamAPointsAfter: lastEvent.teamAPointsAfter,
      teamBPointsAfter: lastEvent.teamBPointsAfter,
      timestamp: DateTime.now(),
      wasUndone: true,
    );
    timeline[timeline.length - 1] = undoneEvent;

    final newScore = currentScore.copyWith(
      teamAPoints: lastEvent.teamAPointsBefore,
      teamBPoints: lastEvent.teamBPointsBefore,
      timeline: timeline,
      status: ScoreStatus.active,
    );

    return ScoreUpdateResult(
      newScore: newScore,
      event: undoneEvent,
      canUndo: timeline.isNotEmpty,
      isRoundComplete: false,
    );
  }

  ServeState updateServeRotation({
    required ServeState currentServe,
    required Round round,
  }) {
    final pointsServed = currentServe.pointsServedThisTurn;
    final teamA = round.teamA;
    final teamB = round.teamB;

    if (pointsServed >= _servesPerTurn - 1) {
      return _rotateServer(
        currentServe,
        round.players,
        teamA.players,
        teamB.players,
      );
    }

    return currentServe.copyWith(
      pointsServedThisTurn: pointsServed + 1,
      isFirstServe: pointsServed == 0,
    );
  }

  ServeState _rotateServer(
    ServeState currentServe,
    List<Player> allPlayers,
    List<Player> teamAPlayers,
    List<Player> teamBPlayers,
  ) {
    final currentServer = currentServe.currentServer;
    if (currentServer == null) {
      return currentServe.copyWith(
        pointsServedThisTurn: 0,
        currentServePosition: ServePosition.right,
      );
    }

    final allIndex = allPlayers.indexWhere((p) => p.id == currentServer.id);
    final nextIndex = (allIndex + 1) % allPlayers.length;
    final nextServer = allPlayers[nextIndex];

    final returner =
        nextServer.position == PlayerPosition.teamAPlayer1 ||
            nextServer.position == PlayerPosition.teamAPlayer2
        ? teamBPlayers.first
        : teamAPlayers.first;

    final nextPosition =
        currentServe.currentServePosition == ServePosition.right
        ? ServePosition.left
        : ServePosition.right;

    return ServeState(
      currentServer: nextServer,
      currentReturner: returner,
      pointsServedThisTurn: 0,
      currentServePosition: nextPosition,
      isFirstServe: true,
    );
  }
}
