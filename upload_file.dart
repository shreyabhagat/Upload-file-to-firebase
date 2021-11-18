import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadFile extends StatefulWidget {
  const UploadFile({Key? key}) : super(key: key);

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  //
  File? file;
  UploadTask? uploadTask;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        //
        title: Text('Upload File'),

        //
        actions: [
          //
          IconButton(
            icon: Icon(Icons.attach_file_sharp),
            onPressed: () {
              //
              getFile();
            },
          ),
          file == null
              ? Container()
              : IconButton(
                  icon: Icon(Icons.upload_rounded),
                  onPressed: () {
                    //
                    uploadFile();
                  },
                ),
        ],
      ),
      body: file == null
          ? Center(child: Text('No file selected'))
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                //

                Text('${file!.path.split('/').last}'),
                SizedBox(height: 32),

                //
                uploadTask == null
                    ? Container()
                    : FileStatus(uploadTask: uploadTask!),
              ],
            ),
    );
  }

  Future<void> getFile() async {
    // get file
    FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (filePickerResult != null) {
      setState(() {
        file = File(filePickerResult.files.first.path!);
        uploadTask = null;
      });
    }
  }

  //
  Future<void> uploadFile() async {
    // get file extension
    String fileExtension = file!.path.split('.').last;

    // get unique file name
    String fileName =
        DateTime.now().microsecondsSinceEpoch.toString() + '.' + fileExtension;

    // get firebase storage reference
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;

    // create reference into firebase storage
    Reference reference = firebaseStorage.ref('files/$fileName');

    // upload file into firebase storage

    uploadTask = reference.putFile(file!);
    setState(() {
      //
    });
  }
}

class FileStatus extends StatelessWidget {
  final UploadTask uploadTask;

  FileStatus({required this.uploadTask});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //
      stream: uploadTask.snapshotEvents,
      //
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //
        if (!snapshot.hasData) {
          return Container();
        }

        // get snapshot data
        TaskSnapshot taskSnapshot = snapshot.data;

        // get total byte
        int totalbyte = taskSnapshot.totalBytes;

        // get byteTransferred
        int byteTransferred = taskSnapshot.bytesTransferred;
        double percentage = (byteTransferred / totalbyte);
        String percent = (percentage * 100).toStringAsFixed(0);
        int per = int.parse(percent);

        //
        return per != 100
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey.shade200,
                      value: percentage,
                    ),
                  ),
                  //
                  Center(
                    child: Text("$percent %"),
                  )
                ],
              )
            : Center(
                child: Text(
                  'File uploaded  Successfully',
                ),
              );
      },
    );
  }
}
