import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/functions/apps.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

class Commit extends StatefulWidget {
  Commit({super.key, required id});
  String? id;
  @override
  State<Commit> createState() => CommitState();
}

class CommitState extends State<Commit> {
  FilePickerResult? result;
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          centerTitle: true,
          title: Image.asset('assets/images/logo.webp',
              height: 80, fit: BoxFit.cover),
          backgroundColor: const Color.fromARGB(255, 15, 23, 42),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['zip'],
                      );
                      if (result == null) {
                      } else {
                        String? path = result?.files.first.path;
                        commit(widget.id, path!, context, _isSelected);
                        if (pop == true) {
                          Navigator.pop(context);
                          pop = false;
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          return bottons;
                          // Cor padrão do botão azul
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    child: const Text("Selecione o arquivo para dar commit"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isSelected,
                        activeColor: const Color.fromARGB(255, 35, 49, 97),
                        onChanged: (value) {
                          setState(() {
                            _isSelected = value!;
                          });
                        },
                      ),
                      const Text('Auto restart'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class FilePickerUpload extends StatefulWidget {
  const FilePickerUpload({super.key});
  @override
  State<FilePickerUpload> createState() => FilePickerUploadState();
}

class FilePickerUploadState extends State<FilePickerUpload> {
  FilePickerResult? result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset('assets/images/logo.webp',
            height: 80, fit: BoxFit.cover),
        backgroundColor: const Color.fromARGB(255, 15, 23, 42),
      ),
      backgroundColor: const Color.fromARGB(255, 11, 14, 19),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['zip'],
                );
                if (result == null) {
                } else {
                  String? path = result?.files.first.path;
                  upload(path!, context);
                  if (pop == true) {
                    Navigator.pop(context);
                    pop = false;
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return bottons;
                    // Cor padrão do botão azul
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
              ),
              child: const Text("Selecione o arquivo para dar upload"),
            ),
          ),
        ],
      ),
    );
  }
}
