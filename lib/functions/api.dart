import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool onerr = false;
var errMsg = ['Nada Consta', 'Nada Consta'];
var data = <String, String>{'id': '', 'name': '', 'key': '', 'apps': ''};
var apps;
Future login(Uint8List crypto) async {
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
    err('Erro 401!',
        'Não Autorizado, Verifique se sua chave de API está correta!');
  } else if (stats == 404) {
    return err('Erro 404!', 'O usuário não existe!');
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
  return onerr;
}

account() async {
  const dbName = 'square';
  const dbAddress = 'localhost';

  const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

  var db = Db(defaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'users';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);
  var ret = await collection.insertOne(<String, dynamic>{
    '_id': int.parse(data['id']!),
    'name': data['name'],
    'Applications': apps
  });
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  var res = await collection.findOne();

  print('Fetched ${res?['name']}');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id', int.parse(data['id']!));
  await prefs.setString('name', data['name']!);
  await prefs.setString('key', data['key']!);
  await cleanupDatabase();
}

err(String id, String msg) {
  onerr = true;
  errMsg[0] = id;
  errMsg[1] = msg;
}
