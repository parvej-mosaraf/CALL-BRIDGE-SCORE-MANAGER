class Player {
  String name;
  String pin;

  // Current round call.
  int? call;

  // Cards/tricks collected in the current round.
  int tricksWon = 0;

  // Score earned in R2, R3, R4...
  // R1 has no score.
  List<int> scoreHistory = [];

  // Calls for R2, R3, R4...
  List<int> roundCalls = [];

  // Cards/tricks collected:
  // roundTricks[0] = R1
  // roundTricks[1] = R2
  // roundTricks[2] = R3
  // ...
  List<int> roundTricks = [];

  Player({required this.name, required this.pin, this.call});

  bool get hasSubmittedCall => call != null;
}
