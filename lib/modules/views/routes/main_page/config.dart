// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';

var statuscode = 0, msgreturn = '';
List<String> list = <String>['Recomendada', 'Última'];

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> with TickerProviderStateMixin {
  final control = TextEditingController();
  bool vs = false;
  @override
  void dispose() {
    super.dispose();
    control.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
              onPressed: () {
                _dialog1(context);
              },
              icon: const Icon(Icons.settings),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return bottons; // Cor padrão do botão azul
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
              label: const Text('Trocar sua APIKey')),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SquareConfig(),
                    ));
              },
              icon: const Icon(Icons.data_array_outlined),
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
              label: const Text('Gerar seu arquivo de configuração')),
        ]),
      ],
    );
  }

  var apis = ['1padpasdk', 'akdoskadokd'];

  Future<void> _dialog1(BuildContext context) {
// Initialize with an invalid index

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: inputBackgroundColor.withOpacity(0.8),
          title: const Text('Insira sua nova Chave'),
          content: Container(
            width: double.maxFinite,
            height: 300, // Defina a altura desejada
            child: ListView.builder(
              itemCount: apis.length, // Número de itens na lista
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: Container(
                    height: 155,
                    color: const Color(0xFF12171F),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Conta"),
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
                                      child: Text(apis[index]),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    left:
                                        MediaQuery.of(context).size.width * 0.2,
                                  ),
                                  child: Row(children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.delete_forever))
                                  ]),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o AlertDialog
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

var text = '';
updateKey(String? k) async {
  Map<String, String> data = {'id': '', 'name': '', 'key': ''};
  final prefs = await SharedPreferences.getInstance();
  final response = await http.get(
    Uri.parse('https://api.squarecloud.app/v2/user'),
    headers: <String, String>{
      'Authorization': k!,
    },
  );
  var statusCode = response.statusCode;
  if (statusCode == 401) {
    return 'Não autorizado. Verifique se sua chave de API está correta!\nVocê pode trocá-la em (Minha Conta/Trocar minha APIKey)';
  } else if (statusCode == 404) {
    return 'O usuário não existe!';
  } else if (statusCode == 200) {
    Map<String, dynamic> responseData = json.decode(response.body);
    var map = responseData["response"];
    data['id'] = map["user"]["id"];
    data['name'] = map["user"]["tag"];
    data['key'] = k;
    var apps = map["applications"];

    await prefs.setInt('id', int.parse(data['id']!));
    await prefs.setString('name', data['name']!);
    var id = {}, name = {};
    for (var i = 0; i < apps.length; i++) {
      id.addAll({i: apps[i]['id']});
      name.addAll({i: apps[i]['tag']});
    }
    List<String>? appIdList = id.values.cast<String>().toList();
    List<String>? appNameList = name.values.cast<String>().toList();
    await prefs.setStringList('app-id', appIdList);
    await prefs.setStringList('app-name', appNameList);
    await prefs.setString('key', k);
    return 'Dados atualizados com sucesso!';
  }
}

class SquareConfig extends StatefulWidget {
  const SquareConfig({super.key});

  @override
  State<SquareConfig> createState() => _SquareConfigState();
}

class _SquareConfigState extends State<SquareConfig> {
  String dropdownValue = list.first;
  bool vs = false;
  late Icon arrow = const Icon(Icons.arrow_downward_outlined);
  var text = 'Mostrar opções avançadas';
  final control = {
    'name': TextEditingController(),
    'main': TextEditingController(),
    'ram': TextEditingController(),
    'desc': TextEditingController(),
    'avatar': TextEditingController(),
    'version': TextEditingController(),
    'cmd': TextEditingController(),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: RawScrollbar(
            thumbColor: const Color.fromARGB(255, 53, 7, 255),
            radius: const Radius.circular(20),
            thickness: 10,
            child: SingleChildScrollView(
                child: Column(children: [
              const SizedBox(
                height: 60,
              ),
              const Text.rich(
                style: TextStyle(fontSize: 25),
                TextSpan(
                  // default text style
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Gere seu ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: 'arquivo ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.blueAccent)),
                    TextSpan(
                        text: 'de ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: 'configuração',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.redAccent)),
                  ],
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              TextFormField(
                controller: control['name'],
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 60, 9, 241),
                          width: 2), //<-- SEE HERE
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 60, 9, 241),
                          width: 2), //<-- SEE HERE
                    ),
                    label: const Text('Apelido'),
                    hintText: 'Tente Nevinha',
                    icon: const Icon(Icons.person)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: control['main'],
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
                    label: const Text('Arquivo Principal'),
                    hintText: 'Tente main.js',
                    icon: const Icon(Icons.developer_mode)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: control['ram'],
                keyboardType: TextInputType.number,
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
                    label: const Text('Total de ram'),
                    hintText: '100',
                    icon: const Icon(Icons.developer_board_outlined)),
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      vs = vs ? false : true;
                      arrow = vs
                          ? const Icon(Icons.arrow_upward_outlined)
                          : const Icon(Icons.arrow_downward_outlined);
                    });
                  },
                  child: Row(
                    children: [arrow, Text(text)],
                  )),
              Visibility(
                  visible: vs,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: control['desc'],
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
                            label: const Text('Descrição'),
                            hintText:
                                'Tente "Hospedado com ❤️ pela SquareCloud"',
                            icon: const Icon(Icons.text_fields)),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: control['avatar'],
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
                            label: const Text('Avatar'),
                            hintText: 'Insira um link para uma imagem.',
                            icon: const Icon(Icons.image)),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            icon: const Icon(Icons.webhook),
                            labelText: 'Versão',
                            labelStyle: const TextStyle(fontSize: 20),
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
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownValue = value!;
                            });
                          },
                          items: list
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: control['cmd'],
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
                            label: const Text('Comando para Iniciar'),
                            hintText: 'Tente "node ."',
                            icon: const Icon(Icons.terminal_outlined)),
                      ),
                    ],
                  )),
              const SizedBox(height: 30),
              SizedBox(
                  height: 40,
                  width: 250,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final ramController =
                          control['ram'] ?? TextEditingController(text: '100');
                      String str = '''
                        DISPLAY_NAME=${control["name"]!.text}
                        DESCRIPTION=${control["desc"]!.text}
                        MAIN=${control["main"]!.text}
                        MEMORY=${ramController.text}
                        VERSION=$dropdownValue
                        ''';
                      str += control['avatar'] != null
                          ? 'AVATAR=${control['avatar']!.text}\n'
                          : '';
                      str += control['cmd'] != null
                          ? 'START=${control['cmd']!.text}\n'
                          : '';
                      try {
                        Directory? directory;
                        if (defaultTargetPlatform == TargetPlatform.android) {
                          directory = await getExternalStorageDirectory();
                        } else if (defaultTargetPlatform ==
                            TargetPlatform.iOS) {
                          directory = await getDownloadsDirectory();
                        }
                        final File file =
                            File('${directory!.path}/squarecloud.config');
                        await file.writeAsString(str);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Seu arquivo foi gerado com sucesso!\nCaminho do arquivo: ${directory.path}',
                            style: const TextStyle(
                              color: Colors
                                  .white, /* fontWeight: FontWeight.bold */
                            ),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 62, 24, 151),
                        ));
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
                    },
                    icon: const Icon(Icons.app_shortcut_outlined),
                    label: const Text('Gerar'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          return bottons; // Cor padrão do botão azul
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
                  ))
            ]))));
  }
}
