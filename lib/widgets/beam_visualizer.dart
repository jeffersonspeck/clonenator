// lib/widgets/beam_visualizer.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';
import '../data/game_data.dart';

class BeamVisualizer extends StatelessWidget {
  final List<DecisionState> states;

  const BeamVisualizer({super.key, required this.states});

  @override
  Widget build(BuildContext context) {
    if (states.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_rounded,
                size: 14, color: AppTheme.accent),
            const SizedBox(width: 6),
            Text(
              'Hipóteses em paralelo (Beam Search — ${states.length} ativo(s)):',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...states.asMap().entries.map((entry) {
          final i = entry.key;
          final state = entry.value;
          final score = state.candidateIds.length + state.penalty;
          final isBest = i == 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isBest
                  ? AppTheme.accent.withOpacity(0.08)
                  : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isBest ? AppTheme.accent.withOpacity(0.4) : AppTheme.border,
                width: isBest ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isBest)
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppTheme.accent),
                    if (!isBest)
                      const Icon(Icons.fork_right_rounded,
                          size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      isBest ? 'Hipótese principal' : 'Hipótese alternativa ${i + 1}',
                      style: TextStyle(
                        color:
                            isBest ? AppTheme.accent : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'score: ${score.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: state.candidateIds.map((id) {
                    final person = gamePeople.firstWhere((p) => p.id == id,
                        orElse: () =>
                            Person(id: id, name: id, emoji: '?'));
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${person.emoji} ${person.name}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (state.penalty > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Penalidade acumulada: ${state.penalty.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.no,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
