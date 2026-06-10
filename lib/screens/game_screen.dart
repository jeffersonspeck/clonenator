// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../engine/game_controller.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/answer_buttons.dart';
import '../widgets/candidate_grid.dart';
import '../widgets/step_card.dart';
import '../widgets/beam_visualizer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  final ScrollController _scrollController = ScrollController();
  Set<String>? _lastEliminatedIds;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _controller.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    setState(() {});
    // scroll to bottom after state update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAnswer(UserAnswer answer) {
    final before = _controller.currentCandidateIds.toSet();
    _controller.answer(answer);
    final after = _controller.currentCandidateIds.toSet();
    setState(() {
      _lastEliminatedIds = before.difference(after);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _controller.phase == GamePhase.idle
                  ? _buildWelcome()
                  : _buildGameBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF63CFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_tree_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Árvore de Decisão',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Beam Search Interativo',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (_controller.phase != GamePhase.idle)
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.startGame();
                  _lastEliminatedIds = null;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4),
                    Text('Reiniciar',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌳', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          const Text(
            'Visualizador de Beam Search',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Este app demonstra como uma árvore de decisão se forma dinamicamente durante uma sessão de Akinator, mantendo múltiplas hipóteses em paralelo (Beam Search) para lidar com respostas incertas.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _InfoRow(
              icon: '🤔',
              title: 'Perguntas binárias',
              desc: 'Cada pergunta tenta dividir os candidatos ao meio'),
          const SizedBox(height: 10),
          _InfoRow(
              icon: '🌿',
              title: 'Hipóteses paralelas',
              desc:
                  'Respostas incertas criam novos galhos na árvore, todos mantidos simultaneamente'),
          const SizedBox(height: 10),
          _InfoRow(
              icon: '⚖️',
              title: 'Score de penalidade',
              desc:
                  'Incerteza acumula penalidade; o melhor caminho tem menor score'),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.startGame();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Começar jogo',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBody() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Current candidate grid
        _SectionCard(
          title: 'Estado atual dos candidatos',
          child: CandidateGrid(
            allPeople: _controller.allPeople,
            activeCandidateIds: _controller.currentCandidateIds,
            justEliminatedIds: _lastEliminatedIds,
          ),
        ),
        const SizedBox(height: 12),

        // Beam states
        _SectionCard(
          title: 'Beam Search — hipóteses ativas',
          child: BeamVisualizer(states: _controller.currentStates),
        ),
        const SizedBox(height: 12),

        // Current question or result
        if (_controller.phase == GamePhase.playing &&
            _controller.currentQuestion != null) ...[
          _buildQuestionCard(),
          const SizedBox(height: 12),
        ],

        if (_controller.phase == GamePhase.guessing) ...[
          _buildResultCard(),
          const SizedBox(height: 12),
        ],

        // History
        if (_controller.history.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history_rounded,
                    size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Histórico de perguntas',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ..._controller.history.asMap().entries.map((entry) => StepCard(
                step: entry.value,
                stepNumber: entry.key + 1,
              )),
        ],

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final q = _controller.currentQuestion!;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1D40), Color(0xFF1A2540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pergunta ${_controller.questionNumber}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            q.text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Esta pergunta foi escolhida por melhor dividir os ${_controller.currentCandidateIds.length} candidatos restantes.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          AnswerButtons(onAnswer: _handleAnswer),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final guesses = _controller.guesses;
    final top = guesses.isNotEmpty ? guesses.first : null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2710), Color(0xFF1A2730)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.yes.withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  color: AppTheme.yes, size: 18),
              const SizedBox(width: 8),
              const Text(
                'O algoritmo chegou a uma conclusão!',
                style: TextStyle(
                  color: AppTheme.yes,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (top != null) ...[
            Row(
              children: [
                Text(top.person.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      top.person.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score: ${top.score.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (guesses.length > 1) ...[
            const SizedBox(height: 16),
            const Text(
              'Outras possibilidades:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...guesses.skip(1).map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text(g.person.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(g.person.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 14)),
                      const Spacer(),
                      Text(
                        'score: ${g.score.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                )),
          ],
          if (_controller.history.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildFullTreeCard(),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _controller.startGame();
                  _lastEliminatedIds = null;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.yes,
                side: BorderSide(color: AppTheme.yes.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Jogar novamente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTreeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.yes.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_tree_rounded, color: AppTheme.yes, size: 16),
              SizedBox(width: 8),
              Text(
                'Arvore completa',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._controller.history.asMap().entries.map((entry) {
            final stepNumber = entry.key + 1;
            final step = entry.value;
            final removed = step.candidatesBefore
                .where((id) => !step.candidatesAfter.contains(id))
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.yes.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.yes.withValues(alpha: 0.35)),
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: const TextStyle(
                          color: AppTheme.yes,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.questionText,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _TreeChip(
                              icon: Icons.reply_rounded,
                              label: AppTheme.answerLabel(step.answer),
                              color: AppTheme.answerColor(step.answer),
                            ),
                            _TreeChip(
                              icon: Icons.person_remove_alt_1_rounded,
                              label: removed.isEmpty
                                  ? '0 removidos'
                                  : '${removed.length} removido(s)',
                              color: removed.isEmpty
                                  ? AppTheme.textSecondary
                                  : AppTheme.no,
                            ),
                            _TreeChip(
                              icon: Icons.groups_rounded,
                              label: '${step.candidatesAfter.length} restantes',
                              color: AppTheme.accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          removed.isEmpty
                              ? 'Removidos: nenhum'
                              : 'Removidos: ${removed.map(_personName).join(', ')}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: AppTheme.border, height: 18),
          const Text(
            'Hipoteses finais mantidas na arvore:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ..._controller.currentStates.asMap().entries.map((entry) {
            final index = entry.key;
            final state = entry.value;
            final score = state.candidateIds.length + state.penalty;
            final candidates = state.candidateIds.map(_personName).join(', ');

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: index == 0
                    ? AppTheme.yes.withValues(alpha: 0.08)
                    : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: index == 0
                      ? AppTheme.yes.withValues(alpha: 0.24)
                      : AppTheme.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index == 0
                        ? 'Caminho principal | score ${score.toStringAsFixed(2)}'
                        : 'Caminho alternativo ${index + 1} | score ${score.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: index == 0 ? AppTheme.yes : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Candidatos: $candidates',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  if (state.path.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      state.path.join('  >  '),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        height: 1.35,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _personName(String id) {
    final person = _controller.personById(id);
    if (person == null) return id;
    return '${person.emoji} ${person.name}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TreeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TreeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
