import 'game_player.dart';

enum TeamSide { a, b }

class GameTeam {
  const GameTeam({
    required this.players,
    required this.side,
    this.isServing = false,
  });

  final List<GamePlayer> players;
  final TeamSide side;
  final bool isServing;

  GameTeam copyWith({
    List<GamePlayer>? players,
    TeamSide? side,
    bool? isServing,
  }) => GameTeam(
    players: players ?? this.players,
    side: side ?? this.side,
    isServing: isServing ?? this.isServing,
  );

  String get sideLabel => side == TeamSide.a ? 'Team A' : 'Team B';

  bool containsPlayer(String playerId) => players.any((p) => p.id == playerId);

  GamePlayer? getPartner(String playerId) {
    final index = players.indexWhere((p) => p.id == playerId);
    if (index == -1) {
      return null;
    }
    return players[index == 0 ? 1 : 0];
  }
}
