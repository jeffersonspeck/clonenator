// lib/engine/game_controller.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/game_data.dart';
import 'decision_engine.dart';

enum GamePhase { idle, playing, guessing, finished }

class GameController extends ChangeNotifier {
  late AkinatorDecisionEngine _engine;
  final List<StepRecord> history = [];
  Question? currentQuestion;
  GamePhase phase = GamePhase.idle;
  int questionNumber = 0;

  GameController() {
    _engine = AkinatorDecisionEngine(
      people: gamePeople,
      questions: gameQuestions,
      beamWidth: 4,
    );
  }

  List<Person> get allPeople => gamePeople;
  List<DecisionState> get currentStates => _engine.allStates;
  Set<String> get currentCandidateIds => _engine.currentCandidateIds;

  void startGame() {
    _engine.reset();
    history.clear();
    questionNumber = 0;
    phase = GamePhase.playing;
    _advance();
  }

  void answer(UserAnswer answer) {
    if (currentQuestion == null) return;

    final q = currentQuestion!;
    final beforeCandidates = _engine.currentCandidateIds.toList();

    _engine.answerCurrentQuestion(q, answer);

    final afterCandidates = _engine.currentCandidateIds.toList();
    final paths = _engine.allStates.map((s) => s.path.isNotEmpty ? s.path.last : '').where((p) => p.isNotEmpty).toList();

    final explanation = _buildExplanation(answer, beforeCandidates, afterCandidates);

    history.add(StepRecord(
      questionText: q.text,
      answer: answer,
      candidatesBefore: beforeCandidates,
      candidatesAfter: afterCandidates,
      explanation: explanation,
      activePaths: paths,
    ));

    _advance();
  }

  void _advance() {
    if (_engine.canGuess(maxCandidates: 1) || questionNumber >= gameQuestions.length) {
      phase = GamePhase.guessing;
      currentQuestion = null;
      notifyListeners();
      return;
    }

    final next = _engine.nextQuestion();
    if (next == null) {
      phase = GamePhase.guessing;
      currentQuestion = null;
    } else {
      questionNumber++;
      currentQuestion = next;
      phase = GamePhase.playing;
    }
    notifyListeners();
  }

  List<GuessResult> get guesses => _engine.guesses(limit: 3);

  String _buildExplanation(
    UserAnswer answer,
    List<String> before,
    List<String> after,
  ) {
    final eliminated = before.where((id) => !after.contains(id)).toList();
    final eliminatedNames = eliminated
        .map((id) => gamePeople.firstWhere((p) => p.id == id).name)
        .toList();

    switch (answer) {
      case UserAnswer.yes:
        if (eliminatedNames.isEmpty) {
          return 'Resposta "Sim" confirmada. Nenhum candidato foi eliminado — todos são compatíveis com esta característica.';
        }
        return 'Resposta "Sim" — eliminei ${eliminatedNames.join(', ')} porque não têm essa característica. Restam ${after.length} candidato(s).';

      case UserAnswer.no:
        if (eliminatedNames.isEmpty) {
          return 'Resposta "Não" confirmada. Nenhum candidato foi eliminado — nenhum deles tem essa característica.';
        }
        return 'Resposta "Não" — eliminei ${eliminatedNames.join(', ')} por terem essa característica. Restam ${after.length} candidato(s).';

      case UserAnswer.probablyYes:
        return 'Resposta incerta! Abri dois caminhos na árvore: o principal trata como "Sim" (baixa penalidade), e um alternativo testa como "Não" (penalidade maior). Ambos continuam na busca.';

      case UserAnswer.probablyNo:
        return 'Resposta incerta! Abri dois caminhos na árvore: o principal trata como "Não" (baixa penalidade), e um alternativo testa como "Sim" (penalidade maior). Ambos continuam na busca.';

      case UserAnswer.unknown:
        return 'Resposta "Não sei" — não elimino ninguém, mas adiciono uma pequena penalidade a este caminho por falta de informação útil.';
    }
  }

  Person? personById(String id) {
    try {
      return gamePeople.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
