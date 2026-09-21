import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<TextEditingController> nameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Match")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            "Player ${index + 1}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: nameControllers[index],
                            decoration: const InputDecoration(
                              labelText: "Player Name",
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: pinControllers[index],
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            decoration: const InputDecoration(
                              labelText: "4 Digit PIN",
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
                  // validation later
                },
                child: const Text("Start Match"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
