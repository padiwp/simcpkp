import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;

class ModuleDetail extends StatefulWidget {
  final String fileName;
  final String userId;
  final String role;
  final String folder;

  const ModuleDetail({
    super.key,
    required this.fileName,
    required this.userId,
    required this.role,
    required this.folder,
  });

  @override
  State<ModuleDetail> createState() => _ModuleDetailState();
}

class _ModuleDetailState extends State<ModuleDetail> {
  late FirebaseStorage storage;
  bool _downloading = false;
  bool _downloadSuccess = false;
  bool _isAuthorized = false;
  List<String> link = [];
  String fileId = "";
  late String lastSavedFilePath; // Path file terakhir yang disimpan
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    storage = FirebaseStorage.instance;
    _checkStoragePermission();
    _fetchModuleData();
    print(widget.role);
    print(widget.userId);
    print(widget.fileName);
    print(widget.folder);
  }

  Future<void> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        var status = await Permission.manageExternalStorage.request();
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    try {
      AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
      if (build.version.sdkInt >= 30) {
        var re = await Permission.manageExternalStorage.request();
        if (re.isGranted) {
          return true;
        } else {
          return false;
        }
      } else {
        if (await permission.isGranted) {
          return true;
        } else {
          var result = await permission.request();
          if (result.isGranted) {
            return true;
          } else {
            return false;
          }
        }
      }
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  Future<void> _fetchModuleData() async {
    try {
      CollectionReference modulesCollection =
          FirebaseFirestore.instance.collection(widget.folder);
      QuerySnapshot querySnapshot = await modulesCollection
          .where('name', isEqualTo: widget.fileName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var moduleDoc = querySnapshot.docs.first;
        String testId = moduleDoc['testId'];
        link = List<String>.from(moduleDoc['link']);
        fileId = moduleDoc.id;

        CollectionReference modulAuthorizationCollection = FirebaseFirestore
            .instance
            .collection('pretest')
            .doc(testId)
            .collection('modul_authorization');

        QuerySnapshot authorizationSnapshot = await modulAuthorizationCollection
            .where('userId', isEqualTo: widget.userId)
            .get();

        if (authorizationSnapshot.docs.isNotEmpty) {
          setState(() {
            _isAuthorized = true;
          });
        }
      }
      print(fileId);
    } catch (e) {
      print('Error fetching module data: $e');
    }
  }

  Future<void> _downloadFile(String fileName, bool isAuthorized) async {
    try {
      setState(() {
        _downloading =
            true; // Set _downloading ke true sebelum memulai proses pengunduhan
      });

      Reference ref = storage.ref().child(widget.folder).child(fileName);
      final url = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      await _saveFile(fileName, response.bodyBytes);
      setState(() {
        _downloading =
            false; // Set _downloading kembali ke false setelah pengunduhan selesai
        _downloadSuccess = true;
      });
    } catch (e) {
      print('Error downloading file: $e');
      setState(() {
        _downloading =
            false; // Set _downloading kembali ke false jika terjadi kesalahan
        _downloadSuccess = false;
      });
    } finally {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_downloadSuccess ? "Berhasil Unduh" : "Gagal Unduh"),
            content: Text(_downloadSuccess
                ? "open file in your internal storage Download/nusa"
                : "Failed to download file $fileName. Please try again"),
            actions: [
              if (_downloadSuccess)
                TextButton(
                  onPressed: () async {
                    bool hasPermission =
                        await _requestPermission(Permission.storage);
                    if (hasPermission) {
                      // Permission is granted, proceed to view the file
                      if (lastSavedFilePath.isNotEmpty) {
                        final result = await OpenFile.open(lastSavedFilePath);
                        if (result.type != ResultType.done) {
                          print("Error opening file: ${result.message}");
                        }
                      } else {
                        print("Error: Last saved file path is empty");
                      }
                    } else {
                      // Permission is not granted
                      print("Permission is not granted");
                    }
                  },
                  child: const Text(
                    "Lihat Berkas",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveFile(String fileName, Uint8List bytes) async {
    try {
      final directory = Directory('/storage/emulated/0/Download/nusa/');
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }

      // Membersihkan nama file dari karakter ilegal
      fileName = fileName.replaceAll(RegExp(r'[^\w\s\-.]'), '');

      File file = File(path.join(directory.path, fileName));

      if (await file.exists()) {
        // Jika file sudah ada, tambahkan nomor urutan ke nama file
        int suffix = 1;
        String fileNameNoExt = path.basenameWithoutExtension(fileName);
        String fileExt = path.extension(fileName);
        String newName;
        do {
          newName = '$fileNameNoExt($suffix)$fileExt';
          file = File(path.join(directory.path, newName));
          suffix++;
        } while (await file.exists());
      }

      await file.writeAsBytes(bytes);
      print('File saved successfully');

      // Simpan path file terbaru
      lastSavedFilePath = file.path;
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Modul'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                widget.fileName,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Video Materi',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: link.length,
                  itemBuilder: (BuildContext context, int index) {
                    int videoNumber = index + 1;
                    return GestureDetector(
                      onTap: () async {
                        if (await canLaunch(link[index])) {
                          await launch(link[index]);
                        } else {
                          print('Could not launch ${link[index]}');
                        }
                      },
                      child: Text(
                        'Video $videoNumber',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _downloadFile(widget.fileName, _isAuthorized);
                },
                child: _downloading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Unduh Modul'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
