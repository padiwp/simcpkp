import 'package:app/supervisor/supervisor_pretest_history_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import halaman detail

class SupervisorPreTestHistoryList extends StatefulWidget {
  const SupervisorPreTestHistoryList({
    super.key,
    required this.userId,
    required this.role,
    required this.examinee,
  });

  final String userId;
  final String role;
  final String examinee;

  @override
  State<SupervisorPreTestHistoryList> createState() =>
      _SupervisorPreTestHistoryListState();
}

class _SupervisorPreTestHistoryListState
    extends State<SupervisorPreTestHistoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Riwayat Pre Test'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pretest_history')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada data tersedia'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];

              return ListTile(
                title: Text(document['testName']),
                subtitle: Text('Nilai: ${document['accuracy'].split('.')[0]}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupervisorPreTestHistoryDetail(
                        // Kirim data detail ke halaman berikutnya jika diperlukan
                        testName: document['testName'],
                        accuracy: document['accuracy'],
                        correctCount: document["correctCount"],
                        examinee: document["examinee"],
                        selectedOptions: document["selectedOptions"],
                        testId: document["testId"],
                        totalQuestions: document["totalQuestions"],
                        userId: document["userId"],
                        role: document["role"],

                        // Kirim parameter lainnya jika diperlukan
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
