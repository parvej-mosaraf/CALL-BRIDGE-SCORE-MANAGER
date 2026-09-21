import 'package:flutter/material.dart';
import '../models/player.dart';
import 'bidding_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<bool> playerSaved = List.generate(4, (_) => false);

  final List<TextEditingController> nameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  void savePlayer(int index) {
    String name = nameControllers[index].text.trim();
    String pin = pinControllers[index].text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Player name cannot be empty")),
      );
      return;
    }

    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN must be exactly 4 digits")),
      );
      return;
    }

    for (int i = 0; i < 4; i++) {
      if (i != index && playerSaved[i] && pinControllers[i].text == pin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN already used by another player")),
        );
        return;
      }
    }

    setState(() {
      playerSaved[index] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${nameControllers[index].text} saved successfully"),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in nameControllers) {
      controller.dispose();
    }

    for (final controller in pinControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Match"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Player ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

                              Icon(
                                playerSaved[index]
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: playerSaved[index]
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: nameControllers[index],
                            enabled: !playerSaved[index],
                            decoration: const InputDecoration(
                              labelText: "Player Name",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: pinControllers[index],
                            enabled: !playerSaved[index],
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            decoration: const InputDecoration(
                              labelText: "4 Digit PIN",
                              border: OutlineInputBorder(),
                              counterText: "",
                            ),
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!playerSaved[index]) {
                                  savePlayer(index);
                                } else {
                                  setState(() {
                                    playerSaved[index] = false;
                                  });
                                }
                              },
                              icon: Icon(
                                playerSaved[index] ? Icons.edit : Icons.check,
                              ),
                              label: Text(playerSaved[index] ? "Edit" : "Save"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (!playerSaved.every((saved) => saved)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Save all 4 players first")),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "All players saved. Ready for bidding screen.",
                      ),
                    ),
                  );

                  List<Player> players = [];

                  for (int i = 0; i < 4; i++) {
                    players.add(
                      Player(
                        name: nameControllers[i].text.trim(),
                        pin: pinControllers[i].text.trim(),
                      ),
                    );
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BiddingScreen(players: players),
                    ),
                  );
                },
                child: const Text(
                  "Start Match",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
