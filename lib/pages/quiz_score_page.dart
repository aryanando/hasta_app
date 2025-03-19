import 'package:flutter/material.dart';
import 'package:hasta_app/services/api_client.dart';

class QuizScorePage extends StatefulWidget {
  final Map<String, dynamic> attemptData;

  const QuizScorePage({super.key, required this.attemptData});

  @override
  State<QuizScorePage> createState() => _QuizScorePageState();
}

class _QuizScorePageState extends State<QuizScorePage> {
  late int quizId;
  Map<String, dynamic>? quizData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    quizId = widget.attemptData['dataAttempt']['quiz_id'];
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final response = await ApiClient().get("/quiz/id/$quizId");
      if (response.data['success']) {
        setState(() {
          quizData = response.data['data']['quiz'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load quiz data.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("❌ Error fetching quiz data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.attemptData['score'] ?? 0;
    final attemptData = widget.attemptData['dataAttempt'] ?? {};
    final answers = attemptData['answers'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(child: Text("Error loading quiz data."))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuizInfo(score),
                      const SizedBox(height: 16),
                      const Text("Answer Summary:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: quizData?['questions']?.length ?? 0,
                          itemBuilder: (context, index) {
                            final question = quizData?['questions'][index];
                            return _buildAnswerTile(question, answers);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        label: const Text("Tutup"),
        icon: const Icon(Icons.close),
      ),
    );
  }

  /// 🔹 Widget to display quiz info at the top
  Widget _buildQuizInfo(int score) {
    int totalMarks = quizData?['total_marks'] ?? 0;
    int passMarks = quizData?['pass_marks'] ?? 0;
    bool isPassed = score >= passMarks;
    double progress = totalMarks > 0 ? score / totalMarks : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Quiz Title
            Text(
              quizData?['name'] ?? 'Unknown Quiz',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Score Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isPassed ? Colors.green : Colors.red,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 12),

            // 🔹 Marks Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.grade, "Total Marks", "$totalMarks"),
                _buildInfoTile(Icons.check_circle, "Pass Marks", "$passMarks"),
                _buildInfoTile(
                  Icons.emoji_events,
                  "Your Score",
                  "$score",
                  color: isPassed ? Colors.green : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Pass/Fail Status
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPassed ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPassed ? "PASSED 🎉" : "FAILED ❌",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Small Info Tile for Total Marks, Pass Marks, and Score
  Widget _buildInfoTile(IconData icon, String title, String value,
      {Color color = Colors.black}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  /// 🔹 Widget to build each answer tile
  Widget _buildAnswerTile(Map question, List answers) {
    final userAnswer = answers.firstWhere(
      (ans) => ans['quiz_question_id'] == question['id'],
      orElse: () => {},
    );

    final userSelectedOptionId = userAnswer['question_option_id'];
    final correctOption = question['question']['options']
        .firstWhere((opt) => opt['is_correct'] == 1, orElse: () => {});

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          question['question']['name'] ?? "Unknown Question",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Your Answer: ${_getOptionText(question, userSelectedOptionId)}",
                style: TextStyle(
                  color: userSelectedOptionId == correctOption['id']
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                )),
            Text("Correct Answer: ${correctOption['name'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  /// 🔹 Get the option text by option ID
  String _getOptionText(Map question, int? optionId) {
    if (optionId == null) return "No Answer";
    final option = question['question']['options']
        .firstWhere((opt) => opt['id'] == optionId, orElse: () => {});
    return option['name'] ?? "Unknown";
  }
}
