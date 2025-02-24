import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hasta_app/pages/already_attempt_score_page.dart';
import 'package:hasta_app/services/api_client.dart';
import 'package:hasta_app/pages/attempt_quiz_page.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  _QuizzesPageState createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  List<dynamic> quizzes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  // Fetch quizzes from the API endpoint "/quiz"
  Future<void> fetchQuizzes() async {
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await ApiClient().get('/quiz');
      if (response.data['success'] == true) {
        setState(() {
          quizzes = response.data['data']['quiz'] ?? [];
        });
      } else {
        print("API error: ${response.data['message']}");
      }
    } catch (error) {
      print('Error fetching quizzes: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Attempt quiz using POST request to /quiz/user/attempt/{{quiz_id}}
  Future<void> attemptQuiz(dynamic quiz) async {
    final quizId = quiz['id'] as int;
    try {
      Response response = await ApiClient().post('/quiz/user/attempt/$quizId');
      final message = response.data['message'] as String;
      if (message == "User Already Attempt Quiz") {
        // Navigate to the score page if already attempted.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlreadyAttemptScorePage(
              responseData: response.data['data'],
            ),
          ),
        );
      } else if (message == "Attempt Quiz Successful") {
        // Navigate to the attempt quiz page if new attempt created.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttemptQuizPage(
              quiz: quiz,
              quizAttemptId: response.data['data']['id'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected response: $message")),
        );
      }
    } catch (error) {
      print('Error attempting quiz: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error attempting quiz")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                // Check if the quiz has any attempts (non-empty array).
                final bool alreadyAttempted = quiz['attempts'] != null &&
                    (quiz['attempts'] as List).isNotEmpty;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(quiz['name']),
                    subtitle: Text(quiz['description']),
                    trailing: IconButton(
                      icon: Icon(
                        alreadyAttempted ? Icons.visibility : Icons.play_arrow,
                        color: Colors.blue, // Set your desired icon color.
                        size: 28,
                      ),
                      tooltip: alreadyAttempted ? 'Lihat Score' : 'Ikuti',
                      onPressed: () => attemptQuiz(quiz),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
