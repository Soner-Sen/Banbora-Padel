import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/design_system/app_widgets.dart';

class SessionJoinScreen extends StatefulWidget {
  const SessionJoinScreen({super.key});

  @override
  State<SessionJoinScreen> createState() => _SessionJoinScreenState();
}

class _SessionJoinScreenState extends State<SessionJoinScreen> {
  final _codeController = TextEditingController();
  bool _isScanning = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinWithCode() {
    final code = _codeController.text.trim();
    if (code.length >= 4) {
      // TODO: Validate and join session
      context.push('/orbit/lobby', extra: {'joinCode': code});
    }
  }

  void _openScanner() {
    setState(() => _isScanning = true);
    // TODO: Implement QR scanner
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Session beitreten'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DesignTokens.spacing24),
          _buildQRScanner(),
          const SizedBox(height: DesignTokens.spacing32),
          _buildDivider(),
          const SizedBox(height: DesignTokens.spacing32),
          _buildCodeInput(),
        ],
      ),
    ),
  );

  Widget _buildQRScanner() => Column(
    children: [
      Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: DesignTokens.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: DesignTokens.surfaceVariant, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isScanning ? Icons.qr_code_scanner : Icons.qr_code_2,
                size: 80,
                color: DesignTokens.orbitPrimary,
              ),
              const SizedBox(height: DesignTokens.spacing16),
              Text(
                _isScanning ? 'Suche nach QR-Code...' : 'QR-Code scannen',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      AppButton(
        label: _isScanning ? 'Scanne QR-Code' : 'Kamera öffnen',
        onPressed: _openScanner,
        icon: Icons.camera_alt_rounded,
        isOutlined: true,
      ),
    ],
  );

  Widget _buildDivider() => Row(
    children: [
      const Expanded(child: Divider(color: DesignTokens.surfaceVariant)),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
        ),
        child: Text(
          'oder',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: DesignTokens.textMuted),
        ),
      ),
      const Expanded(child: Divider(color: DesignTokens.surfaceVariant)),
    ],
  );

  Widget _buildCodeInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Code eingeben',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: DesignTokens.spacing8),
      Text(
        'Du hast einen 4-6-stelligen Code von einem Freund erhalten?',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: DesignTokens.textSecondary),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      AppTextField(
        controller: _codeController,
        hint: 'z.B. ABC123',
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _joinWithCode(),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      AppButton(
        label: 'Session beitreten',
        onPressed: _joinWithCode,
        icon: Icons.login_rounded,
      ),
    ],
  );
}
