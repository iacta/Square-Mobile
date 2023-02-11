import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

bool onerr = false;
var errMsg = ['Nada Consta', 'Nada Consta'];
var data = <String, String>{'id': '', 'name': '', 'key': '', 'apps': ''};
var apps;
Future login(Uint8List crypto, BuildContext context) async {
  const decoder = Utf8Decoder();
  String k = decoder.convert(crypto);
  print(k);
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v1/public/user'),
    headers: <String, String>{
      'Authorization': k,
    },
  );
  print(onerr);
  print(errMsg);
  var stats = get.statusCode;
  print(stats);
  //print(get.body);
  if (stats == 401) {
    onerr = true;
    return showSnack(
        context, 'Não Autorizado, Verifique se sua chave de API está correta!');
  } else if (stats == 404) {
    onerr = true;
    return showSnack(context, 'O usuário não existe!');
  } else if (stats == 200) {
    onerr = false;
    Map<String, dynamic> req = json.decode(get.body);
    //print(req);
    var map = req["response"];
    print("\n\n\n\nApps test$map['applications']");
    data['id'] = map["user"]["id"];
    data['name'] = map["user"]["tag"];
    data['key'] = k;
    apps = map["applications"];
  }
}

account() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id', int.parse(data['id']!));
  await prefs.setString('name', data['name']!);
  await prefs.setString('key', data['key']!);
  var id = {}, name = {}, avatar = {};
  for (var i = 0; i < apps.length; i++) {
    id.addAll({i: apps[i]['id']});
    name.addAll({i: apps[i]['tag']});
    avatar.addAll({i: apps[i]['avatar']});
  }
  print(id);
  List<String>? list = id.values.cast<String>().toList();
  List<String>? list2 = name.values.cast<String>().toList();
  List<String>? list3 = avatar.values.cast<String>().toList();
  print(list);
  await prefs.setStringList('app-id', list);
  await prefs.setStringList('app-name', list2);
  await prefs.setStringList('app-avatar', list3);
  print(prefs.getStringList('app-id'));
  print(apps.length);
}

update(BuildContext key) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v1/public/user'),
    headers: <String, String>{
      'Authorization': prefs.getString('key')!,
    },
  );
  print(onerr);
  print(errMsg);
  var stats = get.statusCode;
  print(stats);
  //print(get.body);
  if (stats == 401) {
    showSnack(key,
        'Não Autorizado, Verifique se sua chave de API está correta!\nVocê pode troca-la em (Minha Conta/Trocar minha APIKey)');
  } else if (stats == 404) {
    return showSnack(key, 'O usuário não existe!');
  } else if (stats == 200) {
    onerr = false;
    Map<String, dynamic> req = json.decode(get.body);
    var map = req["response"];
    print("\n\n\n\nApps test$map['applications']");
    data['id'] = map["user"]["id"];
    data['name'] = map["user"]["tag"];
    data['key'] = prefs.getString('key')!;
    apps = map["applications"];

    await prefs.setInt('id', int.parse(data['id']!));
    await prefs.setString('name', data['name']!);
    var id = {}, name = {}, avatar = {};
    for (var i = 0; i < apps.length; i++) {
      id.addAll({i: apps[i]['id']});
      name.addAll({i: apps[i]['tag']});
      avatar.addAll({i: apps[i]['avatar']});
    }
    print(id);
    List<String>? list = id.values.cast<String>().toList();
    List<String>? list2 = name.values.cast<String>().toList();
    List<String>? list3 = avatar.values.cast<String>().toList();
    print(list);
    await prefs.setStringList('app-id', list);
    await prefs.setStringList('app-name', list2);
    await prefs.setStringList('app-avatar', list3);
    print(prefs.getStringList('app-id'));
    return showSnack(key, 'Dados atualizados com sucesso!');
  }
}

void showSnack(BuildContext context, String text) {
  var snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(
        color: Colors.white, /* fontWeight: FontWeight.bold */
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 62, 24, 151),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

err(String id, String msg) {
  onerr = true;
  errMsg[0] = id;
  errMsg[1] = msg;
}
