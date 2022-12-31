import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:square/routes/main_page/home.dart';
import 'package:square/routes/main_page/home/homescreen.dart';

import '../modules/functions/configapp.dart';

List<String> list = <String>['Gerenciar um App'];
var appID = {};
var totalapps = 0;
bool on = false;
var imageUrl = '';
var text1 = '', text2 = on ? 'em Execução' : 'Desligado';
var info = [];
var network = {};
var vs = false;
var msgreturn = '';
String? id = '';
getApps() async {
  const dbName = 'square';
  const dbAddress = 'localhost';

  const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

  var db = mongo.Db(defaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collection = db.collection('users');
  var res = await collection.findOne();
  List apps = res?['Applications'];
  totalapps = apps.length;
  print(apps.length);
  print(res?['Applications']);
  for (var i = 0; i < totalapps; i++) {
    list.add(apps[i]['tag']);
    appID.addAll({
      apps[i]['tag']: apps[i]['id'],
      'url${apps[i]['tag']}': apps[i]['avatar']
    });
  }
  await cleanupDatabase();
}

class Apps extends StatefulWidget {
  const Apps({super.key});

  @override
  State<Apps> createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
            visible: vs ? false : true,
            child: const Center(child: Text('Selecione uma Opção'))),
        Visibility(
            visible: vs ? false : true,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  onPressed: () {},
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
            ])),
        Visibility(visible: vs, child: const _ShowOptionsApps())
      ],
    );
  }

  Future<void> _dialogBuilder(BuildContext context, int option) {
    var nameapp = '';
    String dropdownValue = list.first;
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
              setState(() {
                  dropdownValue = value!;
                  nameapp = dropdownValue; 
              });
              if (option == 1) {
                // This is called when the user selects an item.
                setState(() {
                  if (dropdownValue == 'Gerenciar um App') {
                    vs = false;
                  } else {
                    vs = true;
                    statusApp(appID[nameapp]);
                    imageUrl = appID['url$nameapp'];
                    print(imageUrl);
                    text1 = '$nameapp(${appID[nameapp]})';
                    /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const _ShowOptionsApps(),
                      )); */
                  }
                });
              } else {
                id = appID[nameapp];
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Cmt()));
              }
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
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

class Cmt extends StatefulWidget {
  const Cmt({super.key});

  @override
  State<Cmt> createState() => _CmtState();
}

class _CmtState extends State<Cmt> {
  FilePickerResult? result;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (result != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected file:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: result?.files.length ?? 0,
                  itemBuilder: (context, index) {
                    return Text(result?.files[index].name ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold));
                  })
            ],
          ),
        ),
      Center(
        child: ElevatedButton(
          onPressed: () async {
            result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
            if (result == null) {
              print("No file selected");
            } else {
              String? path = result?.files.first.path;
              commit(id, path);
            }
          },
          child: const Text("File Picker"),
        ),
      )
    ]);
  }
}

class _ShowOptionsApps extends StatefulWidget {
  const _ShowOptionsApps();

  @override
  State<_ShowOptionsApps> createState() => __ShowOptionsAppsState();
}

class __ShowOptionsAppsState extends State<_ShowOptionsApps> {
  final Text rtn = Text(text2,
      style: TextStyle(color: on ? Colors.lightGreen : Colors.redAccent));
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            width: 379.9,
            height: 307.5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(2),
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: const Color(0xFF07FF5E),
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
              Align(
                alignment: const AlignmentDirectional(0, -1),
                child: Text(
                  text1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Status($rtn)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(children: [
                Text(
                  'Uso da CPU: ${info[0]}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(
                  Icons.data_usage,
                  color: Colors.deepPurpleAccent,
                  size: 22,
                ),
                Text(
                  'Uso da ram: ${info[1]}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(
                  Icons.device_hub_sharp,
                  color: Color(0xFF00FC4D),
                  size: 22,
                ),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Storage: ${info[2]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(
                    Icons.storage_sharp,
                    color: Color(0xFFFA0B0B),
                    size: 22,
                  ),
                  Text(
                    'Total de requests: ${info[3]}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
              onPressed: () {
                print('Button pressed ...');
              },
              label: const Text('Ligar sua Aplicação',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 16,
                  )),
              icon: const Icon(
                Icons.power,
                size: 15,
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ))),
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return const Color(0xFF24BC42);
                  }))),
          ElevatedButton.icon(
              onPressed: () {
                print('Button pressed ...');
              },
              label: const Text('Reiniciar sua Aplicação',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 16,
                  )),
              icon: const Icon(
                Icons.wifi_protected_setup_rounded,
                size: 15,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
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
              )),
          ElevatedButton.icon(
              onPressed: () {
                print('Button pressed ...');
              },
              label: const Text('Deletar sua Aplicação'),
              icon: const Icon(
                Icons.restore_from_trash,
                size: 15,
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return const Color(0xFFFA0B0B);
                  }),
                  textStyle:
                      MaterialStateProperty.all<TextStyle>(const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  )),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ))))
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                print('Button pressed ...');
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
                textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                )),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                )),
              ),
            ),
            ElevatedButton.icon(
                onPressed: () {
                  print('Button pressed ...');
                },
                label: const Text('Consulte os logs da sua Aplicação'),
                icon: const Icon(
                  Icons.receipt_long,
                  size: 15,
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return const Color(0xFFCAA009);
                    }),
                    textStyle:
                        MaterialStateProperty.all<TextStyle>(const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    )),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    )))),
          ],
        )
      ])
    ]);
  }
}
