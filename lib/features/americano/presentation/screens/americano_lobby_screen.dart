import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';

import '../../domain/entities/entities.dart';
import '../cubit/cubit.dart';
import 'americano_session_screen.dart';

class AmericanoLobbyScreen extends StatelessWidget {
  const AmericanoLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AmericanoCubit(),
    child: const _AmericanoLobbyContent(),
  );
}

class _AmericanoLobbyContent extends StatefulWidget {
  const _AmericanoLobbyContent();

  @override
  State<_AmericanoLobbyContent> createState() => _AmericanoLobbyContentState();
}

class _AmericanoLobbyContentState extends State<_AmericanoLobbyContent> {
  final _nameController = TextEditingController();
  int _selectedAvatar = 0;
  int _selectedTarget = 12;
  bool _isCustomTarget = false;

  static const List<int> targetPresets = [12, 16];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Americano Regeln',
              style: Theme.of(ctx).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRuleItem(
              ctx,
              Icons.group,
              '4-10 Spieler',
              'Jeder spielt mit und gegen jeden',
            ),
            _buildRuleItem(
              ctx,
              Icons.sync,
              'Faire Rotation',
              'Teams wechseln jede Runde automatisch',
            ),
            _buildRuleItem(
              ctx,
              Icons.stars,
              'Punkte sammeln',
              'Dein Match-Ergebnis = Deine Punkte',
            ),
            _buildRuleItem(
              ctx,
              Icons.emoji_events,
              'Gewinner',
              'Wer die meisten Punkte hat, gewinnt',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentMint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Beispiel: Team A gewinnt 16:7 → Alle Spieler in Team A bekommen 16 Punkte, Team B bekommt 7 Punkte.',
                      style: Theme.of(ctx).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(
    BuildContext ctx,
    IconData icon,
    String title,
    String description,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleMedium),
              Text(
                description,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gib einen Spielernamen ein'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AmericanoCubit>().addParticipant(
      AmericanoParticipant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        displayName: name,
        avatar: GamePlayerAvatar.values[_selectedAvatar],
      ),
    );
    _nameController.clear();
    FocusScope.of(context).unfocus();
  }

  void _selectTarget(int target) {
    setState(() {
      _selectedTarget = target;
      _isCustomTarget = !targetPresets.contains(target);
    });
    context.read<AmericanoCubit>().setTargetPoints(target);
  }

  void _showCustomTargetDialog() {
    final controller = TextEditingController(
      text: _isCustomTarget ? _selectedTarget.toString() : '',
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eigene Zahl eingeben'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Zahl eingeben (z.B. 15)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                _selectTarget(value);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }

  void _showQRJoinDialog(BuildContext dialogContext) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('QR Code beitreten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 100, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              'QR Scanner kommt bald!',
              style: Theme.of(ctx).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Du kannst später einem Spiel über den geteilten Code beitreten.',
              style: Theme.of(
                ctx,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AmericanoCubit, AmericanoState>(
    builder: (context, state) {
      final participants = state.session?.participants ?? [];
      final canStart = participants.length >= 4;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Americano'),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'QR Code beitreten',
              onPressed: () => _showQRJoinDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showInfoSheet,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Target Score Selection
                      _buildSectionTitle('Ziel-Punkte'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTargetScoreSelector(),
                      const SizedBox(height: AppSpacing.lg),

                      // Player Input
                      _buildSectionTitle('Spieler hinzufügen'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPlayerInput(),
                      const SizedBox(height: AppSpacing.sm),
                      _buildAvatarSelector(),
                      const SizedBox(height: AppSpacing.lg),

                      // Players List
                      _buildSectionTitle('Spieler (${participants.length}/10)'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPlayersList(participants),
                    ],
                  ),
                ),
              ),

              // Start Button
              _buildStartButton(canStart, participants.length),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildSectionTitle(String title) =>
      Text(title, style: Theme.of(context).textTheme.titleLarge);

  Widget _buildTargetScoreSelector() => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      boxShadow: AppElevation.low,
    ),
    child: Column(
      children: [
        // Preset buttons
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: targetPresets.map((target) {
            final isSelected = _selectedTarget == target && !_isCustomTarget;
            return GestureDetector(
              onTap: () => _selectTarget(target),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$target',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Custom button
        GestureDetector(
          onTap: _showCustomTargetDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: _isCustomTarget ? AppColors.primary : AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: _isCustomTarget
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  size: 20,
                  color: _isCustomTarget
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _isCustomTarget ? '$_selectedTarget (Custom)' : 'Eigene Zahl',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isCustomTarget
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPlayerInput() => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      boxShadow: AppElevation.low,
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Spielername',
              prefixIcon: Icon(Icons.person_add),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addPlayer(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          onPressed: _addPlayer,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(56, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ],
    ),
  );

  Widget _buildAvatarSelector() => SizedBox(
    height: 64,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: GamePlayerAvatar.values.length,
      itemBuilder: (context, index) {
        final avatar = GamePlayerAvatar.values[index];
        final isSelected = _selectedAvatar == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = index),
          child: Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(avatar.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildPlayersList(List<AmericanoParticipant> participants) {
    if (participants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppElevation.low,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Noch keine Spieler',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Füge mindestens 4 Spieler hinzu',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppElevation.low,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: participants.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final participant = participants[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                participant.avatar.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              participant.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<AmericanoCubit>().removeParticipant(
                  participant.id,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton(bool canStart, int playerCount) => Container(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      MediaQuery.of(context).padding.bottom + AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: canStart
          ? () {
              context.read<AmericanoCubit>().startSession();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AmericanoCubit>(),
                    child: const AmericanoSessionScreen(),
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      child: Text(
        canStart
            ? 'Spiel starten ($playerCount Spieler)'
            : 'Mindestens 4 Spieler benötigt',
        style: const TextStyle(fontSize: 18),
      ),
    ),
  );
}
