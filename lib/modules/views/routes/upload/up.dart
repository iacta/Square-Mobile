import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Commit extends StatefulWidget {
  final String? id;
  const Commit({super.key, required this.id});

  @override
  State<Commit> createState() => CommitState();
}

class CommitState extends State<Commit> {
  FilePickerResult? result;
  bool _isSelected = false;
  String? path;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(translate(context.locale.toString(), 'commit', 'cancel')),
        ),
      ],
      backgroundColor: Colors.black,
      title: Text(
          translate(context.locale.toString(), 'commit', 'createCommit')),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['zip'],
                          );
                          if (result != null) {
                            path = result?.files.first.path;
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        child: Container(
                            color: Colors.black,
                            child: CustomPaint(
                              painter: DottedBorderPainter(),
                              child: SizedBox(
                                width: 300,
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      PhosphorIconsBold.fileArrowUp,
                                      size: 40,
                                    ),
                                    Text(
                                      translate(context.locale.toString(),
                                          'commit', 'selectZipFile'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      '(max 100MB)',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              translate(context.locale.toString(), 'commit',
                                  'allCommitsGoToRoot'),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: _isSelected,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isSelected = value;
                                    });
                                  },
                                ),
                                const Spacer(),
                                Text(translate(context.locale.toString(),
                                    'commit', 'autoRestart')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return const Color.fromARGB(255, 30, 156, 35);
                              },
                            ),
                          ),
                          onPressed: () {
                            commit(widget.id, path!, context, _isSelected);
                            Navigator.pop(context);
                          },
                          child: Text(
                            translate(
                                context.locale.toString(), 'commit', 'submit'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class FilePickerUpload extends StatefulWidget {
  const FilePickerUpload({super.key});
  @override
  State<FilePickerUpload> createState() => FilePickerUploadState();
}

class FilePickerUploadState extends State<FilePickerUpload> {
  FilePickerResult? result;
  var s = false;
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.youtube.com/embed/_zjpDjFj6dI'));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Container(
              width: 350,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 152, 19).withOpacity(0.2),
                border: Border.all(
                  color: const Color.fromARGB(255, 241, 241, 76),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  translate(
                      context.locale.toString(), 'upload', 'ensureConfigFile'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: () async {
                result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['zip'],
                );
                if (result == null) {
                } else {
                  String? path = result?.files.first.path;
                  var up = await upload(path!, context);
                  if (up == true) {
                    setState(() {});
                  }
                }
              },
              child: CustomPaint(
                painter: DottedBorderPainter(),
                child: SizedBox(
                  width: 300,
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        PhosphorIconsBold.fileArrowUp,
                        size: 40,
                      ),
                      Text(
                        translate(context.locale.toString(), 'upload',
                            'selectZipFile'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '(max 100MB)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translate(
                        context.locale.toString(), 'upload', 'submittingTerms'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    translate(context.locale.toString(), 'upload',
                        'howToSendApplication'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    translate(
                        context.locale.toString(), 'upload', 'exampleVideo'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(bgBlue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => _launchUrl(
                        'https://www.youtube.com/watch?v=_zjpDjFj6dI'),
                    child: Text(
                      translate(context.locale.toString(), 'upload', 'video'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /*  SizedBox(
                    width: 575,
                    height: 324,
                    child: Center(child: WebViewWidget(controller: controller)),
                  ), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String s) async {
  if (!await launchUrl(Uri.parse(s))) {
    throw 'Could not launch $s';
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 92, 91, 91) // Cor dos pontos
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    double dashWidth = 5.0;
    double dashSpace = 5.0;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    double endY = 0;
    while (endY < size.height) {
      canvas.drawLine(
        Offset(size.width, endY),
        Offset(size.width, endY + dashWidth),
        paint,
      );
      endY += dashWidth + dashSpace;
    }

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    double endX = 0;
    while (endX < size.width) {
      canvas.drawLine(
        Offset(endX, size.height),
        Offset(endX + dashWidth, size.height),
        paint,
      );
      endX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class DialogMsg extends StatefulWidget {
  final dynamic text;
  const DialogMsg({super.key, this.text});

  @override
  State<DialogMsg> createState() => _DialogMsgState();
}

class _DialogMsgState extends State<DialogMsg> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Center(
        child: Icon(
          PhosphorIconsRegular.x,
          color: Colors.redAccent,
          size: 50,
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  translate(context.locale.toString(), 'uploadMessages',
                      'error_message'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.text,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: const MaterialStatePropertyAll(
                          Color.fromARGB(255, 255, 17, 0))),
                  onPressed: () => Navigator.pop,
                  child: Text(
                      translate(context.locale.toString(), 'uploadMessages',
                          'try_again'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)))
            ],
          ),
        ),
      ),
    );
  }
}
