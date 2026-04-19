import 'americano_match.dart';
import 'americano_participant.dart';

/// Complete Americano session containing all participants, matches, and configuration
class AmericanoSession {
  const AmericanoSession({
    required this.id,
    required this.participants,
    required this.targetPoints,
    this.matches = const [],
    this.status = SessionStatus.lobby,
    this.createdAt,
    this.currentRoundNumber = 0,
  });

  final String id;
  final List<AmericanoParticipant> participants;
  final int targetPoints;
  final List<AmericanoMatch> matches;
  final SessionStatus status;
  final DateTime? createdAt;
  final int currentRoundNumber;

  AmericanoSession copyWith({
    String? id,
    List<AmericanoParticipant>? participants,
    int? targetPoints,
    List<AmericanoMatch>? matches,
    SessionStatus? status,
    DateTime? createdAt,
    int? currentRoundNumber,
  }) => AmericanoSession(
    id: id ?? this.id,
    participants: participants ?? this.participants,
    targetPoints: targetPoints ?? this.targetPoints,
    matches: matches ?? this.matches,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    currentRoundNumber: currentRoundNumber ?? this.currentRoundNumber,
  );

  AmericanoMatch? get currentMatch {
    if (matches.isEmpty) {
      return null;
    }
    return matches.lastWhere(
      (m) => m.status == MatchStatus.active,
      orElse: () => matches.last,
    );
  }

  List<AmericanoMatch> get completedMatches =>
      matches.where((m) => m.isComplete).toList();

  int get totalRoundsPlayed => completedMatches.length;

  bool get isComplete => status == SessionStatus.completed;
}

enum SessionStatus { lobby, inProgress, paused, completed }
