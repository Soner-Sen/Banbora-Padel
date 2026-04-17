import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/design_system/app_widgets.dart';
import 'package:sonrize_padel/features/session/domain/entities/session_mode.dart';

class SessionCreateScreen extends StatefulWidget {
  const SessionCreateScreen({super.key});

  @override
  State<SessionCreateScreen> createState() => _SessionCreateScreenState();
}

class _SessionCreateScreenState extends State<SessionCreateScreen> {
  SessionMode _selectedMode = SessionMode.orbit;
  int _targetPoints = 12;
  final _playerNameController = TextEditingController();
  final List<String> _players = [];

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty && _players.length < 10) {
      setState(() {
        _players.add(name);
        _playerNameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _startSession() {
    if (_players.length >= 4) {
      context.push(
        '/orbit/lobby',
        extra: {
          'mode': _selectedMode,
          'targetPoints': _targetPoints,
          'players': _players,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Session erstellen'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeSelection(),
          const SizedBox(height: DesignTokens.spacing24),
          _buildPointTargetSelection(),
          const SizedBox(height: DesignTokens.spacing24),
          _buildPlayerSection(),
          const SizedBox(height: DesignTokens.spacing32),
          _buildStartButton(),
        ],
      ),
    ),
  );

  Widget _buildModeSelection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Spielmodus',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: DesignTokens.spacing12),
      Row(
        children: [
          Expanded(
            child: _ModeCard(
              title: 'Orbit',
              subtitle: 'Faire Rotation',
              icon: Icons.autorenew_rounded,
              color: DesignTokens.orbitPrimary,
              isSelected: _selectedMode == SessionMode.orbit,
              onTap: () => setState(() => _selectedMode = SessionMode.orbit),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing12),
          Expanded(
            child: _ModeCard(
              title: 'Classic',
              subtitle: 'Offizielle Regeln',
              icon: Icons.sports_tennis,
              color: DesignTokens.info,
              isSelected: _selectedMode == SessionMode.classic,
              onTap: () =>
                  setState(() => _selectedMode = SessionMode.classic),
            ),
          ),
        ],
      ),
      const SizedBox(height: DesignTokens.spacing12),
      _ModeCard(
        title: 'Chaos Rally',
        subtitle: 'Spaß-Modus mit Specials',
        icon: Icons.casino_rounded,
        color: DesignTokens.secondary,
        isSelected: _selectedMode == SessionMode.chaos,
        onTap: () => setState(() => _selectedMode = SessionMode.chaos),
        isWide: true,
      ),
    ],
  );

  Widget _buildPointTargetSelection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Punkteziel',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: DesignTokens.spacing12),
      Row(
        children: [
          _PointChip(
            label: '12',
            isSelected: _targetPoints == 12,
            onTap: () => setState(() => _targetPoints = 12),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          _PointChip(
            label: '16',
            isSelected: _targetPoints == 16,
            onTap: () => setState(() => _targetPoints = 16),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          _PointChip(
            label: 'Custom',
            isSelected: _targetPoints == 0,
            onTap: () => setState(() => _targetPoints = 0),
          ),
        ],
      ),
    ],
  );

  Widget _buildPlayerSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Spieler (${_players.length}/10)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (_players.length < 4)
            Text(
              'Mindestens 4 nötig',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: DesignTokens.warning),
            ),
        ],
      ),
      const SizedBox(height: DesignTokens.spacing12),
      Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _playerNameController,
              hint: 'Spielername eingeben',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addPlayer(),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          AppIconButton(
            icon: Icons.add,
            onPressed: _addPlayer,
            color: DesignTokens.orbitPrimary,
          ),
        ],
      ),
      const SizedBox(height: DesignTokens.spacing12),
      Wrap(
        spacing: DesignTokens.spacing8,
        runSpacing: DesignTokens.spacing8,
        children: [
          for (int i = 0; i < _players.length; i++)
            _PlayerChip(name: _players[i], onRemove: () => _removePlayer(i)),
        ],
      ),
    ],
  );

  Widget _buildStartButton() {
    final canStart = _players.length >= 4;

    return AppButton(
      label: _players.length < 4
          ? 'Mindestens ${4 - _players.length} Spieler hinzufügen'
          : 'Session starten',
      onPressed: canStart ? _startSession : null,
      icon: Icons.play_arrow_rounded,
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.isWide = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isWide;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: isWide
        ? Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          )
        : Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: DesignTokens.spacing8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: DesignTokens.spacing8),
                  child: Icon(Icons.check_circle, color: color, size: 20),
                ),
            ],
          ),
  );
}

class _PointChip extends StatelessWidget {
  const _PointChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing16,
        vertical: DesignTokens.spacing12,
      ),
      decoration: BoxDecoration(
        color: isSelected ? DesignTokens.orbitPrimary : DesignTokens.elevated,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: isSelected
              ? DesignTokens.orbitPrimary
              : DesignTokens.surfaceVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? DesignTokens.textOnPrimary
              : DesignTokens.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spacing12,
      vertical: DesignTokens.spacing8,
    ),
    decoration: BoxDecoration(
      color: DesignTokens.elevated,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: DesignTokens.orbitPrimary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: DesignTokens.orbitPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spacing8),
        Text(name, style: const TextStyle(color: DesignTokens.textPrimary)),
        const SizedBox(width: DesignTokens.spacing4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 16, color: DesignTokens.textMuted),
        ),
      ],
    ),
  );
}

class ClassicRulesScreen extends StatelessWidget {
  const ClassicRulesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Classic Regeln')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing8),
                      decoration: BoxDecoration(
                        color: DesignTokens.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.sports_tennis,
                        color: DesignTokens.info,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing12),
                    Text(
                      'Offizielle Padel-Regeln',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing16),
                _buildRuleItem(
                  context,
                  'Doppel',
                  'Padel wird als Doppel gespielt (2 gegen 2).',
                ),
                _buildRuleItem(
                  context,
                  'Spielfeld',
                  '10 x 20 Meter, umschlossen mit Wänden und Metallgitter.',
                ),
                _buildRuleItem(
                  context,
                  'Aufschlag',
                  'Unterhand, unter Hüfthöhe, diagonal ins Aufschlagfeld.',
                ),
                _buildRuleItem(
                  context,
                  'Zählweise',
                  '15, 30, 40, Spiel. Bei Deuce 2 Punkte Vorsprung nötig.',
                ),
                _buildRuleItem(
                  context,
                  'Sätze',
                  'Bis 6 Spiele mit 2 Spielen Abstand. Tiebreak bei 6:6.',
                ),
                _buildRuleItem(
                  context,
                  'Ballwechsel',
                  'Ball darf einmal aufspringen. Wandnutzung erlaubt.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildRuleItem(
    BuildContext context,
    String title,
    String description,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: DesignTokens.orbitPrimary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
