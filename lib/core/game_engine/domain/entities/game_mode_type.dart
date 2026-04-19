/// Game modes available in the Padel app
enum GameModeType {
  /// Points-based rotation mode (4-10 players)
  /// Players accumulate points based on match scores
  /// Team partners and opponents rotate fairly
  americano,

  /// Win-based rotation mode (same as Americano but win-focused)
  /// Ranking primarily by wins, then points as tiebreaker
  /// Draws possible
  liga,

  /// Standard Padel match with official rules
  /// Two teams, configurable target score
  normal,

  /// Standard match with random surprise challenges
  /// Challenges appear every X points
  chaosRally;

  String get displayName {
    switch (this) {
      case GameModeType.americano:
        return 'Americano';
      case GameModeType.liga:
        return 'Liga';
      case GameModeType.normal:
        return 'Normal';
      case GameModeType.chaosRally:
        return 'Chaos Rally';
    }
  }

  String get subtitle {
    switch (this) {
      case GameModeType.americano:
        return 'Punkte sammeln, Teams rotieren';
      case GameModeType.liga:
        return 'Gewinne zählen, fair rotieren';
      case GameModeType.normal:
        return 'Klassisches Padel Match';
      case GameModeType.chaosRally:
        return 'Spaß mit Überraschungen';
    }
  }

  String get iconName {
    switch (this) {
      case GameModeType.americano:
        return 'scoreboard';
      case GameModeType.liga:
        return 'emoji_events';
      case GameModeType.normal:
        return 'sports_tennis';
      case GameModeType.chaosRally:
        return 'casino';
    }
  }

  int get minPlayers {
    switch (this) {
      case GameModeType.americano:
      case GameModeType.liga:
        return 4;
      case GameModeType.normal:
        return 4;
      case GameModeType.chaosRally:
        return 4;
    }
  }

  int get maxPlayers {
    switch (this) {
      case GameModeType.americano:
      case GameModeType.liga:
        return 10;
      case GameModeType.normal:
        return 4;
      case GameModeType.chaosRally:
        return 4;
    }
  }

  bool get usesRotation {
    switch (this) {
      case GameModeType.americano:
      case GameModeType.liga:
        return true;
      case GameModeType.normal:
      case GameModeType.chaosRally:
        return false;
    }
  }

  bool get hasLeaderboard {
    switch (this) {
      case GameModeType.americano:
      case GameModeType.liga:
        return true;
      case GameModeType.normal:
      case GameModeType.chaosRally:
        return false;
    }
  }
}
