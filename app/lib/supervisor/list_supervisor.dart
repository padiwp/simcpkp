import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListSupervisorPage extends StatefulWidget {
  final String role;
  final String userId;
  const ListSupervisorPage({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  State<ListSupervisorPage> createState() => _ListSupervisorPageState();
}

class _ListSupervisorPageState extends State<ListSupervisorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: widget.role)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ada kesalahan'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Supervisor tidak ditemukan'));
          }

          var users = snapshot.data!.docs;

          return ListView.separated(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
