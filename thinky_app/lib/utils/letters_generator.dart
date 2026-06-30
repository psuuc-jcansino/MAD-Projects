import 'dart:math';

import '../models/difficulty.dart';
import '../models/game_question.dart';

class LettersGenerator {
  static final _random = Random();

  static final List<String> _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  static const List<String> _animals = [
    'bee',
    'bird',
    'cat',
    'deer',
    'dog',
    'elephant',
    'horse',
    'kangaroo',
    'monkey',
    'mouse',
    'octopus',
    'owl',
    'peacock',
    'penguin',
    'pig',
    'rabbit',
    'seal',
    'shark',
    'snail',
    'snake',
    'tiger',
    'turtle',
  ];

  static final List<String> _easyLetterPool = [];
  static final List<_MissingLetterQuestion> _mediumPool = [];
  static final List<String> _hardAnimalPool = [];

  static GameQuestion generate(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easyGame();
      case Difficulty.medium:
        return _mediumImageMissingLetter();
      case Difficulty.hard:
        return _hardImageIdentifyWord();
    }
  }

  static GameQuestion _easyGame() {
    if (_easyLetterPool.isEmpty) {
      _easyLetterPool
        ..addAll(_alphabet)
        ..shuffle();
    }

    final letter = _easyLetterPool.removeLast();

    final bool capitalToLower = _random.nextBool();

    if (capitalToLower) {
      return GameQuestion(
        question: 'Match the letter:\n$letter',
        correctAnswer: letter.toLowerCase(),
        options: _generateLowercaseOptions(letter.toLowerCase()),
      );
    } else {
      final lower = letter.toLowerCase();
      return GameQuestion(
        question: 'Match the letter:\n$lower',
        correctAnswer: letter,
        options: _generateUppercaseOptions(letter),
      );
    }
  }

  static List<String> _generateUppercaseOptions(String correct) {
    final options = <String>{correct};

    while (options.length < 4) {
      options.add(_alphabet[_random.nextInt(_alphabet.length)]);
    }

    return options.toList()..shuffle();
  }

  static GameQuestion _mediumImageMissingLetter() {
    if (_mediumPool.isEmpty) {
      _mediumPool
        ..addAll(_generateMediumQuestions())
        ..shuffle();
    }

    final q = _mediumPool.removeLast();

    final letters = q.word.split('');
    letters[q.missingIndex] = '_';

    return GameQuestion(
      question: letters.join(' '),
      imagePath: 'lib/assets/animals/${q.word.toLowerCase()}.png',
      correctAnswer: q.correctLetter,
      options: _generateOptions(q.correctLetter),
    );
  }

  static List<_MissingLetterQuestion> _generateMediumQuestions() {
    final list = <_MissingLetterQuestion>[];

    for (final animal in _animals) {
      final word = animal.toUpperCase();

      for (int i = 1; i < word.length - 1; i++) {
        list.add(
          _MissingLetterQuestion(
            word: word,
            missingIndex: i,
            correctLetter: word[i],
          ),
        );
      }
    }

    return list;
  }

  static GameQuestion _hardImageIdentifyWord() {
    if (_hardAnimalPool.isEmpty) {
      _hardAnimalPool
        ..addAll(_animals)
        ..shuffle();
    }

    final animal = _hardAnimalPool.removeLast();
    final correctWord = animal.toUpperCase();

    final options = <String>{correctWord};

    while (options.length < 4) {
      options.add(_animals[_random.nextInt(_animals.length)].toUpperCase());
    }

    return GameQuestion(
      question: 'What is shown in the picture?',
      imagePath: 'lib/assets/animals/$animal.png',
      correctAnswer: correctWord,
      options: options.toList()..shuffle(),
    );
  }

  static List<String> _generateOptions(String correct) {
    final options = <String>{correct};

    while (options.length < 4) {
      options.add(_alphabet[_random.nextInt(_alphabet.length)]);
    }

    return options.toList()..shuffle();
  }

  static List<String> _generateLowercaseOptions(String correct) {
    final options = <String>{correct};

    while (options.length < 4) {
      options.add(_alphabet[_random.nextInt(_alphabet.length)].toLowerCase());
    }

    return options.toList()..shuffle();
  }
}

class _MissingLetterQuestion {
  final String word;
  final int missingIndex;
  final String correctLetter;

  const _MissingLetterQuestion({
    required this.word,
    required this.missingIndex,
    required this.correctLetter,
  });
}
