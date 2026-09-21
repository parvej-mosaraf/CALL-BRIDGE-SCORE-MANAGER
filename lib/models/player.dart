class Player {
  String name;
  String pin;

  int? call;
  int tricksWon = 0;

  double totalScore = 0;

  Player({required this.name, required this.pin, this.call});

  bool get hasSubmittedCall => call != null;
}
