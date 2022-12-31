import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../home/apps.dart';

Future statusApp(String? appID) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/status/$appID'),
      headers: <String, String>{
        'Authorization': prefs.getString('key').toString()
      });
  print(get.body);
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  //final DateTime uptime = DateTime.fromMillisecondsSinceEpoch(map['uptime']);
  info = [map['cpu'], map['ram'], map['storage'], map['requests']];
  network.addAll(map['network']);
  if (map['status'] == "running") {
    return on = true;
  } else {
    return on = false;
  }
}

Future start(String? appID) async {
  var status = 0;
  final prefs = await SharedPreferences.getInstance();
  if (on == false) {
    final get = await http.post(
        Uri.parse('https://api.squarecloud.app/v1/public/start/$appID'),
        headers: <String, String>{
          'Authorization': prefs.getString('key').toString()
        });
    print(get.body);
  } else {
    final get = await http.post(
        Uri.parse('https://api.squarecloud.app/v1/public/stop/$appID'),
        headers: <String, String>{
          'Authorization':
              '858677648317481010-d44c4fe7770d06bfd702b52ed4323f10ab254e6a720df4a2f5b2e07a7f2f0bd6'
        });
    print(get.body);
    status = get.statusCode;
  }
  if (status == 200) {
    return msgreturn =
        'A ação foi enviada ao cluster, tempo estimado de processamento: 3 segundos.';
  } else if (status == 401) {
    return msgreturn = 'Não autorizado!';
  } else if (status == 404) {
    return msgreturn = 'A aplicação não existe!';
  }
}

Future restart(String? appID) async {
  final prefs = await SharedPreferences.getInstance();
  if (on == false) {
    return msgreturn =
        'Sua aplicação não está ligada para realizar um reinicialização, inicie-a primeiro!';
  } else {
    final get = await http.post(
        Uri.parse('https://api.squarecloud.app/v1/public/restart/$appID'),
        headers: <String, String>{
          'Authorization': prefs.getString('key').toString()
        });
    print(get.body);
    if (get.statusCode == 200) {
      return msgreturn =
          'A ação foi enviada ao cluster, tempo estimado de processamento: 3 segundos.';
    } else if (get.statusCode == 401) {
      return msgreturn = 'Não autorizado!';
    } else if (get.statusCode == 404) {
      return msgreturn = 'A aplicação não existe!';
    }
  }
}

Future commit(String? appID, String? file) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.post(
      Uri.parse('https://api.squarecloud.app/v1/public/restart/$appID'),
      headers: <String, String>{
        'Authorization': prefs.getString('key').toString()
      });
  print(get.body);
}
