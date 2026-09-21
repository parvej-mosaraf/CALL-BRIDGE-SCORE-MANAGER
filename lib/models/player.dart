class Player {
  String name;
  String pin;

  int? call;
  int tricksWon = 0;

  double totalScore = 0;

  // Score earned in each round.
  List<double> roundScores = [];

  // Call made in each round.
  List<int> roundCalls = [];

  // Number of tricks won in each round.
  List<int> roundTricks = [];

  Player({required this.name, required this.pin, this.call});

  bool get hasSubmittedCall => call != null;
}
