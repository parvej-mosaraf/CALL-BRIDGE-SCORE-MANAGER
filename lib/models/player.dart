class Player {
  String name;
  String pin;

  int? call;

  Player({required this.name, required this.pin, this.call});

  bool get hasSubmittedCall => call != null;
}
