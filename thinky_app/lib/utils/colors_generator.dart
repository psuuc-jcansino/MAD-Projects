import 'dart:math';
import '../models/game_question.dart';
import '../models/difficulty.dart';
import '../constants/color_type.dart';

class ColorsGenerator {
  static final _rand = Random();
  static const _colors = ColorType.values;

  static final Set<String> _usedEasyPrompts = {};
  static final Set<String> _usedMediumPrompts = {};
  static final Set<String> _usedHardPrompts = {};

  static GameQuestion<ColorType> generate(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _easy();
      case Difficulty.medium:
        return _medium();
      case Difficulty.hard:
        return _hard();
    }
  }

  static GameQuestion<ColorType> _easy() {
    ColorType correct;
    String prompt;

    do {
      correct = _randomColor();
      prompt = correct.name.toUpperCase();
    } while (_usedEasyPrompts.contains(prompt));

    _usedEasyPrompts.add(prompt);

    return GameQuestion(
      question: 'Tap the color shown',
      promptText: prompt,
      promptTextColorValue: correct.value.value,
      correctAnswer: correct,
      options: _uniqueOptions(correct),
    );
  }

  static GameQuestion<ColorType> _medium() {
    final List<MapEntry<String, ColorType>> mixes = [
      MapEntry('Red + Blue = ?', ColorType.purple),
      MapEntry('Blue + Yellow = ?', ColorType.green),
      MapEntry('Red + Yellow = ?', ColorType.orange),
    ];

    MapEntry<String, ColorType> pick;
    do {
      pick = mixes[_rand.nextInt(mixes.length)];
    } while (_usedMediumPrompts.contains(pick.key));

    _usedMediumPrompts.add(pick.key);

    return GameQuestion(
      question: pick.key,
      correctAnswer: pick.value,
      options: _uniqueOptions(pick.value),
    );
  }

  static GameQuestion<ColorType> _hard() {
    ColorType wordColor, textColor;
    String prompt;

    do {
      wordColor = _randomColor();
      do {
        textColor = _randomColor();
      } while (textColor == wordColor);

      prompt =
          '${wordColor.name.toUpperCase()}-${textColor.name.toUpperCase()}';
    } while (_usedHardPrompts.contains(prompt));

    _usedHardPrompts.add(prompt);

    final options = <ColorType>{wordColor, textColor};

    while (options.length < 4) {
      final next = _randomColor();
      if (!options.contains(next)) options.add(next);
    }

    final optionsList = options.toList()..shuffle();

    return GameQuestion(
      question: 'What is the color of the text shown above?',
      promptText: wordColor.name.toUpperCase(),
      promptTextColorValue: textColor.value.value,
      correctAnswer: textColor,
      options: optionsList,
      hideColorOptionVisuals: true,
    );
  }

  static ColorType _randomColor() => _colors[_rand.nextInt(_colors.length)];

  static List<ColorType> _uniqueOptions(ColorType correct) {
    final options = <ColorType>{correct};
    while (options.length < 4) {
      final next = _randomColor();
      if (!options.contains(next)) options.add(next);
    }
    return options.toList()..shuffle();
  }

  static void resetUsedQuestions() {
    _usedEasyPrompts.clear();
    _usedMediumPrompts.clear();
    _usedHardPrompts.clear();
  }
}
