// ignore_for_file: use_build_context_synchronously

import 'package:app/pages/modul.dart';
import 'package:app/pages/dashboard.dart';
import 'package:app/pages/posttest.dart';
import 'package:app/pages/pretest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:app/utils/colors.dart';

import '../login.dart';

enum _SelectedTab { dashboard, pretest, course, posttest }

class Perawat extends StatefulWidget {
  final String role; // Tambahkan variabel role
  const Perawat({super.key, required this.role});

  @override
  State<Perawat> createState() => _UserState();
}

class _UserState extends State<Perawat> {
  var _selectedTab = _SelectedTab.dashboard;

  void _handleIndexChanged(int index) {
    setState(() {
      _selectedTab = _SelectedTab.values[index];
    });
  }

  String name = '';
  String splitName = '';
  String email = '';
  String userId = '';
  String registrationNumber =
      ''; // Tambahkan variabel untuk menyimpan nama pengguna

  @override
  void initState() {
    super.initState();
    fetchName(); // Panggil fungsi untuk mengambil nama pengguna saat inisialisasi widget
  }

  Future<void> fetchName() async {
    // Ambil data pengguna dari Firestore
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!
                .uid) // Menggunakan UID pengguna yang saat ini login
            .get();

    // Periksa apakah dokumen ada dan data pengguna ada di dalamnya
    if (userSnapshot.exists && userSnapshot.data() != null) {
      setState(() {
        userId = userSnapshot.id;
        registrationNumber = userSnapshot.data()!['registrationNumber'];
        email = userSnapshot.data()!['email'];
        // Ambil nama pengguna dari data pengguna
        name = userSnapshot.data()!['name']
            as String; // Cast properti 'name' ke String
        List<String> nameParts =
            name.split(' '); // Pisahkan nama menjadi bagian-bagian
        splitName = nameParts
            .first; // Gunakan bagian pertama (nama depan) sebagai nama pengguna
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text(
              "Selamat Datang, $splitName!",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  logout(context);
                },
                icon: const Icon(
                  Icons.logout,
                ),
                color: Colors.black,
              )
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(top: 77),
              child: DotNavigationBar(
                enablePaddingAnimation: true,
                backgroundColor: Colors.grey.withOpacity(0.5),
                currentIndex: _SelectedTab.values.indexOf(_selectedTab),
                onTap: _handleIndexChanged,
                items: [
                  /// Home
                  DotNavigationBarItem(
                      icon: const Icon(Icons.home_rounded),
                      selectedColor: Colors.white,
                      unselectedColor: AppColors.primary),

                  /// Likes
                  DotNavigationBarItem(
                      icon: const Icon(Icons.assignment_sharp),
                      selectedColor: Colors.white,
                      unselectedColor: AppColors.primary),

                  /// Search
                  DotNavigationBarItem(
                      icon: const Icon(Icons.collections_bookmark_rounded),
                      selectedColor: Colors.white,
                      unselectedColor: AppColors.primary),

                  /// Profile
                  DotNavigationBarItem(
                      icon: const Icon(Icons.assignment_turned_in_rounded),
                      selectedColor: Colors.white,
                      unselectedColor: AppColors.primary),
                ],
              ),
            ),
          ),
          body: IndexedStack(
            index: _selectedTab.index,
            children: [
              Dashboard(
                registrationNumber: registrationNumber,
                role: widget.role,
                name: name,
                email: email,
                userId: userId,
              ),
              PreTest(
                userId: userId,
                role: widget.role,
                examinee: name,
              ),
              Modul(
                role: widget.role,
                userId: userId,
                examinee: name,
              ),
              PostTest(
                userId: userId,
                role: widget.role,
                examinee: name,
              )
            ],
          )),
    );
  }

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                // Lakukan aksi saat tombol OK ditekan
                Navigator.of(context).pop(); // Close dialog
                // Tambahkan proses logout di sini
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                } catch (e) {
                  // Handle error jika gagal logout
                  print("Error during logout: $e");
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
