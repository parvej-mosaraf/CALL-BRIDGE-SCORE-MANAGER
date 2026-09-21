import 'package:flutter/material.dart';
import '../models/player.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;

  const ResultScreen({super.key, required this.players});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
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
    // next step
  }
}
