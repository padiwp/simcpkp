import 'package:app/supervisor/supervisor_posttest_history_detail.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import halaman detail

class SupervisorPostTestHistoryList extends StatefulWidget {
  const SupervisorPostTestHistoryList({
    super.key,
    required this.userId,
    required this.role,
    required this.examinee,
  });

  final String userId;
  final String role;
  final String examinee;

  @override
  State<SupervisorPostTestHistoryList> createState() =>
      _SupervisorPostTestHistoryListState();
}

class _SupervisorPostTestHistoryListState
    extends State<SupervisorPostTestHistoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Riwayat Post Test'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posttest_history')
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
                trailing: Text(
                  int.parse(document['accuracy'].split('.')[0]) < 90
                      ? 'TIDAK LULUS'
                      : 'LULUS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: int.parse(document['accuracy'].split('.')[0]) < 90
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupervisorPostTestHistoryDetail(
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
