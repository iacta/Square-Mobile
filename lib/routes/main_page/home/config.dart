import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/views/homescreen.dart';

var statuscode = 0, msgreturn = '';
List<String> list = <String>['Recomendada', 'Última'];

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> with TickerProviderStateMixin {
  late AnimationController animationController;
  final control = TextEditingController();
  bool vs = false;
  @override
  void dispose() {
    animationController.dispose();
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
              label: const Text('Gerar seu arquivo de configuração')),
        ]),
      ],
    );
  }

  Future<void> _dialog1(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insira sua nova Chave'),
          content: TextFormField(
            controller: control,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 60, 9, 241),
                      width: 2), //<-- SEE HERE
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 60, 9, 241),
                      width: 2), //<-- SEE HERE
                ),
                icon: const Icon(Icons.key)),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
                var msg = '';
                updateKey(control.text);
                setState(() {
                  msg = text;
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.white, /* fontWeight: FontWeight.bold */
                    ),
                  ),
                  backgroundColor: const Color.fromARGB(255, 62, 24, 151),
                ));
              },
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
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v1/public/user'),
    headers: <String, String>{
      'Authorization': k!,
    },
  );
  var stats = get.statusCode;
  print(stats);
  //print(get.body);
  if (stats == 401) {
    return text =
        'Não Autorizado, Verifique se sua chave de API está correta!\nVocê pode troca-la em (Minha Conta/Trocar minha APIKey)';
  } else if (stats == 404) {
    return text = 'O usuário não existe!';
  } else if (stats == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    var map = req["response"];
    print("\n\n\n\nApps test$map['applications']");
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
    print(id);
    List<String>? list = id.values.cast<String>().toList();
    List<String>? list2 = name.values.cast<String>().toList();
    print(list);
    await prefs.setStringList('app-id', list);
    await prefs.setStringList('app-name', list2);
    await prefs.setString('key', k);
    print(prefs.getStringList('app-id'));
    print(apps.length);
    return text = 'Dados atualizados com sucesso!';
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
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
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
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 60, 9, 241),
                          width: 2), //<-- SEE HERE
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
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
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 60, 9, 241),
                          width: 2), //<-- SEE HERE
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
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
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 60, 9, 241),
                          width: 2), //<-- SEE HERE
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
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
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 60, 9, 241),
                                  width: 2), //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
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
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 60, 9, 241),
                                  width: 2), //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
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
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 60, 9, 241),
                                  width: 2), //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
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
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 60, 9, 241),
                                  width: 2), //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
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
                      String str =
                          'DISPLAY_NAME=${control["name"]!.text}\nDESCRIPTION=${control["desc"]!.text}\nMAIN=${control["main"]!.text}\nMEMORY=${control["ram"]!.text}\nVERSION=$dropdownValue';

                      try {
                        Directory? directory;
                        print(getExternalStorageDirectory);
                        if (defaultTargetPlatform == TargetPlatform.android) {
                          directory = await getExternalStorageDirectory();
                        } else if (defaultTargetPlatform ==
                            TargetPlatform.iOS) {
                          directory = await getDownloadsDirectory();
                        }
                        final File file =
                            File('${directory!.path}/squarecloud.config');
                        print(directory.path);
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
                        print(str);
                      } catch (e) {
                        print(e);
                        print('\n$str');
                      }
                    },
                    icon: const Icon(Icons.app_shortcut_outlined),
                    label: const Text('Gerar'),
                  ))
            ]))));
  }
}
