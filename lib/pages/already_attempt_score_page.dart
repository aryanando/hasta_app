import 'package:flutter/material.dart';

class AlreadyAttemptScorePage extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const AlreadyAttemptScorePage({Key? key, required this.responseData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the data using null-aware operators.
    final attemptData = responseData['attemptData'] ?? {};
    final score = responseData['score'] ?? 0;
    final quiz = attemptData['quiz'] ?? {};
    final answers = attemptData['answers'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Result"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quiz: ${quiz['name'] ?? 'Unknown Quiz'}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Score: $score",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              "Resume:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
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
          // Pops all routes until the first (home or quizzes page) is reached.
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        label: Text("Tutup"),
        icon: Icon(Icons.close),
      ),
    );
  }
}
