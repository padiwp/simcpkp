import 'package:app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/quiz_posttest.dart';

class QuizPostTestConfirmation extends StatefulWidget {
  const QuizPostTestConfirmation({
    super.key,
    required this.testId,
    required this.testName,
    required this.testStartDate,
    required this.testDueDate,
    required this.testDuration,
    required this.testLecturer,
    required this.role,
    required this.examinee,
    required this.userId,
    required this.pretestId,
  });

  final String testId;
  final String testName;
  final String testStartDate;
  final String testDueDate;
  final String testLecturer;
  final String testDuration;
  final String role;
  final String examinee;
  final String userId;
  final String pretestId;

  @override
  State<QuizPostTestConfirmation> createState() =>
      _QuizPostTestConfirmationState();
}

class _QuizPostTestConfirmationState extends State<QuizPostTestConfirmation> {
  String fileId = "";
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String collectionName =
        widget.role == "Perawat" ? 'modul_perawat' : 'modul_spv';
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('posttest')
          .doc(widget.testId)
          .get();

      if (snapshot.exists) {
        if (widget.role == "Perawat") {
          dynamic fileIdNurse = snapshot.data()?['fileIdNurse'];
          if (fileIdNurse != null) {
            fileId = fileIdNurse;
            print('File ID Perawat: $fileId');
          } else {
            print('File ID Perawat tidak ditemukan');
          }
        } else if (widget.role == "Penyelia") {
          dynamic fileIdSupervisor = snapshot.data()?['fileIdSupervisor'];
          if (fileIdSupervisor != null) {
            fileId = fileIdSupervisor;
            print('File ID Penyelia: $fileId');
          } else {
            print('File ID Penyelia tidak ditemukan');
          }
        } else {
          print('Role tidak valid');
        }

        // Add a check to ensure fileId is not empty or null
        if (fileId.isNotEmpty) {
          CollectionReference modulAuthorizationCollection = FirebaseFirestore
              .instance
              .collection(collectionName)
              .doc(fileId)
              .collection('modul_downloaded');

          QuerySnapshot moduleSnapshot = await modulAuthorizationCollection
              .where('userId', isEqualTo: widget.userId)
              .get();
          if (moduleSnapshot.docs.isNotEmpty) {
            setState(() {
              _isAuthorized = true;
            });
          }
          print(fileId);
        }
      } else {
        print('Dokumen tidak ditemukan');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Informasi Post Test"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildRow('Nama Tes :', widget.testName),
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
                  style: TextStyle(fontSize: 12),
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
                  backgroundColor:
                      _isAuthorized ? AppColors.primary : Colors.grey,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _isAuthorized
                    ? () {
                        print('PostTest ID : ${widget.pretestId}');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPostTest(
                              userId: widget.userId,
                              examinee: widget.examinee,
                              role: widget.role,
                              testId: widget.testId,
                              testName: widget.testName,
                              testDuration: widget.testDuration,
                              pretestId: widget.pretestId,
                            ),
                          ),
                        );
                      }
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Post Test Dilarang"),
                              content: const Text(
                                  "Anda harus mendownload modulnya terlebih dahulu"),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppColors.primary),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                child: const Text(
                  'Mulai Post Test',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
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
