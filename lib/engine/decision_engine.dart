// lib/engine/decision_engine.dart
import '../models/models.dart';

class AkinatorDecisionEngine {
  final List<Person> people;
  final List<Question> questions;
  final int beamWidth;
  final bool allowQuestionRepeat;

  late List<DecisionState> _states;

  AkinatorDecisionEngine({
    required this.people,
    required this.questions,
    this.beamWidth = 4,
    this.allowQuestionRepeat = true,
  }) {
    reset();
  }

  void reset() {
    _states = [
      DecisionState(
        candidateIds: people.map((p) => p.id).toSet(),
        askedQuestionIds: {},
        penalty: 0,
        path: [],
      ),
    ];
  }

  List<DecisionState> get states => List.unmodifiable(_states);

  Question? nextQuestion() {
    final bestState = _bestState();
    if (bestState == null) return null;
    return _selectBestQuestionForState(bestState);
  }

  void answerCurrentQuestion(Question question, UserAnswer userAnswer) {
    final List<DecisionState> nextStates = [];
    for (final state in _states) {
      nextStates.addAll(_applyAnswerToState(
        state: state,
        question: question,
        userAnswer: userAnswer,
      ));
    }
    nextStates.sort((a, b) => _stateScore(a).compareTo(_stateScore(b)));
    _states = nextStates.take(beamWidth).toList();
  }

  bool canGuess({int maxCandidates = 1}) {
    final best = _bestState();
    if (best == null) return false;
    return best.candidateIds.length <= maxCandidates;
  }

  List<GuessResult> guesses({int limit = 5}) {
    final Map<String, double> bestScoreByPerson = {};
    final Map<String, int> candidateCountByPerson = {};

    for (final state in _states) {
      for (final personId in state.candidateIds) {
        final score = _stateScore(state);
        if (!bestScoreByPerson.containsKey(personId) ||
            score < bestScoreByPerson[personId]!) {
          bestScoreByPerson[personId] = score;
          candidateCountByPerson[personId] = state.candidateIds.length;
        }
      }
    }

    final results = bestScoreByPerson.entries.map((entry) {
      final person = people.firstWhere((p) => p.id == entry.key);
      return GuessResult(
        person: person,
        score: entry.value,
        candidateCount: candidateCountByPerson[entry.key] ?? 999,
      );
    }).toList();

    results.sort((a, b) => a.score.compareTo(b.score));
    return results.take(limit).toList();
  }

  Set<String> get currentCandidateIds => _bestState()?.candidateIds ?? {};

  List<DecisionState> get allStates => List.unmodifiable(_states);

  DecisionState? _bestState() {
    if (_states.isEmpty) return null;
    final sorted = [..._states];
    sorted.sort((a, b) => _stateScore(a).compareTo(_stateScore(b)));
    return sorted.first;
  }

  double _stateScore(DecisionState state) {
    return state.candidateIds.length + state.penalty;
  }

  List<DecisionState> _applyAnswerToState({
    required DecisionState state,
    required Question question,
    required UserAnswer userAnswer,
  }) {
    final asked = {...state.askedQuestionIds, question.id};

    switch (userAnswer) {
      case UserAnswer.yes:
        return [
          _filterState(
            state: state,
            question: question,
            assumePositive: true,
            extraPenalty: 0,
            askedQuestionIds: asked,
            label: 'SIM',
          ),
        ];
      case UserAnswer.no:
        return [
          _filterState(
            state: state,
            question: question,
            assumePositive: false,
            extraPenalty: 0,
            askedQuestionIds: asked,
            label: 'NÃO',
          ),
        ];
      case UserAnswer.probablyYes:
        return [
          _filterState(
            state: state,
            question: question,
            assumePositive: true,
            extraPenalty: 0.25,
            askedQuestionIds: asked,
            label: 'PROVAVELMENTE SIM → tratado como SIM',
          ),
          _filterState(
            state: state,
            question: question,
            assumePositive: false,
            extraPenalty: 1.00,
            askedQuestionIds: asked,
            label: 'PROVAVELMENTE SIM → testado como NÃO',
          ),
        ];
      case UserAnswer.probablyNo:
        return [
          _filterState(
            state: state,
            question: question,
            assumePositive: false,
            extraPenalty: 0.25,
            askedQuestionIds: asked,
            label: 'PROVAVELMENTE NÃO → tratado como NÃO',
          ),
          _filterState(
            state: state,
            question: question,
            assumePositive: true,
            extraPenalty: 1.00,
            askedQuestionIds: asked,
            label: 'PROVAVELMENTE NÃO → testado como SIM',
          ),
        ];
      case UserAnswer.unknown:
        return [
          state.copyWith(
            askedQuestionIds: asked,
            penalty: state.penalty + 0.15,
            path: [...state.path, '${question.text} → NÃO SEI'],
          ),
        ];
    }
  }

  DecisionState _filterState({
    required DecisionState state,
    required Question question,
    required bool assumePositive,
    required double extraPenalty,
    required Set<String> askedQuestionIds,
    required String label,
  }) {
    final filtered = state.candidateIds.where((personId) {
      final expected = question.answerFor(personId);
      return assumePositive ? _isPositive(expected) : _isNegative(expected);
    }).toSet();

    final safeCandidates = filtered.isEmpty ? state.candidateIds : filtered;
    final contradictionPenalty = filtered.isEmpty ? 2.0 : 0.0;

    return state.copyWith(
      candidateIds: safeCandidates,
      askedQuestionIds: askedQuestionIds,
      penalty: state.penalty + extraPenalty + contradictionPenalty,
      path: [...state.path, '${question.text} → $label'],
    );
  }

  Question? _selectBestQuestionForState(DecisionState state) {
    final candidateQuestions = questions.where((q) {
      if (state.askedQuestionIds.contains(q.id)) return false;
      return _questionIsUseful(q, state.candidateIds);
    }).toList();

    if (candidateQuestions.isNotEmpty) {
      return _bestQuestionBySplit(candidateQuestions, state.candidateIds);
    }

    if (!allowQuestionRepeat) return null;

    final repeatableQuestions = questions
        .where((q) => _questionIsUseful(q, state.candidateIds))
        .toList();

    if (repeatableQuestions.isEmpty) return null;
    return _bestQuestionBySplit(repeatableQuestions, state.candidateIds);
  }

  bool _questionIsUseful(Question question, Set<String> candidateIds) {
    int positive = 0;
    int negative = 0;
    for (final personId in candidateIds) {
      final expected = question.answerFor(personId);
      if (_isPositive(expected)) positive++;
      else if (_isNegative(expected)) negative++;
    }
    if (positive == 0 || negative == 0) return false;
    if (candidateIds.length > 3 && (positive == 1 || negative == 1)) return false;
    return true;
  }

  Question _bestQuestionBySplit(List<Question> qs, Set<String> candidateIds) {
    qs.sort((a, b) =>
        _splitScore(a, candidateIds).compareTo(_splitScore(b, candidateIds)));
    return qs.first;
  }

  double _splitScore(Question question, Set<String> candidateIds) {
    int positive = 0, negative = 0, unknown = 0;
    for (final personId in candidateIds) {
      final expected = question.answerFor(personId);
      if (_isPositive(expected)) positive++;
      else if (_isNegative(expected)) negative++;
      else unknown++;
    }
    return (positive - negative).abs() + unknown * 0.5;
  }

  bool _isPositive(ExpectedAnswer answer) =>
      answer == ExpectedAnswer.yes || answer == ExpectedAnswer.probablyYes;

  bool _isNegative(ExpectedAnswer answer) =>
      answer == ExpectedAnswer.no || answer == ExpectedAnswer.probablyNo;
}
