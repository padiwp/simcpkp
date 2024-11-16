import 'package:app/pages/quiz_pretest_confirmation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart';

class PostTestList extends StatefulWidget {
  final String userId;
  final String role;
  final String examinee;

  const PostTestList(
      {super.key,
      required this.userId,
      required this.role,
      required this.examinee});

  @override
  State<PostTestList> createState() => _PostTestListState();
}

class _PostTestListState extends State<PostTestList> {
  late CollectionReference moduleCollection;

  @override
  void initState() {
    super.initState();

    // Tentukan koleksi berdasarkan role
    moduleCollection = FirebaseFirestore.instance.collection('posttest');
  }

  bool isPreTestCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Daftar Post Test'),
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

                        return _buildModuleCard(test, testId);

                        // Tidak ada modul yang sesuai dengan kriteria
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
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tanggal Mulai: ${test['start date']}',
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
                        Icons.date_range,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tanggal Selesai: ${test['due date']}',
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
                        Icons.person,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Penguji: ${test['lecturer']}',
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
