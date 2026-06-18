import 'package:flutter/material.dart';

import '../session_detail_view_model.dart';

/// Full-screen overlay shown while the local processing pipeline runs.
class ProcessingOverlay extends StatelessWidget {
  const ProcessingOverlay({
    super.key,
    required this.status,
    required this.onRetry,
  });

  final ProcessingStatus status;
  final VoidCallback onRetry;

  static const int _totalSteps = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = status.stage == ProcessingStage.error;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: Material(
        key: ValueKey(status.stage),
        color: Colors.black.withOpacity(0.72),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isError)
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: theme.colorScheme.error,
                        )
                      else
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          status.label,
                          key: ValueKey(status.label),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (status.isActive)
                        Text(
                          'Step ${status.stepIndex} of $_totalSteps',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      if (status.isActive) ...[
                        const SizedBox(height: 20),
                        _StageProgressBar(
                          activeStep: status.stepIndex,
                          totalSteps: _totalSteps,
                        ),
                      ],
                      if (isError) ...[
                        const SizedBox(height: 12),
                        Text(
                          status.errorMessage ?? 'An unknown error occurred.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ),
                      ] else if (status.isActive) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Processing locally on your device',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({
    required this.activeStep,
    required this.totalSteps,
  });

  final int activeStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(totalSteps, (index) {
        final step = index + 1;
        final isComplete = step < activeStep;
        final isCurrent = step == activeStep;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isComplete || isCurrent
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
