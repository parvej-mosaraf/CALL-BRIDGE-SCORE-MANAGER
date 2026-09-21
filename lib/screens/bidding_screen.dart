import 'package:flutter/material.dart';

import '../models/player.dart';
import 'result_screen.dart';
import 'scoreboard_screen.dart';

class BiddingScreen extends StatefulWidget {
  final List<Player> players;

  const BiddingScreen({super.key, required this.players});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  bool callsRevealed = false;

  // Prevent saving the same calls more than once.
  bool callsSaved = false;

  // ==========================================
  // CHECK WHETHER ALL PLAYERS SUBMITTED CALL
  // ==========================================
  bool get allCallsSubmitted {
    return widget.players.every((player) => player.call != null);
  }

  // ==========================================
  // ENTER CALL
  // ==========================================
  void enterCall(Player player) {
    if (callsRevealed) {
      return;
    }

    final pinController = TextEditingController();
    final callController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Enter Call - ${player.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: "PIN",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: callController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Call",
                  hintText: "2 - 13",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Check PIN.
                if (pinController.text.trim() != player.pin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect PIN")),
                  );
                  return;
                }

                final call = int.tryParse(callController.text.trim());

                // Check call.
                if (call == null || call < 2 || call > 13) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Call must be between 2 and 13"),
                    ),
                  );
                  return;
                }

                setState(() {
                  player.call = call;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // REVEAL CALLS
  // ==========================================
  void revealCalls() {
    if (!allCallsSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All 4 players must submit their calls first."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Reveal Calls?"),
          content: const Text(
            "All 4 players have submitted their calls.\n\n"
            "Once the calls are revealed, they cannot be changed.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // ==========================================
                // SAVE CALLS TO HISTORY
                // ==========================================
                if (!callsSaved) {
                  for (final player in widget.players) {
                    player.roundCalls.add(player.call!);
                  }

                  callsSaved = true;
                }

                setState(() {
                  callsRevealed = true;
                });
              },
              child: const Text("Reveal"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // START ROUND
  // ==========================================
  void startRound() {
    if (!callsRevealed) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(players: widget.players)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call"),
        centerTitle: true,

        // ==========================================
        // SCOREBOARD BUTTON
        // ==========================================
        actions: [
          IconButton(
            tooltip: "Scoreboard",
            icon: const Icon(Icons.table_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScoreboardScreen(players: widget.players),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Enter Call",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              callsRevealed
                  ? "Calls have been revealed."
                  : "Each player must enter their call.",
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // ==========================================
            // PLAYER LIST
            // ==========================================
            Expanded(
              child: ListView.builder(
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        player.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      trailing: callsRevealed
                          ? Text(
                              "${player.call}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              player.hasSubmittedCall
                                  ? "Submitted"
                                  : "Enter Call",
                              style: TextStyle(
                                color: player.hasSubmittedCall
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),

                      onTap: callsRevealed
                          ? null
                          : () {
                              enterCall(player);
                            },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ==========================================
            // REVEAL / START BUTTON
            // ==========================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: callsRevealed ? startRound : revealCalls,
                child: Text(callsRevealed ? "Start Round" : "Reveal Calls"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
