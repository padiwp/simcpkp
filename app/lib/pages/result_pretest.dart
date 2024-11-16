import 'package:app/login.dart';
import 'package:app/admin/admin.dart';
import 'package:app/pages/nurse.dart';
import 'package:app/pages/supervisor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/utils/colors.dart';

class ResultPreTestPage extends StatefulWidget {
  final String testId;
  final String testName;
  final Map<String, dynamic> selectedOptions;
  final List<int> selectedQuestionIndexes;
  final Map<String, dynamic> correctAnswer;
  final String modulStatus;
  final String userId;
  final String role;
  final String examinee;

  const ResultPreTestPage({
    super.key,
    required this.testId,
    required this.selectedOptions,
    required this.selectedQuestionIndexes,
    required this.correctAnswer,
    required this.testName,
    required this.modulStatus,
    required this.userId,
    required this.role,
    required this.examinee,
  });

  @override
  _ResultPreTestPageState createState() => _ResultPreTestPageState();
}

class _ResultPreTestPageState extends State<ResultPreTestPage> {
  late int correctCount;
  late int totalQuestions;
  late double accuracy;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    calculateAccuracy();
    saveDataToFirestore();
    saveHistoryToFirestore();

    print("SELECTED_OPTIONS${widget.selectedOptions}");
    print("SELECTED_QUESTION_INDEXES${widget.selectedQuestionIndexes}");
  }

  void _resetValues() {
    widget.selectedOptions.clear();

    widget.selectedQuestionIndexes.clear();
  }

  void calculateAccuracy() {
    correctCount = 0;
    totalQuestions = widget.correctAnswer.length;

    widget.correctAnswer.forEach((key, value) {
      if (widget.selectedOptions[key] == value) {
        correctCount++;
      }
    });

    accuracy = correctCount / totalQuestions;
  }

  void saveDataToFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference pretestCollection = firestore.collection("pretest");

      await pretestCollection
          .doc(widget.testId)
          .collection("modul_authorization")
          .doc(widget.userId)
          .set({
        'testId': widget.testId,
        'testName': widget.testName,
        'correctCount': correctCount.toString(),
        'totalQuestions': totalQuestions.toString(),
        'accuracy': (accuracy * 100).toString(),
        'modulStatus': widget.modulStatus,
        'userId': widget.userId,
        'examinee': widget.examinee,
        'selectedOptions': widget.selectedOptions,
        'role': widget.role,
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to save data: $error';
      });
    }
  }

  void saveHistoryToFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference pretestCollection =
          firestore.collection("pretest_history");

      await pretestCollection.doc(widget.testId).set({
        'testId': widget.testId,
        'testName': widget.testName,
        'correctCount': correctCount.toString(),
        'totalQuestions': totalQuestions.toString(),
        'accuracy': (accuracy * 100).toString(),
        'modulStatus': widget.modulStatus,
        'userId': widget.userId,
        'examinee': widget.examinee,
        'selectedOptions': widget.selectedOptions,
        'role': widget.role,
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Gagal simpan data : $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const Text("Hasil"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              const Text(
                "Nilai Anda",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getColor(accuracy),
                ),
                child: Center(
                  child: Text(
                    (accuracy * 100).toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.testName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Text(
              //   "Jawaban Benar : $correctCount",
              //   style: const TextStyle(
              //     color: Colors.green,
              //     fontSize: 18,
              //   ),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Text(
              //   "Jumlah Soal : $totalQuestions",
              //   style: const TextStyle(
              //     color: AppColors.primary,
              //     fontSize: 18,
              //   ),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  // await FirebaseAuth.instance.signOut();
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const LoginPage(),
                  //   ),
                  // );
                  _resetValues();
                  // Navigate based on user role
                  if (widget.role == "Admin") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Admin(
                          role: widget.role,
                        ),
                      ),
                      (route) => false,
                    );
                  } else if (widget.role == "Perawat") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Perawat(
                          role: widget.role,
                        ),
                      ),
                      (route) => false,
                    );
                  } else if (widget.role == "Penyelia") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Penyelia(
                          role: widget.role,
                        ),
                      ),
                      (route) => false,
                    );
                  } else {
                    // Default to go to LoginPage
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color getColor(double accuracy) {
  if (accuracy > 0.75) {
    return Colors.green;
  } else if (accuracy >= 0.5 && accuracy <= 0.75) {
    return Colors.yellow;
  } else if (accuracy >= 0.25 && accuracy < 0.5) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
