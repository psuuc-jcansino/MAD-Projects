import 'dart:math';

import '../constants/shape_type.dart';
import '../models/game_question.dart';
import '../models/difficulty.dart';

class ShapesGenerator {
  static final Random _random = Random();

  static const List<ShapeType> _allShapes = [
    ShapeType.circle,
    ShapeType.square,
    ShapeType.triangle,
    ShapeType.rectangle,
    ShapeType.oval,
    ShapeType.diamond,
    ShapeType.star,
    ShapeType.heart,
    ShapeType.pentagon,
    ShapeType.hexagon,
    ShapeType.octagon,
    ShapeType.trapezoid,
    ShapeType.crescent,
  ];

  static final List<ShapeType> _easyPool = [];
  static final List<ShapeType> _mediumPool = [];
  static final List<_PropertyQuestion> _hardPool = [];

  static GameQuestion<ShapeType> generate(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easyOddOneOut();
      case Difficulty.medium:
        return _mediumFindShape();
      case Difficulty.hard:
        return _hardByProperties();
    }
  }

  static GameQuestion<ShapeType> _easyOddOneOut() {
    if (_easyPool.isEmpty) {
      _easyPool
        ..addAll(_allShapes)
        ..shuffle();
    }

    final common = _easyPool.removeLast();
    final different = _randomShape(except: common);

    return GameQuestion<ShapeType>(
      question: 'Which shape is different?',
      correctAnswer: different,
      options: [common, common, common, different]..shuffle(),
    );
  }

  static GameQuestion<ShapeType> _mediumFindShape() {
    if (_mediumPool.isEmpty) {
      _mediumPool
        ..addAll(_allShapes)
        ..shuffle();
    }

    final correct = _mediumPool.removeLast();

    return GameQuestion<ShapeType>(
      question: 'Which shape is ${correct.name}?',
      correctAnswer: correct,
      options: _randomOptions(correct),
    );
  }

  static GameQuestion<ShapeType> _hardByProperties() {
    if (_hardPool.isEmpty) {
      _hardPool
        ..addAll(_hardQuestions)
        ..shuffle();
    }

    final picked = _hardPool.removeLast();

    return GameQuestion<ShapeType>(
      question: picked.question,
      correctAnswer: picked.answer,
      options: _randomOptions(picked.answer),
    );
  }

  static final List<_PropertyQuestion> _hardQuestions = [
    _PropertyQuestion(
      question: 'Which shape has 3 sides?',
      answer: ShapeType.triangle,
    ),
    _PropertyQuestion(
      question: 'Which shape has 4 equal sides?',
      answer: ShapeType.square,
    ),
    _PropertyQuestion(
      question: 'Which shape has no corners?',
      answer: ShapeType.circle,
    ),
    _PropertyQuestion(
      question: 'Which shape looks like a stretched circle?',
      answer: ShapeType.oval,
    ),
    _PropertyQuestion(
      question: 'Which shape has 5 sides?',
      answer: ShapeType.pentagon,
    ),
    _PropertyQuestion(
      question: 'Which shape has 6 sides?',
      answer: ShapeType.hexagon,
    ),
    _PropertyQuestion(
      question: 'Which shape has 8 sides?',
      answer: ShapeType.octagon,
    ),
    _PropertyQuestion(
      question: 'Which shape is curved and has a point?',
      answer: ShapeType.crescent,
    ),
    _PropertyQuestion(
      question: 'Which shape has 4 sides, but not all sides are equal?',
      answer: ShapeType.rectangle,
    ),
    _PropertyQuestion(
      question: 'Which shape has the most sides here?',
      answer: ShapeType.trapezoid,
    ),
  ];

  static ShapeType _randomShape({ShapeType? except}) {
    ShapeType shape;
    do {
      shape = _allShapes[_random.nextInt(_allShapes.length)];
    } while (shape == except);
    return shape;
  }

  static List<ShapeType> _randomOptions(ShapeType correct) {
    final set = <ShapeType>{correct};
    while (set.length < 4) {
      set.add(_randomShape(except: correct));
    }
    return set.toList()..shuffle();
  }
}

class _PropertyQuestion {
  final String question;
  final ShapeType answer;

  const _PropertyQuestion({required this.question, required this.answer});
}
