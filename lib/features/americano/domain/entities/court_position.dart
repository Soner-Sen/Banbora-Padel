import 'package:sonrize_padel/core/game_engine/game_engine.dart';

import 'americano_participant.dart';
import 'serving_state.dart';

/// Represents the court positions for all 4 players at any point
class CourtPosition {
  const CourtPosition({
    required this.teamALeftPlayerId,
    required this.teamARightPlayerId,
    required this.teamBLeftPlayerId,
    required this.teamBRightPlayerId,
  });

  /// Team A left side player ID
  final String teamALeftPlayerId;

  /// Team A right side player ID
  final String teamARightPlayerId;

  /// Team B left side player ID
  final String teamBLeftPlayerId;

  /// Team B right side player ID
  final String teamBRightPlayerId;

  /// Returns the player ID for the given team and side
  String getPlayerId(TeamSide team, CourtSide side) {
    if (team == TeamSide.a) {
      return side == CourtSide.left ? teamALeftPlayerId : teamARightPlayerId;
    } else {
      return side == CourtSide.left ? teamBLeftPlayerId : teamBRightPlayerId;
    }
  }

  /// Returns the server ID based on the serving state
  String getServerId(List<String> serverRotationOrder) {
    if (serverRotationOrder.isEmpty) {
      return '';
    }
    final index = 0.clamp(0, serverRotationOrder.length - 1);
    return serverRotationOrder[index];
  }

  /// Returns the partner ID of the server
  String getPartnerId(List<String> serverRotationOrder) {
    if (serverRotationOrder.length < 2) {
      return '';
    }
    return serverRotationOrder[1];
  }

  CourtPosition copyWith({
    String? teamALeftPlayerId,
    String? teamARightPlayerId,
    String? teamBLeftPlayerId,
    String? teamBRightPlayerId,
  }) => CourtPosition(
    teamALeftPlayerId: teamALeftPlayerId ?? this.teamALeftPlayerId,
    teamARightPlayerId: teamARightPlayerId ?? this.teamARightPlayerId,
    teamBLeftPlayerId: teamBLeftPlayerId ?? this.teamBLeftPlayerId,
    teamBRightPlayerId: teamBRightPlayerId ?? this.teamBRightPlayerId,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CourtPosition &&
        other.teamALeftPlayerId == teamALeftPlayerId &&
        other.teamARightPlayerId == teamARightPlayerId &&
        other.teamBLeftPlayerId == teamBLeftPlayerId &&
        other.teamBRightPlayerId == teamBRightPlayerId;
  }

  @override
  int get hashCode => Object.hash(
    teamALeftPlayerId,
    teamARightPlayerId,
    teamBLeftPlayerId,
    teamBRightPlayerId,
  );
}

/// Helper to compute court positions based on serving state
class CourtPositionHelper {
  const CourtPositionHelper();

  /// Computes court positions for all 4 players given the serving state
  ///
  /// [teamA] - Team A participants
  /// [teamB] - Team B participants
  /// [servingState] - Current serving state
  /// [serverRotationOrder] - Ordered list of player IDs in rotation [P0, P2, P1, P3]
  ///                         where P0,P1 are Team A and P2,P3 are Team B
  CourtPosition compute({
    required List<AmericanoParticipant> teamA,
    required List<AmericanoParticipant> teamB,
    required ServingState servingState,
    required List<String> serverRotationOrder,
  }) {
    if (teamA.length < 2 || teamB.length < 2) {
      throw ArgumentError('Each team must have at least 2 players');
    }
    if (serverRotationOrder.length < 4) {
      throw ArgumentError('serverRotationOrder must have 4 players');
    }

    // Get server and partner from rotation order based on current server index
    final serverId = serverRotationOrder[servingState.currentServerIndex];

    // Determine which team the server is on and get partner
    final isServerOnTeamA = teamA.any((p) => p.id == serverId);
    final servingTeamPlayers = isServerOnTeamA ? teamA : teamB;
    final partnerId = servingTeamPlayers
        .firstWhere(
          (p) => p.id != serverId,
          orElse: () => servingTeamPlayers.first,
        )
        .id;

    // Point 0 (first of 2-point cycle):
    // - Team A serves: server starts on LEFT side
    // - Team B serves: server starts on RIGHT side (standard)
    // Point 1: server and partner swap sides
    final isFirstPoint = servingState.pointInServiceCycle == 0;

    String serverLeftId;
    String serverRightId;

    if (isFirstPoint) {
      if (isServerOnTeamA) {
        // Team A serves first point: server on LEFT
        serverLeftId = serverId;
        serverRightId = partnerId;
      } else {
        // Team B serves first point: server on RIGHT (standard)
        serverRightId = serverId;
        serverLeftId = partnerId;
      }
    } else {
      // Point 1: sides swap - server and partner exchange positions
      if (isServerOnTeamA) {
        // Team A serves second point: server on RIGHT (swapped)
        serverRightId = serverId;
        serverLeftId = partnerId;
      } else {
        // Team B serves second point: server on LEFT (swapped)
        serverLeftId = serverId;
        serverRightId = partnerId;
      }
    }

    // Build the non-serving team's positions (opposite sides)
    final nonServingTeamPlayers = isServerOnTeamA ? teamB : teamA;
    final nonServerLeft = nonServingTeamPlayers[0].id;
    final nonServerRight = nonServingTeamPlayers[1].id;

    if (isServerOnTeamA) {
      return CourtPosition(
        teamALeftPlayerId: serverLeftId,
        teamARightPlayerId: serverRightId,
        teamBLeftPlayerId: nonServerLeft,
        teamBRightPlayerId: nonServerRight,
      );
    } else {
      return CourtPosition(
        teamALeftPlayerId: nonServerLeft,
        teamARightPlayerId: nonServerRight,
        teamBLeftPlayerId: serverLeftId,
        teamBRightPlayerId: serverRightId,
      );
    }
  }

  /// Gets the server participant from the serving state
  AmericanoParticipant? getServer({
    required List<AmericanoParticipant> teamA,
    required List<AmericanoParticipant> teamB,
    required ServingState servingState,
    required List<String> serverRotationOrder,
  }) {
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
}
