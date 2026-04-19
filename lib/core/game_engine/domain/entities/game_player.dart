/// Shared player entity for all game modes
class GamePlayer {
  const GamePlayer({
    required this.id,
    required this.displayName,
    this.avatar = GamePlayerAvatar.avatar1,
    this.isGuest = false,
    this.deviceId,
    this.skillLevel,
  });

  final String id;
  final String displayName;
  final GamePlayerAvatar avatar;
  final bool isGuest;
  final String? deviceId;
  final int? skillLevel;

  GamePlayer copyWith({
    String? id,
    String? displayName,
    GamePlayerAvatar? avatar,
    bool? isGuest,
    String? deviceId,
    int? skillLevel,
  }) =>
      GamePlayer(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        avatar: avatar ?? this.avatar,
        isGuest: isGuest ?? this.isGuest,
        deviceId: deviceId ?? this.deviceId,
        skillLevel: skillLevel ?? this.skillLevel,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePlayer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum GamePlayerAvatar {
  avatar1,
  avatar2,
  avatar3,
  avatar4,
  avatar5,
  avatar6,
  avatar7,
  avatar8,
  avatar9,
  avatar10;

  String get assetPath => 'assets/images/player_$name.svg';

  String get emoji {
    switch (this) {
      case GamePlayerAvatar.avatar1:
        return '🧑';
      case GamePlayerAvatar.avatar2:
        return '👩';
      case GamePlayerAvatar.avatar3:
        return '👨';
      case GamePlayerAvatar.avatar4:
        return '🧔';
      case GamePlayerAvatar.avatar5:
        return '👱';
      case GamePlayerAvatar.avatar6:
        return '👸';
      case GamePlayerAvatar.avatar7:
        return '🤴';
      case GamePlayerAvatar.avatar8:
        return '🧙';
      case GamePlayerAvatar.avatar9:
        return '🦸';
      case GamePlayerAvatar.avatar10:
        return '🧑‍🎓';
    }
  }
}
