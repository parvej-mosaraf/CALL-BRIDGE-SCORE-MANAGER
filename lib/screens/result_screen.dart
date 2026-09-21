import 'package:flutter/material.dart';

import '../models/player.dart';
import 'scoreboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;

  const ResultScreen({super.key, required this.players});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late List<TextEditingController> trickControllers;

  bool scoreCalculated = false;

  @override
  void initState() {
    super.initState();

    trickControllers = List.generate(
      widget.players.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in trickControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void calculateScore() {
    if (scoreCalculated) {
      return;
    }

    int totalWon = 0;

    // Check all entered values first.
    for (int i = 0; i < widget.players.length; i++) {
      int? won = int.tryParse(trickControllers[i].text.trim());

      if (won == null || won < 0 || won > 13) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Enter a valid trick number for ${widget.players[i].name}",
            ),
          ),
        );
        return;
      }

      totalWon += won;
    }

    // Exactly 13 tricks must be distributed.
    if (totalWon != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Total tricks must be 13. Current total: $totalWon"),
        ),
      );
      return;
    }

    // Calculate score for each player.
    for (int i = 0; i < widget.players.length; i++) {
      int won = int.parse(trickControllers[i].text.trim());

      int call = widget.players[i].call!;

      widget.players[i].tricksWon = won;

      // Save round information.
      widget.players[i].roundTricks.add(won);
      widget.players[i].roundCalls.add(call);

      double score;

      // Custom Call Bridge scoring rule:
      //
      // Call N:
      // N, N+1 or N+2 tricks = +N
      // Anything below N or above N+2 = -N
      if (won >= call && won <= call + 2) {
        score = call.toDouble();
      } else {
        score = -call.toDouble();
      }

      widget.players[i].totalScore += score;
      widget.players[i].roundScores.add(score);
    }

    setState(() {
      scoreCalculated = true;
    });

    showScoreDialog();
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Round Complete"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final player in widget.players)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(player.name)),
                      Text(
                        player.roundScores.last >= 0
                            ? "+${player.roundScores.last.toStringAsFixed(0)}"
                            : player.roundScores.last.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: player.roundScores.last >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Round Result"),
        centerTitle: true,
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
              "Enter the number of tricks collected",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              "Total tricks must be exactly 13.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Call: ${player.call}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: trickControllers[index],
                              enabled: !scoreCalculated,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                labelText: "Tricks",
                                hintText: "0–13",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: scoreCalculated ? null : calculateScore,
                child: Text(
                  scoreCalculated ? "Score Calculated" : "Calculate Score",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
