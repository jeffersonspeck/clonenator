// lib/widgets/step_card.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';
import '../data/game_data.dart';

class StepCard extends StatefulWidget {
  final StepRecord step;
  final int stepNumber;

  const StepCard({super.key, required this.step, required this.stepNumber});

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.answerColor(widget.step.answer);
    final eliminated = widget.step.candidatesBefore
        .where((id) => !widget.step.candidatesAfter.contains(id))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.stepNumber}',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.step.questionText,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                    width: 1),
                              ),
                              child: Text(
                                '${AppTheme.answerEmoji(widget.step.answer)} ${AppTheme.answerLabel(widget.step.answer)}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (eliminated.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '−${eliminated.length} candidato(s)',
                                style: const TextStyle(
                                  color: AppTheme.no,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        _RemovedPreview(ids: eliminated),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(color: AppTheme.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🤖 ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            widget.step.explanation,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RemovedPanel(ids: eliminated),
                  const SizedBox(height: 12),
                  // Before/After candidates
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CandidateList(
                          title: 'Antes',
                          icon: Icons.filter_list_rounded,
                          ids: widget.step.candidatesBefore,
                          highlightIds: null,
                          dimIds: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppTheme.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CandidateList(
                          title: 'Depois',
                          icon: Icons.done_all_rounded,
                          ids: widget.step.candidatesAfter,
                          highlightIds: widget.step.candidatesAfter.toSet(),
                          dimIds: eliminated.toSet(),
                        ),
                      ),
                    ],
                  ),
                  if (widget.step.activePaths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Hipóteses ativas na árvore:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...widget.step.activePaths.map((path) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('  ↳ ',
                                  style: TextStyle(
                                      color: AppTheme.accent, fontSize: 11)),
                              Expanded(
                                child: Text(
                                  path,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CandidateList extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> ids;
  final Set<String>? highlightIds;
  final Set<String>? dimIds;

  const _CandidateList({
    required this.title,
    required this.icon,
    required this.ids,
    this.highlightIds,
    this.dimIds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ...ids.map((id) {
          final person = gamePeople.firstWhere((p) => p.id == id,
              orElse: () => Person(id: id, name: id, emoji: '?'));
          return Text(
            '${person.emoji} ${person.name}',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
            ),
          );
        }),
      ],
    );
  }
}

class _RemovedPreview extends StatelessWidget {
  final List<String> ids;

  const _RemovedPreview({required this.ids});

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return const Text(
        'Professores removidos: nenhum nesta pergunta.',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          height: 1.4,
        ),
      );
    }

    return Text(
      'Professores removidos: ${ids.map(_personLabel).join(', ')}',
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        height: 1.4,
      ),
    );
  }
}

class _RemovedPanel extends StatelessWidget {
  final List<String> ids;

  const _RemovedPanel({required this.ids});

  @override
  Widget build(BuildContext context) {
    final hasRemoved = ids.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasRemoved
            ? AppTheme.no.withValues(alpha: 0.08)
            : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasRemoved
              ? AppTheme.no.withValues(alpha: 0.25)
              : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasRemoved
                    ? Icons.person_remove_alt_1_rounded
                    : Icons.check_circle_outline_rounded,
                size: 14,
                color: hasRemoved ? AppTheme.no : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                hasRemoved
                    ? 'Professores removidos da arvore'
                    : 'Nenhum professor foi removido',
                style: TextStyle(
                  color: hasRemoved ? AppTheme.no : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (hasRemoved) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ids.map((id) {
                final person = gamePeople.firstWhere((p) => p.id == id,
                    orElse: () => Person(id: id, name: id, emoji: '?'));
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.no.withValues(alpha: 0.24)),
                  ),
                  child: Text(
                    '${person.emoji} ${person.name}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.no,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

String _personLabel(String id) {
  final person = gamePeople.firstWhere((p) => p.id == id,
      orElse: () => Person(id: id, name: id, emoji: '?'));
  return '${person.emoji} ${person.name}';
}
