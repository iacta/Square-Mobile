// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/functions/apps.dart';
import 'package:square/modules/views/routes/main_page/apps/edit/files.dart';
import 'package:square/modules/views/routes/main_page/homescreen.dart';

import 'myapps.dart';

var id2;

class SheetConfigApps extends StatefulWidget {
  final String? id; // Adicione o parâmetro 'id'

  const SheetConfigApps({Key? key, required this.id}) : super(key: key);

  @override
  State<SheetConfigApps> createState() => _SheetConfigAppsState();
}

class _SheetConfigAppsState extends State<SheetConfigApps> {
  bool isExpanded = false;
  late Timer timer;
  String dropdownValue = text1;
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    statusApp(infoapp[text1], context);
    _future = Future.value(null); // Inicialize com um valor padrão
    _fetchStatusApp();
    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchStatusApp();
    });
  }

  Future<void> _fetchStatusApp() async {
    try {
      final result = await statusApp(infoapp[text1], context);

      setState(() {
        _future = Future.value(result);
      });
    } catch (e) {
      // Lide com erros, exiba uma mensagem de erro, etc.
    }
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
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset('assets/images/logo.webp',
            height: 80, fit: BoxFit.cover),
        backgroundColor: const Color.fromARGB(255, 15, 23, 42),
      ),
      backgroundColor: const Color.fromARGB(255, 11, 14, 19),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(imageUrl),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Status(',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    TextSpan(
                      text: on ? 'Em Execução' : 'Desligado',
                      style: TextStyle(
                        color: on ? Colors.lightGreen : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const TextSpan(
                      text: ')',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return const Color.fromARGB(
                      255, 35, 49, 97); // Cor padrão do botão azul
                },
              )),
              onPressed: () async {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'Ocultar Informações' : 'Mostrar Informações',
              ),
            ),
            if (isExpanded)
              FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    // Verifique se o widget ainda está montado
                    // Retorna um widget vazio se não estiver montado
                    if (!mounted) return Container();
                    if (snapshot.hasData) {
                      if (app.isNotEmpty) {
                        return SizedBox(
                          height: 200,
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text(text1),
                                subtitle: Text(widget.id!),
                              ),
                              ListTile(
                                title: Text('${info[0]}'),
                                subtitle: const Text('Uso da CPU'),
                              ),
                              ListTile(
                                title: Text('${info[1]}'),
                                subtitle: const Text('Uso da Ram'),
                              ),
                              ListTile(
                                title: Text('${info[2]}'),
                                subtitle: const Text('Storage'),
                              ),
                              ListTile(
                                title: Text('${info[3]}'),
                                subtitle: const Text("Total de Request's"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Text("Lista 'app' está vazia.");
                      }
                    } else if (snapshot.hasError) {
                      return Text("Erro: ${snapshot.error}");
                    }
                    return const CircularProgressIndicator();
                  }),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                        label: on
                            ? 'Desligar sua Aplicação'
                            : 'Ligar sua Aplicação',
                        onPressed: () {
                          start(widget.id, context);
                        },
                        icon: Icons.power,
                        iconColor: on ? Colors.red : Colors.greenAccent),
                    buildButton(
                        label: 'Reiniciar sua Aplicação',
                        onPressed: () {
                          restart(widget.id, context);
                        },
                        icon: Icons.wifi_protected_setup_rounded,
                        iconColor: const Color.fromARGB(255, 229, 255, 0)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                        label: 'Deletar sua Aplicação',
                        onPressed: () async {
                          delete(widget.id, context);
                        },
                        icon: Icons.restore_from_trash,
                        iconColor: Colors.red),
                    buildButton(
                        label: 'Realizar um commit em sua aplicação',
                        onPressed: () {
                          setState(() {
                            id2 = widget.id;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const _FilePickerCommit(),
                            ),
                          );
                        },
                        icon: Icons.settings_backup_restore_outlined,
                        iconColor: const Color.fromARGB(255, 1, 226, 58)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButton(
                        label: 'Realizar um backup da sua Aplicação',
                        onPressed: () {
                          backup(widget.id, context);
                        },
                        icon: Icons.backup_outlined,
                        iconColor: Colors.lightBlue),
                    buildButton(
                        label: 'Consulte os logs da sua Aplicação',
                        onPressed: () async {
                          if (logsmsg.isNotEmpty) {
                            await Future.delayed(const Duration(seconds: 5),
                                () async {
                              logs(widget.id);
                            });
                            logsdialog(context);
                          } else {
                            await logs(widget.id);
                            logsdialog(context);
                          }
                        },
                        icon: Icons.receipt_long,
                        iconColor: const Color.fromARGB(255, 185, 116, 25)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButton(
                        label: 'Editar seus arquivos',
                        onPressed: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Files(
                                        id: widget.id,
                                      )),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        icon: Icons.edit,
                        iconColor: Colors.orange),
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

Future<void> logsdialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: inputBackgroundColor.withOpacity(0.9),
        title: const Text(
          'Logs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Wrap(
          children: [
            Padding(padding: const EdgeInsets.all(1), child: Text(logsmsg))
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Container(
                color: const Color.fromARGB(255, 130, 163, 255),
                child: const Text('ok')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget buildButton({
  required String label,
  required VoidCallback onPressed,
  required IconData icon,
  Color? iconColor, // Adicione a opção de definir a cor do ícone
}) {
  return Container(
    margin: const EdgeInsets.all(10),
    width: 175,
    height: 175,
    child: ElevatedButton(
      onPressed: onPressed,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: iconColor ??
                Colors.white, // Cor do ícone definida ou branca por padrão
          ),
          const SizedBox(height: 10), // Espaço entre o ícone e o texto
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

class _FilePickerCommit extends StatefulWidget {
  const _FilePickerCommit();
  @override
  State<_FilePickerCommit> createState() => _FilePickerCommitState();
}

class _FilePickerCommitState extends State<_FilePickerCommit> {
  FilePickerResult? result;
  String dropdownValue = text1;
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
                  text1 = dropdownValue;
                  id2 = infoapp[text1];
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
                        commit(id2, path!, context, _isSelected);
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

/*
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
    _future = Future.value(null); // Inicialize com um valor padrão
    _fetchStatusApp();
    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchStatusApp();
    });
  }

  Future<void> _fetchStatusApp() async {
    try {
      final result = await statusApp(infoapp[nameapp], context);
      setState(() {
        _future = Future.value(result);
      });
    } catch (e) {
      // Lide com erros, exiba uma mensagem de erro, etc.
      print("Erro: $e");
    }
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
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: Column(children: [
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (app.isNotEmpty) {
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
                              _fetchStatusApp();
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
                                    'Uso da CPU: //vem aq',
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
                } else {
                  // Trate o caso de lista 'app' vazia.
                  return Text("Lista 'app' está vazia.");
                }
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
                      start(widget.id, context);
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
                      restart(widget.id, context);
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
                    onPressed: () async {
                      if (statuscode == 200) {
                        await delete(widget.id, context);
                        vs = false;
                        app.clear();
                        app.add('Gerenciar um App');
                        update(context);
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
                    backup(widget.id, context);
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

  
*/
