import 'dart:math';
import '../models/game_question.dart';
import '../models/difficulty.dart';

class NumbersGenerator {
  static final Random _random = Random();

  static final List<_NumberQuestion> _easyPool = [];
  static final List<_NumberQuestion> _mediumPool = [];
  static final List<_NumberQuestion> _hardPool = [];

  static GameQuestion<int> generate(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easySequence();
      case Difficulty.medium:
        return _mediumAddSubtract();
      case Difficulty.hard:
        return _hardMultiplyDivide();
    }
  }

  static GameQuestion<int> _easySequence() {
    if (_easyPool.isEmpty) {
      _easyPool
        ..addAll(_generateEasyQuestions())
        ..shuffle();
    }

    final q = _easyPool.removeLast();

    return _build(
      'What comes next?',
      q.answer,
      q.maxOption,
      display: q.display,
    );
  }

  static List<_NumberQuestion> _generateEasyQuestions() {
    final list = <_NumberQuestion>[];

    for (int start = 1; start <= 5; start++) {
      list.add(
        _NumberQuestion(
          display: '$start  ${start + 1}  ${start + 2}  _',
          answer: start + 3,
          maxOption: start + 8,
        ),
      );
    }

    for (int start = 1; start <= 5; start++) {
      list.add(
        _NumberQuestion(
          display: '$start  ${start + 2}  ${start + 4}  _',
          answer: start + 6,
          maxOption: start + 10,
        ),
      );
    }

    for (int start = 8; start >= 5; start--) {
      list.add(
        _NumberQuestion(
          display: '$start  ${start - 1}  ${start - 2}  _',
          answer: start - 3,
          maxOption: start,
        ),
      );
    }

    for (int a = 1; a <= 5; a++) {
      final b = a + 1;
      list.add(
        _NumberQuestion(display: '$a  $b  $a  _', answer: b, maxOption: b + 5),
      );
    }

    for (int start = 2; start <= 6; start += 2) {
      list.add(
        _NumberQuestion(
          display: '$start  ${start + 2}  ${start + 4}  _',
          answer: start + 6,
          maxOption: start + 10,
        ),
      );
    }

    return list;
  }

  static GameQuestion<int> _mediumAddSubtract() {
    if (_mediumPool.isEmpty) {
      _mediumPool
        ..addAll(_generateMediumQuestions())
        ..shuffle();
    }

    final q = _mediumPool.removeLast();

    return _build(
      'Can you solve this?',
      q.answer,
      q.maxOption,
      display: q.display,
    );
  }

  static List<_NumberQuestion> _generateMediumQuestions() {
    final list = <_NumberQuestion>[];

    for (int a = 5; a <= 25; a += 5) {
      for (int b = 1; b <= 10; b++) {
        list.add(
          _NumberQuestion(display: '$a + $b = ?', answer: a + b, maxOption: 50),
        );

        if (a > b) {
          list.add(
            _NumberQuestion(
              display: '$a − $b = ?',
              answer: a - b,
              maxOption: 40,
            ),
          );
        }
      }
    }

    return list;
  }

  static GameQuestion<int> _hardMultiplyDivide() {
    if (_hardPool.isEmpty) {
      _hardPool
        ..addAll(_generateHardQuestions())
        ..shuffle();
    }

    final q = _hardPool.removeLast();

    return _build(
      'Can you solve this?',
      q.answer,
      q.maxOption,
      display: q.display,
    );
  }

  static List<_NumberQuestion> _generateHardQuestions() {
    final list = <_NumberQuestion>[];

    for (int a = 2; a <= 10; a++) {
      for (int b = 2; b <= 10; b++) {
        list.add(
          _NumberQuestion(
            display: '$a × $b = ?',
            answer: a * b,
            maxOption: 100,
          ),
        );
      }
    }

    for (int divisor = 2; divisor <= 10; divisor++) {
      for (int answer = 2; answer <= 10; answer++) {
        final dividend = divisor * answer;
        list.add(
          _NumberQuestion(
            display: '$dividend ÷ $divisor = ?',
            answer: answer,
            maxOption: 50,
          ),
        );
      }
    }

    return list;
  }

  static GameQuestion<int> _build(
    String title,
    int correct,
    int maxOption, {
    required String display,
  }) {
    final options = <int>{correct};

    while (options.length < 4) {
      options.add(_random.nextInt(maxOption) + 1);
    }

    return GameQuestion<int>(
      question: '$title\n$display',
      correctAnswer: correct,
      options: options.toList()..shuffle(),
    );
  }
}

class _NumberQuestion {
  final String display;
  final int answer;
  final int maxOption;

  const _NumberQuestion({
    required this.display,
    required this.answer,
    required this.maxOption,
  });
}
