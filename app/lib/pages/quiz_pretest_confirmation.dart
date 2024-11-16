import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/quiz_pretest.dart';

class QuizPreTestConfirmation extends StatefulWidget {
  const QuizPreTestConfirmation({
    super.key,
    required this.testId,
    required this.testName,
    required this.testStartDate,
    required this.testDueDate,
    required this.testDuration,
    required this.testLecturer,
    required this.userId,
    required this.role,
    required this.examinee,
  });

  final String testId;
  final String testName;
  final String testStartDate;
  final String testDueDate;
  final String testLecturer;
  final String testDuration;
  final String userId;
  final String role;
  final String examinee;

  @override
  State<QuizPreTestConfirmation> createState() =>
      _QuizPreTestConfirmationState();
}

class _QuizPreTestConfirmationState extends State<QuizPreTestConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Informasi Pre Test"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildRow('Nama Tes :', widget.testName),
                // buildRow('User ID:', widget.userId),
                // buildRow('Pretest ID:', widget.testId),
                buildRow('Tanggal Mulai :', widget.testStartDate),
                buildRow('Tanggal Selesai :', widget.testDueDate),
                buildRow('Pengajar :', widget.testLecturer),
                buildRow('Durasi :', '${widget.testDuration} menit'),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Petunjuk Pengisian Soal\n'
                    '1.Bacalah dengan teliti setiap pertanyaan sebelum anda menjawab\n'
                    '2.Jawablah pertanyaan untuk setiap soal dengan memilih opsi pada salah satu jawaban yang menurut Anda paling benar\n'
                    '3.Jika ada Anda ingin mengganti jawaban yang telah Anda pilih maka cukup dengan menggantinya dengan  memilih opsi jawaban yang menurut Anda paling benar\n'
                    '4.Semua pertanyaan harus dijawab oleh peserta ujian\n'
                    '5.Jika telah menjawab semua soal, silakan tekan tombol SUBMIT\n'
                    '6.Saat waktu telah habis, maka laman ujian akan tertutup dengan sendirinya dan akan muncul hasil ujian Anda',

                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 12), // Ubah sesuai kebutuhan
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Jika sudah siap, silakan mulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPreTest(
                            examinee: widget.examinee,
                            testId: widget.testId,
                            testName: widget.testName,
                            testDuration: widget.testDuration,
                            userId: widget.userId,
                            role: widget.role),
                      ),
                    );
                  },
                  child: const Text(
                    'Mulai Pre Test',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
