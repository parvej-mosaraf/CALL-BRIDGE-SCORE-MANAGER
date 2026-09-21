import 'package:flutter/material.dart';

import '../models/player.dart';
import 'bidding_screen.dart';

class ScoreboardScreen extends StatelessWidget {
  final List<Player> players;

  const ScoreboardScreen({super.key, required this.players});

  // ==========================================
  // START NEXT ROUND
  // ==========================================
  void startNextRound(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Start Next Round?"),
          content: const Text(
            "Previous rounds will be kept. "
            "Players will enter new calls.",
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

                // Clear only current call/tricks.
                // History remains untouched.
                for (final player in players) {
                  player.call = null;
                  player.tricksWon = 0;
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BiddingScreen(players: players),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Start"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // END MATCH
  // ==========================================
  void endMatch(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("End Match?"),
          content: const Text("Are you sure you want to end this match?"),
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

                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("End Match"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scoreboard"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 50,
                    dataRowMinHeight: 45,
                    dataRowMaxHeight: 55,

                    columns: [
                      const DataColumn(label: Text("")),

                      for (final player in players)
                        DataColumn(
                          label: SizedBox(
                            width: 75,
                            child: Text(
                              player.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],

                    rows: [
                      // ==========================================
                      // R1
                      // ==========================================
                      if (players.isNotEmpty &&
                          players.first.roundTricks.isNotEmpty)
                        DataRow(
                          cells: [
                            const DataCell(
                              Text(
                                "R1",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            for (final player in players)
                              DataCell(
                                Text(
                                  player.scoreHistory[0].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),

                      // ==========================================
                      // CALL + RESULT
                      // ==========================================
                      for (
                        int callIndex = 0;
                        callIndex <
                            (players.isEmpty
                                ? 0
                                : players.first.roundCalls.length);
                        callIndex++
                      ) ...[
                        // --------------------------
                        // CALL
                        // --------------------------
                        DataRow(
                          cells: [
                            const DataCell(
                              Text(
                                "Call",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            for (final player in players)
                              DataCell(
                                Text(player.roundCalls[callIndex].toString()),
                              ),
                          ],
                        ),

                        // --------------------------
                        // RESULT
                        // --------------------------
                        if (players.isNotEmpty &&
                            players.first.roundTricks.length > callIndex + 1)
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  "R${callIndex + 2}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              for (final player in players)
                                DataCell(
                                  Text(
                                    player.scoreHistory[callIndex + 1]
                                        .toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          player.scoreHistory[callIndex + 1] >
                                              player.scoreHistory[callIndex]
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==========================================
            // BACK TO ROUND
            // ==========================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Round"),
              ),
            ),

            const SizedBox(height: 8),

            // ==========================================
            // NEXT ROUND
            // ==========================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  startNextRound(context);
                },
                icon: const Icon(Icons.skip_next),
                label: const Text("Next Round"),
              ),
            ),

            const SizedBox(height: 8),

            // ==========================================
            // END MATCH
            // ==========================================
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  endMatch(context);
                },
                icon: const Icon(Icons.stop_circle),
                label: const Text("End Match"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
