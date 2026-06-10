// lib/widgets/candidate_grid.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class CandidateGrid extends StatelessWidget {
  final List<Person> allPeople;
  final Set<String> activeCandidateIds;
  final Set<String>? justEliminatedIds;

  const CandidateGrid({
    super.key,
    required this.allPeople,
    required this.activeCandidateIds,
    this.justEliminatedIds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_alt_rounded,
                size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Candidatos ativos: ${activeCandidateIds.length}/${allPeople.length}',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allPeople.map((person) {
            final isActive = activeCandidateIds.contains(person.id);
            final justEliminated =
                justEliminatedIds?.contains(person.id) ?? false;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.paper : AppTheme.nodeEliminated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: justEliminated
                      ? AppTheme.no
                      : isActive
                          ? AppTheme.brass
                          : AppTheme.border,
                  width: justEliminated ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(person.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    person.name,
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.ink
                          : AppTheme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.normal,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                      decorationColor: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
