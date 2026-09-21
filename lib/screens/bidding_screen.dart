import 'package:flutter/material.dart';
import '../models/player.dart';

class BiddingScreen extends StatefulWidget {
  final List<Player> players;

  const BiddingScreen({super.key, required this.players});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  bool callsRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hidden Bidding")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];

                  return Card(
                    child: ListTile(
                      title: Text(player.name),

                      trailing: callsRevealed
                          ? Text(
                              player.call?.toString() ?? "-",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.lock, size: 28),

                      onTap: () {
                        if (!callsRevealed) {
                          verifyPinAndEnterCall(index);
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allPlayersSubmitted() ? revealCalls : null,
                child: const Text("Reveal Calls"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool allPlayersSubmitted() {
    return widget.players.every((player) => player.hasSubmittedCall);
  }

  void revealCalls() {
    setState(() {
      callsRevealed = true;
    });
  }

  void verifyPinAndEnterCall(int playerIndex) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.players[playerIndex].name),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Enter PIN"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == widget.players[playerIndex].pin) {
                  Navigator.pop(context);

                  enterCall(playerIndex);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Wrong PIN")));
                }
              },
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  void enterCall(int playerIndex) {
    final callController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Call"),
          content: TextField(
            controller: callController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "1 - 13"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int? value = int.tryParse(callController.text);

                if (value == null || value < 1 || value > 13) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Call must be between 1 and 13"),
                    ),
                  );
                  return;
                }

                setState(() {
                  widget.players[playerIndex].call = value;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
