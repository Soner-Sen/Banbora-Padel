import 'package:flutter/material.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';

class PadelCourtWidget extends StatelessWidget {
  const PadelCourtWidget({
    this.teamAPositions,
    this.teamBPositions,
    this.serverIndex,
    this.width,
    this.height,
    super.key,
  });

  final List<PlayerPosition>? teamAPositions;
  final List<PlayerPosition>? teamBPositions;
  final int? serverIndex;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    width: width ?? 300,
    height: height ?? 200,
    decoration: BoxDecoration(
      color: DesignTokens.courtBase,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(
        color: DesignTokens.courtLine.withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Stack(
      children: [
        _buildCourtLines(),
        _buildNet(),
        if (teamAPositions != null)
          ..._buildPlayers(teamAPositions!, DesignTokens.teamA),
        if (teamBPositions != null)
          ..._buildPlayers(teamBPositions!, DesignTokens.teamB),
      ],
    ),
  );

  Widget _buildCourtLines() => CustomPaint(
    size: Size(width ?? 300, height ?? 200),
    painter: _CourtLinesPainter(),
  );

  Widget _buildNet() => Center(child: Container(height: 3, color: DesignTokens.courtNet));

  List<Widget> _buildPlayers(List<PlayerPosition> positions, Color teamColor) => positions.asMap().entries.map((entry) {
    final index = entry.key;
    final position = entry.value;
    final isServer = serverIndex == index;

    return Positioned(
      left: position.x,
      top: position.y,
      child: _PlayerAvatar(
        name: position.name,
        initials: position.initials,
        color: teamColor,
        isServer: isServer,
      ),
    );
  }).toList();
}

class PlayerPosition {
  const PlayerPosition({
    required this.name,
    required this.x,
    required this.y,
    this.initials,
  });

  final String name;
  final String? initials;
  final double x;
  final double y;
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.name,
    required this.color,
    this.initials,
    this.isServer = false,
  });

  final String name;
  final Color color;
  final String? initials;
  final bool isServer;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isServer ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                initials ?? (name.isNotEmpty ? name[0].toUpperCase() : '?'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isServer)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1),
                  ),
                  child: const Icon(
                    Icons.sports_tennis,
                    size: 8,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DesignTokens.courtLine.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final courtPadding = size.width * 0.08;
    final courtWidth = size.width - (courtPadding * 2);
    final courtHeight = size.height - (courtPadding * 2);

    // Court outer rectangle
    canvas.drawRect(
      Rect.fromLTWH(courtPadding, courtPadding, courtWidth, courtHeight),
      paint,
    );

    // Center line (net)
    canvas.drawLine(
      Offset(courtPadding, size.height / 2),
      Offset(courtPadding + courtWidth, size.height / 2),
      paint,
    );

    // Service boxes
    final serviceLineOffset = courtWidth * 0.3;

    // Left service line
    canvas.drawLine(
      Offset(courtPadding + serviceLineOffset, courtPadding),
      Offset(courtPadding + serviceLineOffset, courtPadding + courtHeight),
      paint..strokeWidth = 1,
    );

    // Right service line
    canvas.drawLine(
      Offset(courtPadding + courtWidth - serviceLineOffset, courtPadding),
      Offset(
        courtPadding + courtWidth - serviceLineOffset,
        courtPadding + courtHeight,
      ),
      paint,
    );

    // Center service line
    canvas.drawLine(
      Offset(courtPadding + serviceLineOffset, size.height / 2),
      Offset(courtPadding + courtWidth - serviceLineOffset, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
