import 'package:flutter/material.dart';

class QuizScorePage extends StatelessWidget {
  final Map<String, dynamic> attemptData;

  const QuizScorePage({super.key, required this.attemptData});

  @override
  Widget build(BuildContext context) {
    final score = attemptData['score'];
    final dataAttempt = attemptData['dataAttempt'];
    print(attemptData);
    final quiz = dataAttempt['quiz'] ?? attemptData['attemptData'];
    final answers = dataAttempt['answers'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quiz: ${quiz['name']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Score: $score"),
            const SizedBox(height: 16),
            const Text(
              "Resume:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  return ListTile(
                    title: Text("Question ID: ${answer['quiz_question_id']}"),
                    subtitle: Text(
                        "Selected Option: ${answer['question_option_id']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Pop all pushed quiz widgets and return to the quizzes page.
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        label: const Text("Tutup"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
