import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/pages/upload.dart';
import 'package:app/utils/colors.dart';
import 'package:app/admin/module/modul_detail.dart'; // Import ModuleDetail

class ModulList extends StatefulWidget {
  const ModulList({
    super.key,
    required this.userId,
    required this.role,
    required this.examinee,
  });

  final String userId;
  final String role;
  final String examinee;

  @override
  State<ModulList> createState() => _ModulListState();
}

class _ModulListState extends State<ModulList> {
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  List<String> fileListPerawat = [];
  List<String> fileListSpv = [];
  Map<String, Map<String, String>> fileDetailsPerawat = {};
  Map<String, Map<String, String>> fileDetailsSpv = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    storage = FirebaseStorage.instance;
    requestStoragePermission();
    fetchFileList();
  }

  void requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> fetchFileList() async {
    try {
      ListResult resultPerawat =
          await storage.ref().child('modul_perawat').listAll();
      ListResult resultSpv = await storage.ref().child('modul_spv').listAll();
      setState(() {
        fileListPerawat = resultPerawat.items.map((item) => item.name).toList();
        fileListSpv = resultSpv.items.map((item) => item.name).toList();
        isLoading = false; // Setelah selesai memuat daftar file
      });
      await fetchFileDetails();
    } catch (e) {
      print('Error fetching file list: $e');
      setState(() {
        isLoading =
            false; // Setelah selesai memuat daftar file (bahkan jika ada kesalahan)
      });
    }
  }

  Future<void> fetchFileDetails() async {
    await fetchFileDetailsForRole(
        'modul_perawat', fileListPerawat, fileDetailsPerawat);
    await fetchFileDetailsForRole('modul_spv', fileListSpv, fileDetailsSpv);
  }

  Future<void> fetchFileDetailsForRole(String role, List<String> fileList,
      Map<String, Map<String, String>> fileDetails) async {
    for (String fileName in fileList) {
      try {
        Reference ref = storage.ref().child(role).child(fileName);
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
        title: const Text("Daftar Modul"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadPage(),
                ),
              );
            },
            child: const Text('Unggah Berkas'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.primary,
                  )) // Menampilkan CircularProgressIndicator jika isLoading true
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          tabs: [
                            Tab(
                              text: 'Perawat',
                            ),
                            Tab(text: 'Penyelia'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildModulList(fileListPerawat,
                                  fileDetailsPerawat, 'modul_perawat'),
                              _buildModulList(
                                  fileListSpv, fileDetailsSpv, 'modul_spv'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulList(List<String> fileList,
      Map<String, Map<String, String>> fileDetails, String folder) {
    return ListView.builder(
      itemCount: fileList.length,
      itemBuilder: (context, index) {
        String fileName = fileList[index];
        return Column(
          children: [
            ListTile(
              title: Text(fileName),
              subtitle: fileDetails.containsKey(fileName)
                  ? Text('Size: ${fileDetails[fileName]!['size']}')
                  : const Text('Loading...'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleDetail(
                      role: widget.role,
                      fileName: fileName,
                      userId: widget.userId,
                      folder: folder, // Kirim informasi folder ke ModuleDetail
                    ),
                  ),
                );
              },
            ),
            const Divider(color: Colors.black), // Tambahkan Divider di sini
          ],
        );
      },
    );
  }
}
