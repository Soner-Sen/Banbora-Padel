enum SessionMode {
  orbit,
  classic,
  chaos;

  String get displayName {
    switch (this) {
      case SessionMode.orbit:
        return 'Orbit';
      case SessionMode.classic:
        return 'Classic';
      case SessionMode.chaos:
        return 'Chaos Rally';
    }
  }

  String get description {
    switch (this) {
      case SessionMode.orbit:
        return 'Faire Rotation für 4-10 Spieler';
      case SessionMode.classic:
        return 'Offizielle Padel-Regeln';
      case SessionMode.chaos:
        return 'Spaß-Modus mit Specials';
    }
  }
}
