import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/login.dart';
import 'package:app/admin/admin.dart';
import 'package:app/pages/nurse.dart';
import 'package:app/pages/supervisor.dart';
import 'package:app/utils/colors.dart';

class ResultPostTestPage extends StatefulWidget {
  final String testId;
  final String testName;
  final Map<String, dynamic> selectedOptions;
  final List<int> selectedQuestionIndexes;
  final Map<String, dynamic> correctAnswer;
  final String modulStatus;
  final String userId;
  final String role;
  final String examinee;
  final String pretestId;

  const ResultPostTestPage({
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
    required this.pretestId,
  });

  @override
  _ResultPostTestPageState createState() => _ResultPostTestPageState();
}

class _ResultPostTestPageState extends State<ResultPostTestPage> {
  late int correctCount;
  late int totalQuestions;
  late double accuracy;
  String errorMessage = '';
  double scorePreTest = 0.0;
  double meanScore = 0.0;

  @override
  void initState() {
    super.initState();

    calculateAccuracy();
    saveDataToFirestore();
    saveHistoryToFirestore();
    // Panggil fungsi untuk mengambil nilai accuracy dari pretest
    getPreTestAccuracy();
  }

  void _resetValues() {
    widget.selectedOptions.clear();
    widget.selectedQuestionIndexes.clear();
  }

  // Fungsi untuk mengambil nilai accuracy dari pretest
  Future<void> getPreTestAccuracy() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('pretest')
          .doc(widget.pretestId)
          .collection('modul_authorization')
          .doc(widget.userId);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['accuracy'] != null) {
          final accuracyString =
              data['accuracy']; // Ambil nilai accuracy sebagai String
          final accuracyDouble =
              double.tryParse(accuracyString); // Konversi String menjadi double

          if (accuracyDouble != null) {
            setState(() {
              scorePreTest = accuracyDouble;
            });
            print('Pretest Accuracy: $scorePreTest');
          } else {
            print('Invalid accuracy value: $accuracyString');
          }
        } else {
          print('Accuracy value is missing.');
        }
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print("Error getting pre-test accuracy: $e");
    }
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
      CollectionReference pretestCollection = firestore.collection("posttest");

      await pretestCollection
          .doc(widget.testId)
          .collection("result")
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
        'description': accuracy >= 90
            ? 'SELAMAT, ANDA TELAH LULUS POST TEST'
            : 'GAGAL LUSUS, SILAKAN ULANGI POST TEST',
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Gagal menyimpan data: $error';
      });
    }
  }

  void saveHistoryToFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference pretestCollection =
          firestore.collection("posttest_history");

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
        errorMessage = 'Gagal menyimpan data: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text("Hasil"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                "Nilai Akhir Anda",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Nama Tes : ${widget.testName}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Nilai Post Test :",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    (accuracy * 100).toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Text(
              //   "Jawaban Benar : $correctCount",
              //   style: TextStyle(
              //     color: Colors.green,
              //     fontSize: 18,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Text(
              //   "Jumlah Soal : $totalQuestions",
              //   style: TextStyle(
              //     color: AppColors.primary,
              //     fontSize: 18,
              //   ),
              // ),
              // SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                accuracy * 100 >= 90
                    ? "SELAMAT, ANDA TELAH LULUS POST TEST"
                    : "GAGAL LUSUS, SILAKAN ULANGI POST TEST",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accuracy * 100 >= 90 ? Colors.green : Colors.red,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () async {
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
