class GameQuestion<T> {
  final String question;
  final T correctAnswer;
  final List<T> options;

  final String? imagePath;

  final String? promptText;
  final int? promptTextColorValue;

  final bool hideColorOptionVisuals;

  GameQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.imagePath,
    this.promptText,
    this.promptTextColorValue,
    this.hideColorOptionVisuals = false,
  });
}
