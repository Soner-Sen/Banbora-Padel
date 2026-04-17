import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import 'player_avatar_widget.dart';

class CourtViewWidget extends StatelessWidget {
  const CourtViewWidget({
    required this.round,
    super.key,
    this.onTeamAScore,
    this.onTeamBScore,
    this.canScore = true,
  });
  final Round round;
  final VoidCallback? onTeamAScore;
  final VoidCallback? onTeamBScore;
  final bool canScore;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _buildCourt(context),
      const SizedBox(height: 16),
      _buildScoreButtons(context),
    ],
  );

  Widget _buildCourt(BuildContext context) => Container(
    width: double.infinity,
    height: 300,
    decoration: BoxDecoration(
      color: const Color(0xFF2E7D32),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Stack(children: [_buildCourtLines(), _buildNet(), _buildPlayers()]),
  );

  Widget _buildCourtLines() => CustomPaint(
    size: const Size(double.infinity, 300),
    painter: _CourtLinesPainter(),
  );

  Widget _buildNet() => Positioned(
    top: 148,
    left: 0,
    right: 0,
    child: Container(height: 4, color: Colors.white),
  );

  Widget _buildPlayers() {
    final teamAPlayers = round.teamA.players;
    final teamBPlayers = round.teamB.players;
    final currentServer = round.serveState.currentServer;

    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 40,
          child: PlayerAvatarWidget(
            player: teamAPlayers[0],
            isServing: currentServer?.id == teamAPlayers[0].id,
            isReturner: _isReturner(teamBPlayers, currentServer),
            size: 50,
          ),
        ),
        Positioned(
          top: 40,
          right: 40,
          child: PlayerAvatarWidget(
            player: teamAPlayers[1],
            isServing: currentServer?.id == teamAPlayers[1].id,
            isReturner: _isReturner(teamBPlayers, currentServer),
            size: 50,
          ),
        ),
        Positioned(
          bottom: 40,
          left: 40,
          child: PlayerAvatarWidget(
            player: teamBPlayers[0],
            isServing: currentServer?.id == teamBPlayers[0].id,
            isReturner: _isReturner(teamAPlayers, currentServer),
            size: 50,
          ),
        ),
        Positioned(
          bottom: 40,
          right: 40,
          child: PlayerAvatarWidget(
            player: teamBPlayers[1],
            isServing: currentServer?.id == teamBPlayers[1].id,
            isReturner: _isReturner(teamAPlayers, currentServer),
            size: 50,
          ),
        ),
      ],
    );
  }

  bool _isReturner(List<Player> players, Player? server) {
    if (server == null) {
      return false;
    }
    return players.any((p) => p.id == server.id);
  }

  Widget _buildScoreButtons(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ScoreButton(
          label: '+1',
          teamName: 'Team A',
          score: round.score.teamAPoints,
          color: const Color(0xFF1E88E5),
          onTap: canScore ? onTeamAScore : null,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _ScoreButton(
          label: '+1',
          teamName: 'Team B',
          score: round.score.teamBPoints,
          color: const Color(0xFFE53935),
          onTap: canScore ? onTeamBScore : null,
        ),
      ),
    ],
  );
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.label,
    required this.teamName,
    required this.score,
    required this.color,
    this.onTap,
  });
  final String label;
  final String teamName;
  final int score;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              teamName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final courtWidth = size.width * 0.8;
    final courtHeight = size.height * 0.8;
    final left = (size.width - courtWidth) / 2;
    final top = (size.height - courtHeight) / 2;
    final right = left + courtWidth;
    final bottom = top + courtHeight;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

    final centerX = size.width / 2;
    canvas.drawLine(Offset(centerX, top), Offset(centerX, bottom), paint);

    final serviceBoxWidth = courtWidth * 0.3;
    final serviceBoxHeight = courtHeight * 0.4;

    canvas.drawRect(
      Rect.fromLTRB(left, top, left + serviceBoxWidth, top + serviceBoxHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        right - serviceBoxWidth,
        top,
        right,
        top + serviceBoxHeight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        left,
        bottom - serviceBoxHeight,
        left + serviceBoxWidth,
        bottom,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        right - serviceBoxWidth,
        bottom - serviceBoxHeight,
        right,
        bottom,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
