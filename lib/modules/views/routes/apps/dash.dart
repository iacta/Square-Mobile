// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api, unused_import, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/api/messages.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:square/modules/views/routes/upload/up.dart';
import 'package:url_launcher/url_launcher.dart';

import 'deploy/deploy.dart';
import 'files/edit.dart';
import 'myapps.dart';
import 'files/files.dart';

var vs = false;

class SheetConfigApps extends StatefulWidget {
  final String? appid; // Adicione o parâmetro 'id'

  const SheetConfigApps({super.key, required this.appid});

  @override
  State<SheetConfigApps> createState() => _SheetConfigAppsState();
}

class _SheetConfigAppsState extends State<SheetConfigApps> {
  var filter = 'Project';
  bool isExpanded = false;
  late Timer timer;
  late Future<dynamic> _future;
  bool status = true;

  @override
  void initState() {
    super.initState();
    statusApp(widget.appid, context);
    _future = Future.value(null);
    _fetchStatusApp();
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _fetchStatusApp();
    });
  }

  Future<void> _fetchStatusApp() async {
    try {
      final result = await statusApp(widget.appid, context);
      await logs(widget.appid);
      setState(() {
        _future = Future.value(result);
      });
    } catch (e) {
      log(data['name'], 'fatal', '$e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    info = [];
    online = false;
    logsmsg = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.webp',
          height: 60,
          fit: BoxFit.cover,
        ),
        backgroundColor: const Color.fromARGB(255, 11, 15, 19),
        elevation: 1,
        actions: const [LanguageSwitcher()],
      ),
      floatingActionButton: help(),
      backgroundColor: const Color.fromARGB(255, 11, 14, 19),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(text1),
                          subtitle: Row(children: [
                            const Icon(PhosphorIconsBold.identificationCard),
                            const SizedBox(width: 5),
                            Text(widget.appid!)
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterButton(
                  text: 'Project',
                  activeFilter: filter,
                  onPressed: () {
                    setState(() {
                      filter = 'Project';
                      project(appid: widget.appid, context: context);
                      status = true;
                    });
                  },
                ),
                FilterButton(
                  text: 'File Manager',
                  activeFilter: filter,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Files(appid: widget.appid),
                      ),
                    );
                  },
                ),
                FilterButton(
                  text: 'Deploy',
                  activeFilter: filter,
                  onPressed: () {
                    setState(() {
                      filter = 'Deploy';
                      status = false;
                    });
                  },
                ),
                FilterButton(
                  text: 'Settings',
                  activeFilter: filter,
                  onPressed: () {
                    setState(() {
                      filter = 'Settings';
                      status = false;
                    });
                  },
                ),
              ],
            ),
            Visibility(
                visible: status,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          info.isEmpty) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Erro: ${snapshot.error}");
                      } else {
                        if (data['apps'].isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.all(9),
                                  child: Text(
                                    'Status',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                              buildInfoTile(online ? 'running' : 'offline',
                                  'appInfo', 'Uptime', PhosphorIconsBold.clock),
                              const SizedBox(height: 10),
                              buildInfoTile('${info[0]}', 'appInfo', 'cpuUsage',
                                  PhosphorIconsRegular.cpu),
                              const SizedBox(height: 10),
                              buildInfoTile('${info[1]}', 'appInfo', 'ramUsage',
                                  PhosphorIconsRegular.squareSplitVertical),
                              const SizedBox(height: 10),
                              buildInfoTile('${info[2]}', 'app', 'Storage',
                                  PhosphorIconsRegular.hardDrives),
                              const SizedBox(height: 10),
                              buildInfoTile('${info[3]}', 'app', "Request's",
                                  PhosphorIconsRegular.cellSignalFull),
                            ],
                          );
                        } else {
                          return const Text("Lista 'app' está vazia.");
                        }
                      }
                    },
                  ),
                )),
            Container(
              child: (() {
                if (filter == 'Project') {
                  return project(appid: widget.appid, context: context);
                } else if (filter == 'File Manager') {
                  return Files(appid: widget.appid);
                } else if (filter == 'Deploy') {
                  return Deploy(appid: widget.appid);
                } else if (filter == 'Settings') {
                  return settings(appid: widget.appid, context: context);
                } else {
                  return Container();
                }
              })(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInfoTile(
      String text, String category, String message, IconData icon) {
    if (message == "Storage" || message == "Request's") {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1,
              color: borderBlack700,
            ),
          ),
          child: ListTile(
            title: Row(
              children: [
                Text(text),
                const SizedBox(width: 5),
                Icon(icon),
              ],
            ),
            subtitle: Text(message),
          ));
    } else if (message == 'Uptime') {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 0.15,
              color: const Color.fromARGB(255, 70, 70, 70),
            ),
          ),
          child: ListTile(
            title: Row(
              children: [
                Text(translate(context.locale.toString(), category, text)),
                const SizedBox(width: 5),
                Icon(
                  icon,
                  color: online ? Colors.greenAccent : Colors.redAccent,
                ),
              ],
            ),
            subtitle: Text(message),
          ));
    } else {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 0.15,
              color: const Color.fromARGB(255, 70, 70, 70),
            ),
          ),
          child: ListTile(
            title: Row(
              children: [
                Text(text),
                const SizedBox(width: 5),
                Icon(icon),
              ],
            ),
            subtitle:
                Text(translate(context.locale.toString(), category, message)),
          ));
    }
  }
}

Widget project({
  required String? appid,
  required BuildContext context,
}) {
  return Column(
    children: [
      const Padding(
        padding: EdgeInsets.all(9),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Realtime Console',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
            color: bgBlack900,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 3,
              color: borderBlack700,
            )),
        child: Column(
          children: [
            Buttons(
              appid: appid,
            ),
            Container(
              width: 390,
              decoration: BoxDecoration(
                color: fieldBackgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '[Square Cloud Realtime] Connection established',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 10),
                  for (String logMessage in logsmsg.split('\n'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          logMessage,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  const SizedBox(
                    height: 120 * 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<void> input(BuildContext context, String? appid) {
  final control = TextEditingController();
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: inputBackgroundColor.withOpacity(0.8),
            title: Text(
                translate(context.locale.toString(), 'appInfo', 'fileCreate')),
            content: SizedBox(
              width: double.maxFinite,
              height: 300, // Defina a altura desejada
              child: TextFormField(
                  controller: control,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 60, 9, 241),
                            width: 2), //<-- SEE HERE
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 60, 9, 241),
                            width: 2), //<-- SEE HERE
                      ),
                      label: Text(translate(
                          context.locale.toString(), 'appInfo', 'fileInfo')),
                      icon: const Icon(Icons.developer_mode))),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  fileCreate(appid, '', context, control.text);
                  Navigator.pop(context);
                },
                child: const Text('Enviar'),
              )
            ]);
      });
}

Widget settings({
  required String? appid,
  required BuildContext context,
}) {
  return Container(
    width: 390,
    decoration: BoxDecoration(border: Border.all(color: Colors.red)),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate(context.locale.toString(), 'appInfo', 'delete'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          translate(context.locale.toString(), 'appInfo', 'deleteInfo'),
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
        ),
        const Divider(
          endIndent: 7,
        ),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                return const Color.fromARGB(255, 255, 17, 0);
              },
            ),
          ),
          onPressed: () async {
            delete(appid, context);
            filterManager.setFilter('All');
          },
          child: Text(
            translate(context.locale.toString(), 'appInfo', 'delete'),
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    ),
  );
}

class Buttons extends StatefulWidget {
  String? appid;

  Buttons({super.key, required this.appid});
  @override
  _ButtonsState createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  bool isStartButtonLoading = false;
  bool isRestartButtonLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildButton(
              onPressed: () async {
                setState(() {
                  isStartButtonLoading = true;
                  isRestartButtonLoading = false;
                });

                await start(widget.appid, context);

                setState(() {
                  isStartButtonLoading = false;
                });
              },
              isLoading: isStartButtonLoading,
              icon: online == true
                  ? PhosphorIconsLight.stop
                  : PhosphorIconsLight.play,
              iconColor: online == true
                  ? Colors.red
                  : const Color.fromARGB(255, 13, 219, 30),
              label: online == true ? 'Stop' : 'Start',
            ),
            buildButton(
              onPressed: () async {
                if (online == true) {
                  setState(() {
                    isRestartButtonLoading = true;
                    isStartButtonLoading = false;
                  });

                  await restart(widget.appid, context);

                  setState(() {
                    isRestartButtonLoading = false;
                  });
                } else {
                  return showSnack(
                      context, Messages.send(context, 'restartWarn'));
                }
              },
              icon: PhosphorIconsLight.arrowClockwise,
              iconColor: online == false
                  ? Colors.grey
                  : const Color.fromARGB(255, 70, 113, 252),
              isLoading: isRestartButtonLoading,
              label: 'Restart',
            ),
          ],
        ),
      ],
    );
  }

  Widget buildButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 180,
      height: 90,
      child: ElevatedButton.icon(
        label: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Colors.black;
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  width: 1,
                  color: borderBlack700,
                )),
          ),
        ),
        icon: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(iconColor!),
              )
            : Icon(
                icon,
                size: 30,
                color: iconColor ?? Colors.white,
              ),
      ),
    );
  }
}
