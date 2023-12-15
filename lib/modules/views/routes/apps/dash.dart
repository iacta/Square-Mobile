// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api, unused_import, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/functions/apps.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

import 'edit/edit.dart';
import '../main_page/myapps.dart';

class SheetConfigApps extends StatefulWidget {
  final String? appid; // Adicione o parâmetro 'id'

  const SheetConfigApps({Key? key, required this.appid}) : super(key: key);

  @override
  State<SheetConfigApps> createState() => _SheetConfigAppsState();
}

class _SheetConfigAppsState extends State<SheetConfigApps> {
  var filter = 'Console';
  bool isExpanded = false;
  late Timer timer;
  String dropdownValue = text1;
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    statusApp(widget.appid, context);
    _future = Future.value(null);
    _fetchStatusApp();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
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
      print(e);
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Erro: ${snapshot.error}");
                    } else {
                      if (app.isNotEmpty) {
                        return SizedBox(
                          height: 200,
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text(text1),
                                subtitle: Text(widget.appid!),
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
                    }
                  }),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterButton(
                      text: 'Console',
                      activeFilter: filter,
                      onPressed: () {
                        setState(() {
                          filter = 'Console';
                          console(appid: widget.appid, context: context);
                        });
                      },
                    ),
                    FilterButton(
                      text: 'File Manager',
                      activeFilter: filter,
                      onPressed: () {
                        setState(() {
                          filter = 'File Manager';
                        });
                      },
                    ),
                    FilterButton(
                      text: 'Settings',
                      activeFilter: filter,
                      onPressed: () {
                        setState(() {
                          filter = 'Settings';
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                    height: 500, // Defina a altura desejada
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          if (filter == 'Console') {
                            return console(
                                appid: widget.appid, context: context);
                          } else if (filter == 'File Manager') {
                            return Filles(appid: widget.appid);
                          } else if (filter == 'Settings') {
                            return settings(
                                appid: widget.appid, context: context);
                          }
                          return null;
                        }))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget console({
  required String? appid,
  required BuildContext context,
}) {
  return Column(children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildButton(
            onPressed: () {
              start(appid, context);
            },
            icon: Icons.play_arrow_rounded,
            iconColor: on ? Colors.red : Colors.greenAccent),
        buildButton(
            onPressed: () {
              restart(appid, context);
            },
            icon: Icons.replay_outlined,
            iconColor: const Color.fromARGB(255, 70, 113, 252)),
      ],
    ),
    Container(
        color: inputBackgroundColor.withOpacity(0.9),
        width: 400,
        height: 400,
        child: Wrap(
          children: [
            Padding(
                padding: const EdgeInsets.all(1),
                child: Column(children: [
                  Text.rich(
                    TextSpan(
                      // default text style
                      children: <TextSpan>[
                        const TextSpan(
                            text: '[Square Cloud Console]: ',
                            style: TextStyle(
                                color: Color.fromARGB(255, 209, 209, 27),
                                fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: 'Welcome to console!\n',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: logsmsg,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ]))
          ],
        ))
  ]);
}

Widget settings({
  required String? appid,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(border: Border.all(color: Colors.red)),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deletar aplicação',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        const Text(
          'Sua aplicação será deletada permanentemente, recomendamos fazer um backup antes. Esta ação é irreversível!',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
        ),
        const Divider(
          endIndent: 9,
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
          onPressed: () => delete(appid, context),
          child: const Text(
            'Deletar aplicação',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    ),
  );
}

Widget buildButton({
  required VoidCallback onPressed,
  required IconData icon,
  Color? iconColor, // Adicione a opção de definir a cor do ícone
}) {
  return Container(
    margin: const EdgeInsets.all(10),
    width: 180,
    height: 100,
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
        ],
      ),
    ),
  );
}

class Filles extends StatefulWidget {
  String? appid;
  Filles({super.key, this.appid});

  @override
  State<Filles> createState() => _FillesState();
}

class _FillesState extends State<Filles> {
  late final Future<void> filesFuture;
  @override
  void initState() {
    super.initState();
    filesFuture = files(widget.appid, '.%2F');
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      Container(
          margin: const EdgeInsets.all(4),
          width: 300,
          height: 50,
          child: ElevatedButton(
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
                  return bottons;
                  // Cor padrão do botão azul
                })),
            onPressed: () => backup(widget.appid, context),
            child: const Text(
              'Cópia de segurança',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Container(
          margin: const EdgeInsets.all(4),
          width: 300,
          height: 50,
          child: ElevatedButton(
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
                  return bottons;
                  // Cor padrão do botão azul
                })),
            onPressed: () => Navigator.pushNamed(context, '/commit',
                arguments: {'id': widget.appid}),
            child: const Text(
              'Realizar um commit',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Container(
          margin: const EdgeInsets.all(4),
          width: 300,
          height: 50,
          child: ElevatedButton(
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
                  return bottons;
                  // Cor padrão do botão azul
                })),
            onPressed: () => backup(widget.appid, context),
            child: const Text(
              'Criar arquivo',
              style: TextStyle(color: Colors.white),
            ),
          )),
      const SizedBox(
        height: 5,
      ),
      Visibility(
          visible: vs,
          child: GestureDetector(
              onTap: () async {
                await files(widget.appid, '.%2F');
                setState(() {
                  filesFuture;
                  vs = false;
                });
              },
              child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: Container(
                      color: const Color(0xFF12171F),
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              title: Row(
                            children: [
                              Icon(Icons.drive_folder_upload),
                              SizedBox(width: 8),
                              Text('..'),
                            ],
                          ))))))),
      FutureBuilder(
        future: filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final List<Map<String, dynamic>> directories = [];
            final List<Map<String, dynamic>> filesList = [];
            if (file != null) {
              for (final item in file) {
                if (item['type'] == 'directory') {
                  directories.add(item);
                } else {
                  filesList.add(item);
                }
              }
            }

            // Ordene ambas as listas
            directories.sort((a, b) => a['name'].compareTo(b['name']));
            filesList.sort((a, b) => a['name'].compareTo(b['name']));

            // Combine as listas ordenadas
            final List<Map<String, dynamic>> sortedList = [
              ...directories,
              ...filesList
            ];
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedList.length,
              itemBuilder: (context, index) {
                return Column(children: [
                  GestureDetector(
                    onTap: () async {
                      if (sortedList[index]['type'] == 'directory') {
                        await files(
                            widget.appid, '.%2F/${sortedList[index]['name']}');
                        setState(() {
                          vs = true;
                          filesFuture;
                        });
                      } else {
                        await file_read(
                            widget.appid, sortedList[index]['name']);
                        List<int> bytes = fileread.cast<int>();
                        String decodedString = utf8.decode(bytes);

                        Navigator.of(context).pushNamed('/edit', arguments: {
                          'source': decodedString,
                          'lang': sortedList[index]['name'],
                          'appid': widget.appid,
                          'path': '.%2F/${sortedList[index]['name']}',
                        });
                      }
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(8),
                      child: Container(
                        color: const Color(0xFF12171F),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Icon(
                                  sortedList[index]['type'] == 'directory'
                                      ? Icons.folder
                                      : sortedList[index]['type'] == 'file'
                                          ? Icons.file_open
                                          : sortedList[index]['name']
                                                  .toString()
                                                  .contains('package')
                                              ? Icons.token
                                              : null, 
                                ),
                                const SizedBox(width: 8),
                                Text(sortedList[index]['name']),
                              ],
                            ),
                            subtitle: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: inputBackgroundColor,
                                        border: Border.all(
                                          color: fieldBackgroundColor,
                                          width: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Text(sortedList[index]['type']),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: inputBackgroundColor,
                                        border: Border.all(
                                          color: inputBackgroundColor,
                                          width: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                          '${sortedList[index]['size'].toString()}KB'),
                                    ),
                                    /*Container(
                                        width: 15,
                                        height: 15,
                                        margin: EdgeInsets.only(
                                          bottom: 10.0,
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () async {
                                            await file_delete(widget.appid,
                                                ".%2F/${sortedList[index]['name']}");
                                            setState(() {
                                              filesFuture;
                                            });
                                          },
                                        ))*/
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]);
              },
            );
          }
        },
      ),
      const SizedBox(
        height: 300,
      )
    ]);
  }
}