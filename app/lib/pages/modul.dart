import 'package:app/pages/file_description.dart';
import 'package:app/utils/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

class Modul extends StatefulWidget {
  const Modul(
      {super.key,
      required this.userId,
      required this.role,
      required this.examinee});

  // Value to be passed to the next screen
  final String userId;
  final String role;
  final String examinee;

  @override
  State<Modul> createState() => _ModulState();
}

class _ModulState extends State<Modul> {
  bool isPreTestCompleted = false;
  bool isCourseCompleted = false;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late CollectionReference moduleCollection; // Mengganti courseCollection
  List<String> fileList = [];
  Map<String, Map<String, String>> fileDetails = {};

  @override
  void initState() {
    super.initState();
    storage = FirebaseStorage.instance;
    requestStoragePermission();
    // Tentukan koleksi berdasarkan role
    moduleCollection = widget.role == 'Perawat'
        ? FirebaseFirestore.instance.collection('modul_perawat')
        : FirebaseFirestore.instance.collection('modul_spv');
    fetchFileList();
  }

  // Fungsi untuk meminta izin penyimpanan
  void requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Fetch daftar file dari Firebase Storage sesuai dengan role
  Future<void> fetchFileList() async {
    try {
      ListResult result = await storage
          .ref()
          .child(widget.role == 'Perawat' ? 'modul_perawat' : 'modul_spv')
          .listAll();
      setState(() {
        fileList = result.items.map((item) => item.name).toList();
      });
      await fetchFileDetails();
    } catch (e) {
      print('Error fetching file list: $e');
    }
  }

  // Fetch detail setiap file
  Future<void> fetchFileDetails() async {
    for (String fileName in fileList) {
      try {
        Reference ref = storage
            .ref()
            .child(widget.role == 'Perawat' ? 'modul_perawat' : 'modul_spv')
            .child(fileName);
        final metadata = await ref.getMetadata();
        setState(() {
          fileDetails[fileName] = {
            'size': '${(metadata.size! / (1024 * 1024)).toStringAsFixed(2)} MB',
          };
        });
      } catch (e) {
        print('Error fetching file details for $fileName: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Materi",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dihapus karena tidak dibutuhkan di sini
            Expanded(
              child: fileList.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ListView.builder(
                      itemCount: fileList.length,
                      itemBuilder: (context, index) {
                        String fileName = fileList[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(fileName),
                              subtitle: fileDetails.containsKey(fileName)
                                  ? Text(
                                      'Ukuran: ${fileDetails[fileName]!['size']}')
                                  : const Text('Memuat...'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FileDescriptionPage(
                                      role: widget.role,
                                      fileName: fileName,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: Colors.black,
                            ), // Tambahkan Divider di sini
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
