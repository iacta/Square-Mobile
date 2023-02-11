import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../modules/functions/configapp.dart';
import '../modules/views/homescreen.dart';

var totalapps = 0;
var load = false;
bool on = false;
bool pop = false;
var imageUrl = '';
var text1 = '';
var info = [];
var network = {};
var vs = false;
var name = '';
String msgreturn = '';
String? id = '';
var nameapp = '';
var statuscode = 0;
int opt = 0;
bool vsp = false;

class Apps extends StatefulWidget {
  const Apps({super.key});

  @override
  State<Apps> createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: load == false ? true : false,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Center(
              child: Text(
            'Selecione uma Opção',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                    onPressed: () {
                      _dialogBuilder(context, 1);
                    },
                    style: ButtonStyle(padding:
                        MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
                            (Set<MaterialState> states) {
                      return const EdgeInsets.all(30);
                    }), backgroundColor:
                        MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                      return const Color.fromARGB(255, 29, 204, 248);
                    })),
                    child: const Text(
                      'Gerenciar um App',
                      style: TextStyle(color: Colors.white),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const _FilePickerUpload(),
                          ));
                    },
                    style: ButtonStyle(padding:
                        MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
                            (Set<MaterialState> states) {
                      return const EdgeInsets.all(30);
                    }), backgroundColor:
                        MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                      return const Color.fromARGB(255, 29, 204, 248);
                    })),
                    child: const Text(
                      'Realizar um Upload',
                      style: TextStyle(color: Colors.white),
                    )),
              ]),
              TextButton(
                  onPressed: () {
                    _dialogBuilder(context, 2);
                  },
                  style: ButtonStyle(padding:
                      MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
                          (Set<MaterialState> states) {
                    return const EdgeInsets.all(30);
                  }), backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                    return const Color.fromARGB(255, 29, 204, 248);
                  })),
                  child: const Text(
                    'Realizar um Commit',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          )
        ]));
  }

  Future<void> _dialogBuilder(BuildContext context, int option) {
    String dropdownValue = app.first;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(nameapp),
          content: DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) async {
              setState(() async {
                dropdownValue = value!;
                nameapp = dropdownValue;
                if (dropdownValue != app.first) {
                  if (option == 1) {
                    name = nameapp;
                    print(imageUrl);
                    text1 = '$nameapp(${infoapp[nameapp]})';
                    id = infoapp[nameapp];
                    imageUrl = avatar[id];
                    print(avatar[id]);
                    var ctx = context;
                    Navigator.pop(context);

                    Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (context) => const _ShowOptionsApps(),
                        ));
                    //set loading to false
                  } else {
                    id = infoapp[nameapp];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _FilePickerCommit(),
                        ));
                  }
                }
              });
            },
            items: app.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _FilePickerCommit extends StatefulWidget {
  const _FilePickerCommit();
  @override
  State<_FilePickerCommit> createState() => _FilePickerCommitState();
}

class _FilePickerCommitState extends State<_FilePickerCommit> {
  FilePickerResult? result;
  String dropdownValue = nameapp;
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) async {
              setState(() {
                dropdownValue = value!;
                nameapp = dropdownValue;
                id = infoapp[nameapp];
                if (dropdownValue == app[0]) {
                  vs = false;
                  vsp = false;
                }
              });
            },
            items: app.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Center(
            child: Column(children: [
              ElevatedButton(
                onPressed: () async {
                  result = await FilePicker.platform.pickFiles(
                      type: FileType.custom, allowedExtensions: ['zip']);
                  if (result == null) {
                    print("No file selected");
                  } else {
                    String? path = result?.files.first.path;
                    commit(id, path!, context, _isSelected);
                    if (pop == true) {
                      Navigator.pop(context);
                      pop = false;
                    }
                  }
                },
                child: const Text("Selecione o arquivo para dar commit"),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Checkbox(
                  value: _isSelected,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    setState(() {
                      _isSelected = value!;
                    });
                  },
                ),
                const Text('Auto restart')
              ])
            ]),
          ),
        ]));
  }
}

class _FilePickerUpload extends StatefulWidget {
  const _FilePickerUpload();
  @override
  State<_FilePickerUpload> createState() => _FilePickerUploadState();
}

class _FilePickerUploadState extends State<_FilePickerUpload> {
  FilePickerResult? result;
  String dropdownValue = nameapp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['zip']);
                if (result == null) {
                  print("No file selected");
                } else {
                  String? path = result?.files.first.path;
                  String? name = result?.files.first.name;
                  upload(path!, context);
                  if (pop == true) {
                    Navigator.pop(context);
                    pop = false;
                  }
                }
              },
              child: const Text("Selecione o arquivo para dar upload"),
            ),
          ),
        ]));
  }
}

class _ShowOptionsApps extends StatefulWidget {
  const _ShowOptionsApps();

  @override
  State<_ShowOptionsApps> createState() => __ShowOptionsAppsState();
}

class __ShowOptionsAppsState extends State<_ShowOptionsApps> {
  late Timer timer;
  String dropdownValue = nameapp;
  late Future<dynamic> _future;
  @override
  void initState() {
    super.initState();
    _future = statusApp(infoapp[nameapp], context);
    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      setState(() {
        statusApp(infoapp[nameapp], context);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
        body: Column(children: [
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255)),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? value) async {
                          setState(() {
                            dropdownValue = value!;
                            nameapp = dropdownValue;
                            _future;
                          });
                        },
                        items:
                            app.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      Container(
                          margin: const EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.width * 0.90,
                          height: MediaQuery.of(context).size.height * 0.30,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 22, 20, 48),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(2),
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(children: [
                            Container(
                              width: 90,
                              height: 90,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: const AlignmentDirectional(0, -1),
                              child: Text(
                                text1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                // default text style
                                children: <TextSpan>[
                                  const TextSpan(
                                      text: 'Status(',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: on ? 'Em Execução' : 'Desligado',
                                      style: TextStyle(
                                          color: on
                                              ? Colors.lightGreen
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(
                                      text: ')',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Uso da CPU: ${info[0]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.data_usage,
                                  color: Colors.deepPurpleAccent,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Uso da ram: ${info[1]}',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.device_hub_sharp,
                                  color: Color(0xFF00FC4D),
                                  size: 22,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Storage: ${info[2]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.storage_sharp,
                                  color: Color(0xFFFA0B0B),
                                  size: 22,
                                ),
                                const SizedBox(width: 25),
                                Text(
                                  'Total de requests: ${info[3]}',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.wifi_protected_setup_rounded,
                                  color: Color(0xFF02FFF7),
                                  size: 23,
                                ),
                              ],
                            ),

                            /* Row(children: const [
                Text(
                  'Total: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ]),
              const Text(
                'Now: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Network: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Icon(
                Icons.wifi,
                color: Color(0xFFF1E20B),
                size: 40,
              )
            ]) */
                          ]))
                    ]);
              } else if (snapshot.hasError) {
                return Text("Erro: ${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                width: 350,
                child: ElevatedButton.icon(
                    onPressed: () {
                      start(id, context);
                      print(statuscode);
                    },
                    label: Text(
                        on ? 'Desligar sua Aplicação' : 'Ligar sua Aplicação',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    icon: const Icon(
                      Icons.power,
                      size: 15,
                    ),
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ))),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (on == true) {
                            return Colors.redAccent;
                          } else {
                            return const Color(0xFF24BC42);
                          }
                        })))),
            SizedBox(
                width: 350,
                child: ElevatedButton.icon(
                    onPressed: () {
                      restart(id, context);
                    },
                    label: const Text('Reiniciar sua Aplicação',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    icon: const Icon(
                      Icons.wifi_protected_setup_rounded,
                      size: 15,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                        return Colors.deepPurpleAccent;
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ))),
                    ))),
            SizedBox(
                width: 350,
                child: ElevatedButton.icon(
                    onPressed: () {
                      if (statuscode == 200) {
                        delete(id, context);
                        vs = false;
                        app.clear();
                        app.add('Gerenciar um App');
                      }
                    },
                    label: const Text('Deletar sua Aplicação'),
                    icon: const Icon(
                      Icons.restore_from_trash,
                      size: 15,
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          return const Color(0xFFFA0B0B);
                        }),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ))))),
            SizedBox(
                width: 350,
                child: ElevatedButton.icon(
                  onPressed: () {
                    backup(id, context);
                  },
                  label: const Text('Realizar um backup da sua Aplicação'),
                  icon: const Icon(
                    Icons.backup_outlined,
                    size: 15,
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return const Color(0xBE02FFF7);
                    }),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    )),
                  ),
                )),
            SizedBox(
                width: 350,
                child: ElevatedButton.icon(
                    onPressed: () {
                      logsdialog(context);
                    },
                    label: const Text('Consulte os logs da sua Aplicação'),
                    icon: const Icon(
                      Icons.receipt_long,
                      size: 15,
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          return const Color(0xFFCAA009);
                        }),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ))))),
          ])
        ]));
  }

  Future<void> logsdialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sistema de logs',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Wrap(
            children: [
              Padding(
                  padding: const EdgeInsets.all(1),
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await logs(id);
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogsPage(),
                            ));
                      },
                      icon: const Icon(Icons.terminal_outlined),
                      label: const Text(
                          'Colete as últimas logs da sua aplicação'))),
              Padding(
                  padding: const EdgeInsets.all(1),
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await full_logs(id);
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogsPage2(),
                            ));
                      },
                      icon: const Icon(Icons.terminal_sharp),
                      label: const Text(
                          'Colete o terminal de ID único da sua aplicação')))
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

var logsmsg = '';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
        body: Column(children: [
          SizedBox(
              height: 500,
              child: Container(
                  color: const Color.fromARGB(176, 59, 56, 56),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: const Color.fromARGB(111, 0, 0, 0),
                        child: Text(
                          logsmsg,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      )
                    ],
                  )))
        ]));
  }
}

class LogsPage2 extends StatelessWidget {
  const LogsPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(logsmsg),
                  icon: const Icon(Icons.account_tree_sharp),
                  label: const Text('Clique aqui para acessar seu terminal')))
        ]));
  }
}

Future<void> _launchUrl(String url) async {
  final Uri urlparse = Uri.parse(url);
  if (!await launchUrl(urlparse)) {
    throw 'Could not launch $url';
  }
}
