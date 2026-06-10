// lib/models/models.dart

enum UserAnswer { yes, no, probablyYes, probablyNo, unknown }

enum ExpectedAnswer { yes, no, probablyYes, probablyNo, unknown }

class Person {
  final String id;
  final String name;
  final String emoji;

  const Person({required this.id, required this.name, required this.emoji});

  @override
  String toString() => name;
}

class Question {
  final String id;
  final String text;
  final Map<String, ExpectedAnswer> answersByPerson;

  const Question({
    required this.id,
    required this.text,
    required this.answersByPerson,
  });

  bool hasAnswerFor(String personId) => answersByPerson.containsKey(personId);

  ExpectedAnswer answerFor(String personId) =>
      answersByPerson[personId] ?? ExpectedAnswer.unknown;
}

class DecisionState {
  final Set<String> candidateIds;
  final Set<String> askedQuestionIds;
  final double penalty;
  final List<String> path;

  const DecisionState({
    required this.candidateIds,
    required this.askedQuestionIds,
    required this.penalty,
    required this.path,
  });

  DecisionState copyWith({
    Set<String>? candidateIds,
    Set<String>? askedQuestionIds,
    double? penalty,
    List<String>? path,
  }) {
    return DecisionState(
      candidateIds: candidateIds ?? this.candidateIds,
      askedQuestionIds: askedQuestionIds ?? this.askedQuestionIds,
      penalty: penalty ?? this.penalty,
      path: path ?? this.path,
    );
  }
}

class GuessResult {
  final Person person;
  final double score;
  final int candidateCount;

  const GuessResult({
    required this.person,
    required this.score,
    required this.candidateCount,
  });
}

class StepRecord {
  final String questionText;
  final UserAnswer answer;
  final List<String> candidatesBefore;
  final List<String> candidatesAfter;
  final String explanation;
  final List<String> activePaths;

  const StepRecord({
    required this.questionText,
    required this.answer,
    required this.candidatesBefore,
    required this.candidatesAfter,
    required this.explanation,
    required this.activePaths,
  });
}
