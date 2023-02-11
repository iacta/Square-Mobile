import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../home/apps.dart';

Future statusApp(String? infoapp, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/status/$infoapp'),
      headers: <String, String>{
        'Authorization': prefs.getString('key').toString()
      });
  print(get.body);
  if (get.statusCode == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response'];
    //final DateTime uptime = DateTime.fromMillisecondsSinceEpoch(map['uptime']);
    info = [map['cpu'], map['ram'], map['storage'], map['requests']];
    network.addAll(map['network']);
    if (map['running'] == true) {
      return on = true;
    } else {
      return on = false;
    }
  } else if (get.statusCode == 401) {
    Navigator.pop(context);
    return showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (get.statusCode == 404) {
    Navigator.pop(context);
    return showSnack(context, 'A aplicação não existe!');
  }
}

Future start(String? infoapp, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (on == false) {
    final get = await http.post(
        Uri.parse('https://api.squarecloud.app/v1/public/start/$infoapp'),
        headers: <String, String>{
          'Authorization': prefs.getString('key').toString()
        });
    print(get.body);
    statuscode = get.statusCode;
  } else {
    final get = await http.post(
        Uri.parse('https://api.squarecloud.app/v1/public/stop/$infoapp'),
        headers: <String, String>{
          'Authorization':
              '858677648317481010-d44c4fe7770d06bfd702b52ed4323f10ab254e6a720df4a2f5b2e07a7f2f0bd6'
        });
    print(get.body);
    statuscode = get.statusCode;
  }
  if (statuscode == 200) {
    return showSnack(context,
        'A ação foi enviada ao cluster, tempo estimado de processamento: 3 segundos.');
  } else if (statuscode == 401) {
    return showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (statuscode == 404) {
    return showSnack(context, 'A aplicação não existe!');
  }
}

Future restart(String? infoapp, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (on == false) {
    return showSnack(context,
        'Sua aplicação não está ligada para realizar um reinicialização, inicie-a primeiro!');
  } else {
    final get = await http.post(
        Uri.parse('https://api.squarecloud.app/v1/public/restart/$infoapp'),
        headers: <String, String>{
          'Authorization': prefs.getString('key').toString()
        });
    print(get.body);
    statuscode = get.statusCode;
    if (get.statusCode == 200) {
      return showSnack(context,
          'A ação foi enviada ao cluster, tempo estimado de processamento: 3 segundos.');
    } else if (get.statusCode == 401) {
      return showSnack(
          context, 'Não autorizado!\nVerifique sua chave de APIKey');
    } else if (get.statusCode == 404) {
      return showSnack(context, 'A aplicação não existe!');
    }
  }
}

Future<http.StreamedResponse> upload(String path, BuildContext context) async {
  var uri = Uri.parse("https://api.squarecloud.app/v1/public/upload");
  final prefs = await SharedPreferences.getInstance();
  var request = http.MultipartRequest("POST", uri);
  request.headers["Authorization"] = prefs.getString('key')!;

  var file = await http.MultipartFile.fromPath("body", path);
  request.files.add(file);
  showSnack(context, 'Request enviado! Aguarde alguns segundos.');
  try {
    var response = await request.send();
    if (response.reasonPhrase == 'Unauthorized') {
      showSnack(context, 'Não autorizado! Verifique sua chave de api!');
    } else {
      showSnack(context, 'Request enviado com sucesso!');
      pop = true;
    }
    print(response.reasonPhrase);
    return response;
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<http.StreamedResponse> commit(
    String? appid, String path, BuildContext context, bool restart) async {
  var uri = Uri.parse("https://api.squarecloud.app/v1/public/commit/$appid");
  final prefs = await SharedPreferences.getInstance();
  var request = http.MultipartRequest("POST", uri);
  request.headers["Authorization"] = prefs.getString('key')!;
  request.fields["restart"] = restart as String;
  var file = await http.MultipartFile.fromPath("body", path);
  request.files.add(file);
  showSnack(context, 'Request enviado! Aguarde alguns segundos.');
  try {
    var response = await request.send();
    if (response.statusCode == 401) {
      return showSnack(context, 'Não autorizado! Verifique sua chave de api!');
    } else if (response.statusCode == 404) {
      return showSnack(context, 'O app não existe');
    } else if (response.statusCode == 200) {
      showSnack(context, 'Request enviado com sucesso!');
      pop = true;
    }
    print(response.reasonPhrase);
    return response;
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future delete(String? infoapp, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.post(
      Uri.parse('https://api.squarecloud.app/v1/public/delete/$infoapp'),
      headers: <String, String>{
        'Authorization': prefs.getString('key').toString()
      });
  print(get.body);
  statuscode = get.statusCode;
  if (get.statusCode == 200) {
    return showSnack(context, 'O seu app foi deletado!');
  } else if (get.statusCode == 401) {
    return showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (get.statusCode == 404) {
    return showSnack(context, 'A aplicação não existe!');
  }
}

Future backup(String? id, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/backup/$id'),
      headers: <String, String>{'Authorization': prefs.getString('key')!});
  print(get.body);
  print(id);
  statuscode = get.statusCode;
  print(statuscode);
  if (get.statusCode == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response']['downloadURL'];
    _launchUrl(map);
  } else if (get.statusCode == 401) {
    return showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (get.statusCode == 404) {
    return showSnack(context, 'A aplicação não existe!');
  }
}

Future logs(String? id) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/logs/$id'),
      headers: <String, String>{'Authorization': prefs.getString('key')!});
  print(get.body);
  print(id);
  statuscode = get.statusCode;
  print(statuscode);
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  logsmsg = map['logs'];
}

Future full_logs(String? id) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/full-logs/$id'),
      headers: <String, String>{'Authorization': prefs.getString('key')!});
  print(get.body);
  print(id);
  statuscode = get.statusCode;
  print(statuscode);
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  logsmsg = map['logs'];
}

showSnack(BuildContext context, String text) {
  var snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(
        color: Colors.white, /* fontWeight: FontWeight.bold */
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 62, 24, 151),
  );
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> _launchUrl(String url) async {
  final Uri urlparse = Uri.parse(url);
  if (!await launchUrl(urlparse)) {
    throw 'Could not launch $url';
  }
}
