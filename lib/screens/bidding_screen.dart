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
    // next step
  }
}
