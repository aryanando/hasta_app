import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hasta_app/pages/quiz_score_page.dart';
import 'package:hasta_app/services/api_client.dart';

class AttemptQuizPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final int quizAttemptId; // Provided when starting the quiz

  const AttemptQuizPage({
    super.key,
    required this.quiz,
    required this.quizAttemptId,
  });

  @override
  _AttemptQuizPageState createState() => _AttemptQuizPageState();
}

class _AttemptQuizPageState extends State<AttemptQuizPage> {
  // Map to store the selected answer for each question
  Map<int, int> selectedAnswers = {};

  // Send answer to the API each time an option is chosen.
  Future<void> sendAnswer(int quizQuestionId, int questionOptionId) async {
    // print('${widget.quiz} $quizQuestionId $questionOptionId');
    try {
      Response response = await ApiClient().post(
        '/quiz/question/answer',
        data: {
          'quiz_attempt_id': widget.quizAttemptId,
          'quiz_question_id': quizQuestionId,
          'question_option_id': questionOptionId,
        },
      );
      print('Answer sent: ${response.data}');
    } catch (error) {
      print('Error sending answer: $error');
      // Optionally, show an error message.
    }
  }

  // Call the score endpoint and navigate to ScorePage.
  Future<void> finishQuiz() async {
    try {
      Response response = await ApiClient().get(
        '/quiz/user/attempt/${widget.quiz['id']}',
      );
      if (response.data['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScorePage(
              attemptData: response.data['data'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.data['message']}")),
        );
      }
    } catch (error) {
      print('Error finishing quiz: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error finishing quiz")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List questions = widget.quiz['questions'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['name'] ?? 'Attempt Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display quiz description if available.
            Text(
              widget.quiz['description'] ?? '',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            // Expanded list of questions.
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  var questionItem = questions[index];

                  var question = questionItem['question'];
                  // print(
                  //     'Test data ku${questionItem['id']} ${questions.length}');
                  if (question == null) {
                    return Container(
                        child: const Text('Missing question data'));
                  }
                  List options = question['options'] ?? [];
                  int quizQuestionId = questionItem['id'];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: ${question['name']}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          ...options.map<Widget>((option) {
                            // print(option);
                            return RadioListTile<int>(
                              title: Text(option['name']),
                              value: option['id'],
                              groupValue: selectedAnswers[quizQuestionId],
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[quizQuestionId] = value!;
                                });
                                // Send answer when an option is chosen.
                                sendAnswer(quizQuestionId, value!);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: finishQuiz,
        label: const Text("Selesai"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
