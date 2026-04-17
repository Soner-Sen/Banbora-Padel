import 'package:equatable/equatable.dart';

class GuestUser extends Equatable {
  const GuestUser({
    required this.id,
    required this.displayName,
    this.avatarColor,
    this.deviceId,
  });

  final String id;
  final String displayName;
  final int? avatarColor;
  final String? deviceId;

  String get initials {
    final words = displayName.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  bool get isGuest => true;

  GuestUser copyWith({
    String? id,
    String? displayName,
    int? avatarColor,
    String? deviceId,
  }) => GuestUser(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    avatarColor: avatarColor ?? this.avatarColor,
    deviceId: deviceId ?? this.deviceId,
  );

  @override
  List<Object?> get props => [id, displayName, avatarColor, deviceId];
}
