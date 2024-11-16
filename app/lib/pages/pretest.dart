import 'package:app/admin/all_pretest_history_list.dart';
import 'package:app/nurse/nurse_pretest_history_list.dart';
import 'package:app/pages/quiz_pretest_confirmation.dart';
import 'package:app/supervisor/supervisor_pretest_history_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart';

class PreTest extends StatefulWidget {
  final String userId;
  final String role;
  final String examinee;

  const PreTest(
      {super.key,
      required this.userId,
      required this.role,
      required this.examinee});

  @override
  State<PreTest> createState() => _PreTestState();
}

class _PreTestState extends State<PreTest> {
  late CollectionReference moduleCollection;

  @override
  void initState() {
    super.initState();
    print(widget.role);

    // Tentukan koleksi berdasarkan role
    moduleCollection = FirebaseFirestore.instance.collection('pretest');
  }

  bool isPreTestCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Pre Test'),
        actions: [
          IconButton(
            onPressed: () {
              if (widget.role == "Penyelia") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupervisorPreTestHistoryList(
                      examinee: widget.examinee,
                      role: widget.role,
                      userId: widget.userId,
                    ),
                  ),
                );
              } else if (widget.role == "Perawat") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NursePreTestHistoryList(
                      examinee: widget.examinee,
                      role: widget.role,
                      userId: widget.userId,
                    ),
                  ),
                );
              } else if (widget.role == "Admin") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPreTestHistoryList(
                      examinee: widget.examinee,
                      role: widget.role,
                      userId: widget.userId,
                    ),
                  ),
                );
              } else {
                // Handle case where role is neither Penyelia, Perawat, nor Admin
              }
            },
            icon: const Icon(Icons.history_rounded),
            color: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              StreamBuilder(
                stream: moduleCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot test = snapshot.data!.docs[index];
                        String testId = test.id;
                        // Filter modul berdasarkan peran pengguna (role)
                        if (widget.role == "Perawat" &&
                            (test['category'] == "all" ||
                                test['category'] == "nurse")) {
                          return _buildModuleCard(test, testId);
                        } else if (widget.role == "Penyelia" &&
                            (test['category'] == "all" ||
                                test['category'] == "supervisor")) {
                          return _buildModuleCard(test, testId);
                        } else {
                          // Tidak ada modul yang sesuai dengan kriteria
                          return const SizedBox();
                        }
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(DocumentSnapshot test, String testId) {
    return MouseRegion(
      child: InkWell(
        onTap: () {
          print('Document ID: $testId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPreTestConfirmation(
                examinee: widget.examinee,
                role: widget.role,
                userId: widget.userId,
                testId: testId,
                testName: test['name'],
                testStartDate: test['start date'],
                testDueDate: test['due date'],
                testLecturer: test['lecturer'],
                testDuration: test['duration'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(25),
        child: Card(
          color: AppColors.primary.withOpacity(1),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              title: Text(
                test['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tanggal Mulai : ${test['start date']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tanggal Selesai : ${test['due date']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Pengajar : ${test['lecturer']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
