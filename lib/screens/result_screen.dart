import 'package:flutter/material.dart';

import 'bidding_screen.dart';
import '../models/player.dart';
import 'scoreboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  final bool isFirstRound;

  const ResultScreen({
    super.key,
    required this.players,
    this.isFirstRound = false,
  });

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

  // ==========================================
  // CALCULATE / SAVE ROUND
  // ==========================================
  void calculateScore() {
    if (scoreCalculated) {
      return;
    }

    int totalWon = 0;

    // ==========================================
    // VALIDATE INPUT
    // ==========================================
    for (int i = 0; i < widget.players.length; i++) {
      final won = int.tryParse(trickControllers[i].text.trim());

      if (won == null || won < 0 || won > 13) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Enter a valid card number for "
              "${widget.players[i].name}",
            ),
          ),
        );
        return;
      }

      totalWon += won;
    }

    // ==========================================
    // TOTAL MUST BE 13
    // ==========================================
    if (totalWon != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Total cards must be 13. Current total: $totalWon"),
        ),
      );
      return;
    }

    // ==========================================
    // ROUND 1
    // ==========================================
    if (widget.isFirstRound) {
      for (int i = 0; i < widget.players.length; i++) {
        final won = int.parse(trickControllers[i].text.trim());

        widget.players[i].tricksWon = won;

        // R1 has no call and no score.
        // Save the cards collected as R1.
        widget.players[i].roundTricks.add(won);

        // R1 becomes the first score
        widget.players[i].scoreHistory.add(won);
      }

      setState(() {
        scoreCalculated = true;
      });

      showFirstRoundCompleteDialog();

      return;
    }

    // ==========================================
    // R2, R3, R4...
    // ==========================================
    for (int i = 0; i < widget.players.length; i++) {
      final player = widget.players[i];

      final won = int.parse(trickControllers[i].text.trim());

      // The call was already saved in BiddingScreen.
      final call = player.call!;

      player.tricksWon = won;

      // Save cards collected.
      player.roundTricks.add(won);

      int previousScore = player.scoreHistory.last;

      bool success = won >= call && won <= call + 2;

      int newScore;

      if (success) {
        newScore = previousScore + call;
      } else {
        newScore = previousScore - call;
      }

      player.scoreHistory.add(newScore);
    }

    setState(() {
      scoreCalculated = true;
    });

    showScoreDialog();
  }

  // ==========================================
  // AFTER R1
  // ==========================================
  void showFirstRoundCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Round 1 Complete"),
          content: const Text(
            "Round 1 has been saved.\n\n"
            "Now the players will enter their calls "
            "for Round 2.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                for (final player in widget.players) {
                  player.call = null;
                  player.tricksWon = 0;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BiddingScreen(players: widget.players),
                  ),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // AFTER R2/R3/R4...
  // ==========================================
  void showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
                        player.scoreHistory.last >= 0
                            ? "+${player.scoreHistory.last.toStringAsFixed(0)}"
                            : player.scoreHistory.last.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: player.scoreHistory.last >= 0
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
                Navigator.pop(dialogContext);
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
        title: Text(widget.isFirstRound ? "Round 1" : "Round Result"),
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
            Text(
              widget.isFirstRound
                  ? "Enter the cards collected by each player"
                  : "Enter the cards collected",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              "All players' cards must total exactly 13.",
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

                                if (!widget.isFirstRound)
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
                                labelText: "Cards",
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
                  scoreCalculated
                      ? (widget.isFirstRound
                            ? "R1 Saved"
                            : "R${widget.players.first.roundTricks.length} Calculated")
                      : (widget.isFirstRound ? "Save R1" : "Calculate Round"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
