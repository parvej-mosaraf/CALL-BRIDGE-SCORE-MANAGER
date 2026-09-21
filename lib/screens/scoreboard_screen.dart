import 'package:flutter/material.dart';
import '../models/player.dart';

class ScoreboardScreen extends StatelessWidget {
  final List<Player> players;

  const ScoreboardScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    int totalRounds = players.isEmpty ? 0 : players.first.roundScores.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Scoreboard")),
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
                      const DataColumn(
                        label: Text(
                          "",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

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
                      for (int round = 0; round < totalRounds; round++) ...[
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "R${round + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            for (final player in players)
                              DataCell(
                                Text(
                                  player.roundTricks[round].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: player.roundScores[round] >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),

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
                                Text(player.roundCalls[round].toString()),
                              ),
                          ],
                        ),
                      ],

                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              "Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          for (final player in players)
                            DataCell(
                              Text(
                                player.totalScore.toStringAsFixed(0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: player.totalScore >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Return to current round
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Round"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
