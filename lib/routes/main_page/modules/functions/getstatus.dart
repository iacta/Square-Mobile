import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

void main() async {
  //status();
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
  List opa = ['teste'];
  var res = await collection.findOne();
  List teste = res?['Applications'];
  Iterable<void> list2 = teste.map((number) => opa.add(number));
  print(teste.length);
  print(res?['Applications']);
  print(opa);
  for (var i = 0; i < teste.length; i++) {
    opa.add(teste[i]['tag']);
  }
  print(opa);
  await cleanupDatabase();
}

Future status() async {
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/user'),
      headers: <String, String>{
        'Authorization':
            '858677648317481010-d44c4fe7770d06bfd702b52ed4323f10ab254e6a720df4a2f5b2e07a7f2f0bd6'
      });
  return print(get.body);
}

//https://status.squarecloud.app/r/2n8j/eeo9v website
//https://status.squarecloud.app/r/2n8j/eeodt documentation
//https://status.squarecloud.app/r/2n8k/eeo9y api
//https://status.squarecloud.app/r/2n8k/efax8 serviço banco de dados
//https://status.squarecloud.app/r/2n8k/efn70 serviço de pagamentos
//https://status.squarecloud.app/r/2n8k/egaip serviço de registro

// clusters

//https://status.squarecloud.app/r/2p88/ejl6q florida 1
//https://status.squarecloud.app/r/2p88/ejl6r florida 2
//https://status.squarecloud.app/r/2p88/ef3am florida 3
//https://status.squarecloud.app/r/2p88/ejndx florida gratis