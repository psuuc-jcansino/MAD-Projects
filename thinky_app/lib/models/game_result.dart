class GameResult {
  final int score;
  final int total;

  const GameResult({required this.score, required this.total});

  bool get isPerfect => score == total;
}
