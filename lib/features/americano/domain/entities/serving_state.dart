import 'package:sonrize_padel/core/game_engine/game_engine.dart';

/// Court side for positioning players
enum CourtSide {
  /// Right side of the court (from server's perspective)
  right,

  /// Left side of the court (from server's perspective)
  left,
}

/// Represents the complete serving state for a match at any point in time
class ServingState {
  const ServingState({
    required this.currentServerIndex,
    required this.servingTeam,
    required this.pointInServiceCycle,
    required this.serverSide,
  });

  /// Creates the initial serving state
  /// [serverRotationOrder] is the ordered list of participant IDs serving in rotation
  /// [initialServingTeam] determines which team serves first
  factory ServingState.initial({
    required List<String> serverRotationOrder,
    required TeamSide initialServingTeam,
  }) {
    if (serverRotationOrder.isEmpty) {
      throw ArgumentError('serverRotationOrder cannot be empty');
    }

    return ServingState(
      currentServerIndex: 0,
      servingTeam: initialServingTeam,
      pointInServiceCycle: 0,
      serverSide: CourtSide.right,
    );
  }

  /// Index 0-3 representing the current server in rotation order
  /// 0=First player in rotation, 1=Second, 2=Third, 3=Fourth
  final int currentServerIndex;

  /// Which team is currently serving
  final TeamSide servingTeam;

  /// 0 = first point of the 2-point cycle (server starts on right)
  /// 1 = second point (server on left, sides swapped with partner)
  final int pointInServiceCycle;

  /// Which court side the server is on
  /// Point 0: right (Deuce side)
  /// Point 1: left (Ad side, after swap with partner)
  final CourtSide serverSide;

  /// Returns true if this is the first point of the 2-point service cycle
  bool get isFirstPointInCycle => pointInServiceCycle == 0;

  /// Returns true if this is the second point (sides have been swapped)
  bool get isSecondPointInCycle => pointInServiceCycle == 1;

  ServingState copyWith({
    int? currentServerIndex,
    TeamSide? servingTeam,
    int? pointInServiceCycle,
    CourtSide? serverSide,
  }) => ServingState(
    currentServerIndex: currentServerIndex ?? this.currentServerIndex,
    servingTeam: servingTeam ?? this.servingTeam,
    pointInServiceCycle: pointInServiceCycle ?? this.pointInServiceCycle,
    serverSide: serverSide ?? this.serverSide,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ServingState &&
        other.currentServerIndex == currentServerIndex &&
        other.servingTeam == servingTeam &&
        other.pointInServiceCycle == pointInServiceCycle &&
        other.serverSide == serverSide;
  }

  @override
  int get hashCode => Object.hash(
    currentServerIndex,
    servingTeam,
    pointInServiceCycle,
    serverSide,
  );

  @override
  String toString() =>
      'ServingState(serverIndex: $currentServerIndex, team: $servingTeam, '
      'pointInCycle: $pointInServiceCycle, side: $serverSide)';
}
