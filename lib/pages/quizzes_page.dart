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

  Future<void> attemptQuiz(dynamic quiz) async {
    if (quiz == null || !quiz.containsKey('id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Quiz data is not available.")),
      );
      return;
    }

    final quizId = quiz['id'] as int;
    try {
      Response response = await ApiClient().post('/quiz/user/attempt/$quizId');
      final message = response.data['message'] as String;
      final responseData = response.data['data'];

      print("🟢 API Response: $responseData");

      if (message == "User Already Attempt Quiz") {
        final attemptData = responseData['attemptData'];
        if (attemptData != null) {
          final List<dynamic> answers = attemptData['answers'] ?? [];
          if (answers.isEmpty) {
            // If user attempted but has no answers, allow them to continue
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttemptQuizPage(
                  quiz: quiz,
                  quizAttemptId: attemptData['id'],
                ),
              ),
            );
            return;
          }
          // User has attempted and answered, go to score page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlreadyAttemptScorePage(
                responseData: responseData,
              ),
            ),
          );
        }
      } else if (message == "Attempt Quiz Successful" ||
          message == "User Has Attempt Quiz Successful") {
        // ✅ Handling First-time attempt (API response provides 'id' directly)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttemptQuizPage(
              quiz: quiz,
              quizAttemptId: responseData['id'], // Use direct ID from response
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected response: $message")),
        );
      }
    } catch (error) {
      print('❌ Error attempting quiz: $error');
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
                if (quiz == null || quiz['id'] == null) {
                  return const SizedBox(); // Return an empty widget if data is missing
                }
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(quiz['name'] ?? "Unknown Quiz"),
                    subtitle: Text(quiz['description'] ?? "No description"),
                    trailing: IconButton(
                      icon: Icon(
                        alreadyAttempted ? Icons.visibility : Icons.play_arrow,
                        color: Colors.blue,
                        size: 28,
                      ),
                      tooltip: alreadyAttempted ? 'Lihat Score' : 'Ikuti',
                      onPressed: () => {
                        alreadyAttempted
                            ? attemptQuiz(quiz)
                            : _confirmAttemptQuiz(context, quiz)
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmAttemptQuiz(BuildContext context, dynamic quiz) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin mencoba kuis '${quiz['name']}'?"),
              const SizedBox(height: 12),
              const Text(
                "⚠️ Catatan: Kuis ini harus diselesaikan dalam percobaan pertama. Jika keluar sebelum selesai, Anda mungkin tidak dapat mengulanginya.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog before attempting quiz
                attemptQuiz(quiz);
              },
              child: const Text("Ya, Lanjut"),
            ),
          ],
        );
      },
    );
  }
}
