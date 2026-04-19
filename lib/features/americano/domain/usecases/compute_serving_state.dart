import 'package:sonrize_padel/core/game_engine/game_engine.dart';

import '../entities/serving_state.dart';

/// Use case to compute the serving state based on points played
/// 
/// The core algorithm: serverIndex = pointsPlayed ~/ 2 % 4
/// This produces the rotation: Player0 → Player1 → Player2 → Player3 → Player0
///
/// Each player serves 2 points in their block:
/// - Point 1 (even): Server starts on Right (Deuce) side
/// - Point 2 (odd): Server and partner swap, server on Left (Ad) side
///
/// After 2 points (4 total points played), service goes to the other team.
class ComputeServingStateUseCase {
  const ComputeServingStateUseCase();

  /// Computes the serving state for a given point number
  /// 
  /// [pointsPlayed] - Number of points already played (0-based index)
  /// [serverRotationOrder] - Ordered list of player IDs [P0, P2, P1, P3]
  ///                         where P0,P1 are Team A and P2,P3 are Team B
  /// [initialServingTeam] - Which team serves first (TeamSide.a or TeamSide.b)
  ServingState execute({
    required int pointsPlayed,
    required List<String> serverRotationOrder,
    required TeamSide initialServingTeam,
  }) {
    if (serverRotationOrder.isEmpty) {
      throw ArgumentError('serverRotationOrder cannot be empty');
    }

    // 0-based point index
    final pointIndex = pointsPlayed;

    // Determine which server in the rotation (0, 1, 2, 3, 0, 1, 2, 3...)
    // Formula: serverIndex = pointIndex ~/ 2 % 4
    final serverIndex = pointIndex ~/ 2 % serverRotationOrder.length;

    // Point within 2-point cycle: 0 = first serve (right), 1 = second serve (left)
    final pointInCycle = pointIndex % 2;

    // Server side based on point in cycle
    // Point 0: right, Point 1: left (sides swapped after point 1)
    final serverSide = pointInCycle == 0 ? CourtSide.right : CourtSide.left;

    // Serving team alternates every 4 points (2 points per server × 2 servers per team)
    // Points 0-3: Initial team, Points 4-7: Other team
    final cycleNumber = pointIndex ~/ 4;
    final isInitialTeamServing = cycleNumber % 2 == 0;
    
    // Determine which team is serving based on initial serving team
    final TeamSide servingTeam;
    if (initialServingTeam == TeamSide.a) {
      servingTeam = isInitialTeamServing ? TeamSide.a : TeamSide.b;
    } else {
      servingTeam = isInitialTeamServing ? TeamSide.b : TeamSide.a;
    }

    return ServingState(
      currentServerIndex: serverIndex,
      servingTeam: servingTeam,
      pointInServiceCycle: pointInCycle,
      serverSide: serverSide,
    );
  }

  /// Verifies the serving state for a sequence of points
  /// Returns a map of point number to expected serving state
  Map<int, ServingState> verifySequence({
    required int startPoint,
    required int count,
    required List<String> serverRotationOrder,
    required TeamSide initialServingTeam,
  }) {
    final result = <int, ServingState>{};
    for (int i = startPoint; i < startPoint + count; i++) {
      result[i] = execute(
        pointsPlayed: i,
        serverRotationOrder: serverRotationOrder,
        initialServingTeam: initialServingTeam,
      );
    }
    return result;
  }
}