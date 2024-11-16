import 'package:app/nurse/list_nurse.dart';
import 'package:app/pages/modul.dart';
import 'package:app/pages/posttest.dart';
import 'package:app/pages/pretest.dart';
import 'package:app/supervisor/list_supervisor.dart';
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart'; // Import library Firestore

class Dashboard extends StatefulWidget {
  final String role;
  final String name;
  final String email;
  final String userId;
  final String registrationNumber;

  const Dashboard({
    super.key,
    required this.role,
    required this.name,
    required this.email,
    required this.userId,
    required this.registrationNumber,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int preTestCount = 0; // Variable untuk menyimpan jumlah dokumen pre test
  int postTestCount = 0; // Variable untuk menyimpan jumlah dokumen post test
  int nurseModuleCount = 0; // Variable untuk menyimpan jumlah modul perawat
  int userCount = 0;
  int nurseCount = 0;
  int supervisorCount = 0; // Variable untuk menyimpan jumlah pengguna
  String peran = "Admin";

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fungsi untuk mengambil data saat inisialisasi widget
  }

  // Fungsi untuk mengambil data dari Firestore
  void fetchData() async {
    QuerySnapshot preTestSnapshot =
        await FirebaseFirestore.instance.collection('pretest').get();
    QuerySnapshot postTestSnapshot =
        await FirebaseFirestore.instance.collection('posttest').get();
    QuerySnapshot nurseModuleSnapshot =
        await FirebaseFirestore.instance.collection('modul_perawat').get();
    QuerySnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Mencari dokumen dengan role "Perawat" dan "Penyelia"
    for (var doc in userSnapshot.docs) {
      var data = doc.data()
          as Map<String, dynamic>?; // Casting data ke Map<String, dynamic>?
      if (data != null) {
        if (data['role'] == 'Perawat') {
          // Memeriksa jika data memiliki role "Perawat"
          nurseCount++;
        } else if (data['role'] == 'Penyelia') {
          // Memeriksa jika data memiliki role "Penyelia"
          supervisorCount++;
        }
      }
    }

    setState(() {
      preTestCount = preTestSnapshot.size;
      postTestCount = postTestSnapshot.size;
      nurseModuleCount = nurseModuleSnapshot.size;
      userCount = userSnapshot.size;
    });
  }

  String _getImageAsset() {
    // Menentukan path gambar berdasarkan role
    switch (widget.role.toLowerCase()) {
      case 'perawat':
        return 'assets/nurse.png';
      case 'penyelia':
        return 'assets/supervisor.png';
      case 'admin':
        return 'assets/admin.png';
      default:
        return 'assets/default.png'; // Jika role tidak sesuai, tampilkan gambar default
    }
  }

  Future<int> fetchPreTestCount() async {
    String category = (widget.role == 'Perawat') ? 'nurse' : 'supervisor';

    QuerySnapshot preTestSnapshot = await FirebaseFirestore.instance
        .collection('pretest')
        .where('category', whereIn: ['all', category]).get();

    return preTestSnapshot.size;
  }

  Future<int> fetchPostTestCount() async {
    String category = (widget.role == 'Perawat') ? 'nurse' : 'supervisor';

    QuerySnapshot postTestSnapshot = await FirebaseFirestore.instance
        .collection('posttest')
        .where('category', whereIn: ['all', category]).get();

    return postTestSnapshot.size;
  }

  Future<int> fetchModuleCount() async {
    try {
      // Jika peran adalah "Perawat"
      if (widget.role == 'Perawat') {
        peran = "Perawat";
        QuerySnapshot moduleSnapshot =
            await FirebaseFirestore.instance.collection('modul_perawat').get();
        return moduleSnapshot.size;
      }
      // Jika peran adalah "Penyelia"
      else if (widget.role == 'Penyelia') {
        peran = "Supervisor";
        QuerySnapshot moduleSnapshot =
            await FirebaseFirestore.instance.collection('modul_spv').get();
        return moduleSnapshot.size;
      }
      // Jika peran tidak sesuai
      else {
        return 0;
      }
    } catch (e) {
      print('Error fetching module count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Column(
          children: [
            Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.asset(
                        _getImageAsset(), // Memanggil fungsi untuk mendapatkan path gambar sesuai role
                        fit: BoxFit.fitHeight,
                        width: 150,
                        height: 200,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.registrationNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              peran,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Apa yang ingin anda lakukan?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              (context),
                              MaterialPageRoute(
                                  builder: (context) => PreTest(
                                        examinee: widget.name,
                                        userId: widget.userId,
                                        role: widget.role,
                                      )));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.46,
                          color: Colors.amber,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Pre Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              FutureBuilder<int>(
                                future: fetchPreTestCount(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors
                                              .white), // Ubah warna circular progress indicator
                                    );
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        '${snapshot.data}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              (context),
                              MaterialPageRoute(
                                  builder: (context) => PostTest(
                                        examinee: widget.name,
                                        userId: widget.userId,
                                        role: widget.role,
                                      )));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.46,
                          color: Colors.green,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Post Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              FutureBuilder<int>(
                                future: fetchPostTestCount(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors
                                              .white), // Ubah warna circular progress indicator
                                    );
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        '${snapshot.data}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Kontainer modul perawat
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              (context),
                              MaterialPageRoute(
                                  builder: (context) => Modul(
                                        examinee: widget.name,
                                        userId: widget.userId,
                                        role: widget.role,
                                      )));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.46,
                          color: Colors.purple,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Materi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              FutureBuilder<int>(
                                future: fetchModuleCount(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors
                                              .white), // Ubah warna circular progress indicator
                                    );
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        '${snapshot.data}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Kontainer pengguna (users)
                    GestureDetector(
                      onTap: () {
                        if (widget.role == 'Penyelia') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListSupervisorPage(
                                    role: widget.role, userId: widget.userId)),
                          );
                        } else if (widget.role == 'Perawat') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListNursePage(
                                    role: widget.role, userId: widget.userId)),
                          );
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.46,
                          color: Colors
                              .orange, // Ganti warna sesuai keinginan Anda
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.role == 'Admin'
                                    ? 'Admins' // Menampilkan 'Admins' untuk role Admin
                                    : widget.role == 'Penyelia'
                                        ? 'Jumlah Supervisor' // Menampilkan 'Supervisors' untuk role Penyelia
                                        : widget.role == 'Perawat'
                                            ? 'Jumlah Perawat' // Menampilkan 'Nurses' untuk role Perawat
                                            : 'Users', // Jika tidak ada peran yang cocok, tetap tampilkan 'Users'
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.role == 'Admin'
                                    ? '$userCount' // Menampilkan jumlah pengguna untuk role Admin
                                    : widget.role == 'Penyelia'
                                        ? '$supervisorCount' // Menampilkan jumlah pengguna untuk role Penyelia
                                        : widget.role == 'Perawat'
                                            ? '$nurseCount' // Menampilkan jumlah pengguna untuk role Perawat
                                            : '0', // Jika tidak ada peran yang cocok, tampilkan '0'
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Anda bisa menambahkan lebih banyak baris kartu di sini
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
