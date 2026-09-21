import 'package:flutter/material.dart';
import '../models/player.dart';
import 'result_screen.dart';

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
            Text(
              callsRevealed
                  ? "Calls Revealed"
                  : "${widget.players.where((player) => player.hasSubmittedCall).length}/4 Players Submitted",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
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
                          : Icon(
                              player.hasSubmittedCall
                                  ? Icons.lock
                                  : Icons.lock_outline,
                              size: 28,
                            ),

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
                onPressed: !callsRevealed
                    ? (allPlayersSubmitted() ? revealCalls : null)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ResultScreen(players: widget.players),
                          ),
                        );
                      },
                child: Text(callsRevealed ? "Start Round" : "Reveal Calls"),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reveal Calls?"),
          content: const Text(
            "All 4 players have submitted their calls.\n\n"
            "Once the calls are revealed, they cannot be changed.",
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
                Navigator.pop(context);

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
    final callController = TextEditingController(
      text: widget.players[playerIndex].call?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            widget.players[playerIndex].hasSubmittedCall
                ? "Edit Call"
                : "Enter Call",
          ),
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

                if (value == null || value < 2 || value > 13) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Call must be between 2 and 13"),
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
