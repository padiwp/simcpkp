import 'package:app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isPreTestCompleted = false;
  bool isCourseCompleted = false;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late CollectionReference nurseModuleCollection;
  late CollectionReference supervisorModuleCollection;
  List<String> fileList = [];
  Map<String, Map<String, String>> fileDetails = {};

  @override
  void initState() {
    super.initState();
    storage = FirebaseStorage.instance;
    requestStoragePermission();
    nurseModuleCollection =
        FirebaseFirestore.instance.collection('modul_perawat');
    supervisorModuleCollection =
        FirebaseFirestore.instance.collection('modul_spv');
    fetchFileList();
  }

  void requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> fetchFileDetails() async {
    for (String fileName in fileList) {
      try {
        Reference ref = storage.ref().child('modul_perawat').child(fileName);
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

  Future<void> fetchFileList() async {
    try {
      ListResult result = await storage.ref().child('modul_perawat').listAll();
      setState(() {
        fileList = result.items.map((item) => item.name).toList();
      });
      await fetchFileDetails();
    } catch (e) {
      print('Error fetching file list: $e');
    }
  }

  Future<void> pickAndUploadFile(bool isNurseModule) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      try {
        await putFile(file, isNurseModule);
        fetchFileList();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> putFile(PlatformFile file, bool isNurseModule) async {
    try {
      if (file.bytes != null) {
        Reference ref = isNurseModule
            ? storage.ref().child('modul_perawat').child(file.name)
            : storage.ref().child('modul_spv').child(file.name);
        await ref.putData(file.bytes!);
        print('File uploaded successfully');

        await addFileToFirestore(file.name, isNurseModule);
      } else {
        print('Error uploading file: File bytes are null');
      }
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> addFileToFirestore(String fileName, bool isNurseModule) async {
    try {
      CollectionReference moduleCollection =
          isNurseModule ? nurseModuleCollection : supervisorModuleCollection;

      await moduleCollection.add({
        'name': fileName,
        'link': [],
        'description': '',
      });

      print('File data added to Firestore successfully');
    } catch (e) {
      print('Error adding file data to Firestore: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                onPressed: () => pickAndUploadFile(true), // Perawat Module
                child: const Text('Unggah Modul Perawat'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                onPressed: () => pickAndUploadFile(false), // Penyelia Module
                child: const Text('Unggah Modul Penyelia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
