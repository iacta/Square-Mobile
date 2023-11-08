// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api, unused_import, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/functions/apps.dart';
import 'package:square/modules/views/routes/main_page/homescreen.dart';

import 'edit/edit.dart';
import 'myapps.dart';

class SheetConfigApps extends StatefulWidget {
  final String? id; // Adicione o parâmetro 'id'

  const SheetConfigApps({Key? key, required this.id}) : super(key: key);

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
    statusApp(widget.id, context);
    _future = Future.value(null); // Inicialize com um valor padrão
    _fetchStatusApp();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchStatusApp();
    });
  }

  Future<void> _fetchStatusApp() async {
    try {
      final result = await statusApp(widget.id, context);
      await logs(widget.id);
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
                          console(appid: widget.id, context: context);
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
                Container(
                    height: 500, // Defina a altura desejada
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          if (filter == 'Console') {
                            return console(appid: widget.id, context: context);
                          } else if (filter == 'File Manager') {
                            return filer(appid: widget.id);
                          } else if (filter == 'Settings') {
                            return settings(appid: widget.id, context: context);
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

class filer extends StatefulWidget {
  String? appid;
  filer({super.key, this.appid});

  @override
  State<filer> createState() => _filerState();
}

class _filerState extends State<filer> {
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _FilePickerCommit(id: widget.appid),
              ),
            ),
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
            print(file);
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

                        print(decodedString);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Editing(
                              source: decodedString,
                              lang: sortedList[index]['name'],
                              appid: widget.appid,
                              path: '.%2F/${sortedList[index]['name']}',
                            ),
                          ),
                        );
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
                                              : null, // Ícone nulo se nenhuma condição for atendida
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

class _FilePickerCommit extends StatefulWidget {
  _FilePickerCommit({required id});
  String? id;
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
                  widget.id = widget.id;
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
