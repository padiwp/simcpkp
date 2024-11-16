import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NursePostTestHistoryDetail extends StatefulWidget {
  const NursePostTestHistoryDetail({
    super.key,
    required this.testName,
    required this.accuracy,
    required this.correctCount,
    required this.examinee,
    required this.selectedOptions,
    required this.testId,
    required this.totalQuestions,
    required this.userId,
    required this.role,
  });

  final String testName;
  final String accuracy;
  final String correctCount;
  final String examinee;
  final Map<String, dynamic>? selectedOptions;
  final String totalQuestions;
  final String testId;
  final String userId;
  final String role;

  @override
  State<NursePostTestHistoryDetail> createState() =>
      _NursePostTestHistoryDetailState();
}

class _NursePostTestHistoryDetailState
    extends State<NursePostTestHistoryDetail> {
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    print(widget.accuracy);
  }

  void fetchQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("posttest")
        .doc(widget.testId)
        .collection("questions")
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        questions = snapshot.docs
            .map((doc) => doc.data())
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Post Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 10),
          Text('Nama Tes: ${widget.testName}'),
          Text('Jumlah Soal: ${widget.totalQuestions}'),
          Text('Jawaban Benar: ${widget.correctCount}'),
          Text(
            'Nilai: ${widget.accuracy.split('.')[0]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Status: ${int.parse(widget.accuracy.split('.')[0]) >= 90 ? 'LULUS' : 'TIDAK LULUS'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: int.parse(widget.accuracy.split('.')[0]) >= 90
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          if (questions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: questions
                  .asMap()
                  .entries
                  .map(
                    (entry) => QuestionCard(
                      questionNumber:
                          int.parse(entry.value['number']), // Parsing as int
                      question: entry.value['question'],
                      options: entry.value['options'] ?? [],
                      answer: entry.value['answer'] ?? "",
                      selectedOptions: widget.selectedOptions ?? {},
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final String question;
  final List<dynamic> options;
  final String answer;
  final Map<String, dynamic> selectedOptions;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.answer,
    required this.selectedOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soal $questionNumber:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          question,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: options
              .asMap()
              .entries
              .map(
                (entry) => OptionWidget(
                  option: entry.value,
                  isCorrect: entry.value == answer,
                  isSelected: entry.value == selectedOptions["$questionNumber"],
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Jawaban Benar: $answer',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Opsi yang Dipilih: ${selectedOptions["$questionNumber"] ?? "Tidak Memilih"}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedOptions["$questionNumber"] == answer
                ? Colors.green
                : Colors.red,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class OptionWidget extends StatelessWidget {
  final String option;
  final bool isCorrect;
  final bool isSelected;

  const OptionWidget({
    super.key,
    required this.option,
    required this.isCorrect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? Colors.red : Colors.grey),
              color: isSelected
                  ? isCorrect
                      ? Colors.green
                      : Colors.red
                  : Colors.transparent,
            ),
            child: Center(
              child: Text(
                option.split(". ")[0],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            option.split(". ")[1],
          ),
        ],
      ),
    );
  }
}
