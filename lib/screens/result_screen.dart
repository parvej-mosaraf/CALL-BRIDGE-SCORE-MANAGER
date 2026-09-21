import 'package:flutter/material.dart';
import '../models/player.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;

  const ResultScreen({super.key, required this.players});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool scoreCalculated = false;
  late List<TextEditingController> trickControllers;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Round Result")),
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
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text("Call: ${player.call}"),

                          const SizedBox(height: 12),

                          TextField(
                            controller: trickControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Tricks Won",
                              border: OutlineInputBorder(),
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
              child: ElevatedButton(
                onPressed: () {
                  calculateScores();
                },
                child: const Text("Calculate Score"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void calculateScores() {
    if (scoreCalculated) {
      return;
    }
    int totalWon = 0;
    for (int i = 0; i < widget.players.length; i++) {
      int? won = int.tryParse(trickControllers[i].text);

      if (won == null || won < 0 || won > 13) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid tricks won for ${widget.players[i].name}"),
          ),
        );

        return;
      }

      widget.players[i].tricksWon = won;

      totalWon += won;

      int call = widget.players[i].call!;

      if (won >= call && won <= call + 2) {
        double score = call.toDouble();

        widget.players[i].totalScore += score;

        widget.players[i].roundScores.add(score);
      } else {
        double score = -call.toDouble();

        widget.players[i].totalScore += score;

        widget.players[i].roundScores.add(score);
      }
    }
    if (totalWon != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Total tricks must be 13. Current total: $totalWon"),
        ),
      );
      return;
    }
    scoreCalculated = true;
    showScoreDialog();
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Round Score"),

          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.players.map((player) {
                return ListTile(
                  title: Text(player.name),
                  trailing: Text(player.totalScore.toStringAsFixed(1)),
                );
              }).toList(),
            ),
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
}
