import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square/modules/functions/apps.dart';
import 'package:url_launcher/url_launcher.dart';

var data = <String, String>{'id': '', 'name': '', 'key': '', 'apps': ''};
List<Map<String, dynamic>> apps = [];
Future login(Uint8List crypto, BuildContext context) async {
  const decoder = Utf8Decoder();
  String k = decoder.convert(crypto);
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v2/user'),
    headers: <String, String>{
      'Authorization': k,
    },
  );
  var stats = get.statusCode;
  if (kDebugMode) {
    print(stats);
  }
  //print(get.body);
  if (stats == 401) {
    return showSnack(
        context, 'Não Autorizado, Verifique se sua chave de API está correta!');
  } else if (stats == 404) {
    return showSnack(context, 'O usuário não existe!');
  } else if (stats == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    //print(req);
    var map = req["response"];
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
  if (kDebugMode) {
    print(id);
  }
  List<String>? list = id.values.cast<String>().toList();
  List<String>? list2 = name.values.cast<String>().toList();
  List<String>? list3 = avatar.values.cast<String>().toList();
  await prefs.setStringList('app-id', list);
  await prefs.setStringList('app-name', list2);
  await prefs.setStringList('app-avatar', list3);
}

String user = "...";
Future<void> update(BuildContext key) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v2/user'),
    headers: <String, String>{
      'Authorization': prefs.getString('key')!,
    },
  );
  var stats = get.statusCode;

  if (stats == 401) {
    showSnack(key,
        'Não Autorizado, Verifique se sua chave de API está correta!\nVocê pode trocá-la em (Minha Conta/Trocar minha APIKey)');
  } else if (stats == 404) {
    return showSnack(key, 'O usuário não existe!');
  } else if (stats == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    var map = req["response"];
    data['id'] = map["user"]["id"];
    data['name'] = map["user"]["tag"];
    data['key'] = prefs.getString('key')!;
    apps = List<Map<String, dynamic>>.from(map[
        "applications"]); // Converta a lista de objetos JSON para uma lista de mapas.

    await prefs.setInt('id', int.parse(data['id']!));
    await prefs.setString('name', data['name']!);
    var id = {}, name = {}, avatar = {};
    for (var i = 0; i < apps.length; i++) {
      id.addAll({i: apps[i]['id']});
      name.addAll({i: apps[i]['tag']});
      avatar.addAll({i: apps[i]['avatar']});
    }
    List<String>? list = id.values.cast<String>().toList();
    List<String>? list2 = name.values.cast<String>().toList();
    List<String>? list3 = avatar.values.cast<String>().toList();
    await prefs.setStringList('app-id', list);
    await prefs.setStringList('app-name', list2);
    await prefs.setStringList('app-avatar', list3);
    user = data['name']!;
    if (kDebugMode) {
      print(apps);
    }
    return showSnack(key, 'Dados atualizados com sucesso!');
  }
}

Future stats(String appid) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v2/apps/$appid/status'),
    headers: <String, String>{
      'Authorization': prefs.getString('key')!,
    },
  );
  Map<String, dynamic> req = json.decode(get.body);
  var map = req["response"];

  return map['running'] as bool;
}

String formattedDuration = "";

Future planinfo(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v2/user'),
      headers: <String, String>{
        'Authorization': prefs.getString('key')!,
      },
    );

    if (get.statusCode == 200) {
      Map<String, dynamic> req = json.decode(get.body);
      var map = req["response"];
      data['plan'] = map["user"]["plan"]["name"];
      data['duration'] = map['user']['plan']['duration'].toString();
      data['available'] = map['user']['plan']['memory']['available'].toString();
      data['used'] = map['user']['plan']['memory']['used'].toString();
      data['duration'].toString() == 'null'
          ? formattedDuration = "PERMANENTE"
          : formattedDuration = formatDuration(data['duration']!);
    } else if (get.statusCode == 401) {
      showSnack(context,
          'Não Autorizado, Verifique se sua chave de API está correta!\nVocê pode trocá-la em (Minha Conta/Trocar minha APIKey)');
    } else if (get.statusCode == 404) {
      showSnack(context, 'O usuário não existe!');
    }
  } catch (e) {
    // Tratar a exceção aqui
    print('Erro na solicitação: $e');
    // Você pode mostrar uma mensagem de erro ou realizar outras ações apropriadas.
  }
}

String formatDuration(String duration) {
  int milliseconds = int.tryParse(duration) ?? 0;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  if (dateTime.isBefore(DateTime.now())) {
    return 'Já ocorreu';
  } else if (dateTime.isAtSameMomentAs(DateTime.now())) {
    return 'Agora';
  } else if (dateTime.isBefore(DateTime.now().add(const Duration(days: 1)))) {
    return 'Amanhã';
  } else if (dateTime.isBefore(DateTime.now().add(const Duration(days: 2)))) {
    return 'Hoje';
  } else {
    return _formatDate(dateTime);
  }
}

String _formatDate(DateTime dateTime) {
  return '${dateTime.day} de ${_getMonthName(dateTime.month)} de ${dateTime.year}';
}

String _getMonthName(int month) {
  final monthNames = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro'
  ];
  return monthNames[month - 1];
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

// ignore_for_file: non_constant_identifier_names
Future<Map<String, dynamic>> statusApp(
    String? appID, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final authorizationKey = prefs.getString('key') ?? '';

  try {
    final response = await http.get(
      Uri.parse("https://api.squarecloud.app/v2/apps/$appID/status"),
      headers: <String, String>{
        'Authorization': authorizationKey,
      },
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body)['response'];
      info = [map['cpu'], map['ram'], map['storage'], map['requests']];
      network.addAll(map['network']);

      return {
        'online': map['running'],
        'info': info,
      };
    } else if (response.statusCode == 401) {
      Navigator.pop(context);
      return {
        'error': 'Não autorizado!\nVerifique sua chave de APIKey',
      };
    } else if (response.statusCode == 404) {
      Navigator.pop(context);
      return {
        'error': 'A aplicação não existe!',
      };
    } else {
      return {
        'error': 'Erro desconhecido',
      };
    }
  } catch (e) {
    return {
      'error': e.toString(),
    };
  }
}

Future<void> start(String? appID, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  int statuscode = 0;
  final get = on == false
      ? await http.post(
          Uri.parse("https://api.squarecloud.app/v2/apps/$appID/start"),
          headers: <String, String>{
              'Authorization': prefs.getString('key') ?? '',
            })
      : await http.post(
          Uri.parse("https://api.squarecloud.app/v2/apps/$appID/stop"),
          headers: <String, String>{
              'Authorization':
                  '858677648317481010-d44c4fe7770d06bfd702b52ed4323f10ab254e6a720df4a2f5b2e07a7f2f0bd6'
            });

  statuscode = get.statusCode;

  if (statuscode == 200) {
    showSnack(context,
        'A ação foi enviada ao cluster, tempo estimado de processamento: 3 segundos.');
  } else if (statuscode == 401) {
    showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (statuscode == 404) {
    showSnack(context, 'A aplicação não existe!');
  }
}

Future<void> restart(String? appID, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (on == false) {
    showSnack(context,
        'Sua aplicação não está ligada para realizar um reinicialização, inicie-a primeiro!');
  } else {
    final get = await http.post(
        Uri.parse("https://api.squarecloud.app/v2/apps/$appID/restart"),
        headers: <String, String>{
          'Authorization': prefs.getString('key') ?? '',
        });
    statuscode = get.statusCode;
    if (get.statusCode == 200) {
      showSnack(context,
          'A ação foi enviada ao cluster, tempo estimado de processamento: 3 segundos.');
    } else if (get.statusCode == 401) {
      showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
    } else if (get.statusCode == 404) {
      showSnack(context, 'A aplicação não existe!');
    }
  }
}

Future<http.StreamedResponse> upload(String path, BuildContext context) async {
  final uri = Uri.parse('https://api.squarecloud.app/v2/apps/upload');
  final prefs = await SharedPreferences.getInstance();

  var request = http.MultipartRequest("POST", uri);
  request.headers["Authorization"] = prefs.getString('key') ?? '';

  var file = await http.MultipartFile.fromPath("body", path);
  request.files.add(file);

  showSnack(context, 'Request enviado! Aguarde alguns segundos.');

  try {
    final response = await request.send();
    if (response.reasonPhrase == 'Unauthorized') {
      showSnack(context, 'Não autorizado! Verifique sua chave de api!');
    } else {
      showSnack(context, 'Request enviado com sucesso!');
      pop = true;
    }
    return response;
  } catch (e) {
    rethrow;
  }
}

Future<http.StreamedResponse> commit(
    String? appID, String path, BuildContext context, bool restart) async {
  final uri = Uri.parse("https://api.squarecloud.app/v2/apps/commit");
  final prefs = await SharedPreferences.getInstance();

  var request = http.MultipartRequest("POST", uri);
  request.headers["Authorization"] = prefs.getString('key') ?? '';
  request.fields["restart"] = restart.toString();
  var file = await http.MultipartFile.fromPath("body", path);
  request.files.add(file);

  showSnack(context, 'Request enviado! Aguarde alguns segundos.');

  try {
    final response = await request.send();
    if (response.statusCode == 401) {
      showSnack(context, 'Não autorizado! Verifique sua chave de api!');
    } else if (response.statusCode == 404) {
      showSnack(context, 'O app não existe');
    } else if (response.statusCode == 200) {
      showSnack(context, 'Request enviado com sucesso!');
      pop = true;
    }
    return response;
  } catch (e) {
    rethrow;
  }
}

Future<void> delete(String? appID, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.delete(
      Uri.parse("https://api.squarecloud.app/v2/apps/$appID/delete"),
      headers: <String, String>{
        'Authorization': prefs.getString('key') ?? '',
      });
  int statuscode = get.statusCode;
  if (kDebugMode) {}
  if (statuscode == 200) {
    showSnack(
        context, 'O seu app foi deletado!\nAguarde o tempo de processamento!!');
    await update(context);
  } else if (statuscode == 401) {
    showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (statuscode == 404) {
    showSnack(context, 'A aplicação não existe!');
  }
  Navigator.pop(context);
}

Future<void> backup(String? id, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v2/backup/$id'),
      headers: <String, String>{'Authorization': prefs.getString('key')!});

  int statuscode = get.statusCode;
  if (statuscode == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response']['downloadURL'];
    _launchUrl(map);
  } else if (statuscode == 401) {
    showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (statuscode == 404) {
    showSnack(context, 'A aplicação não existe!');
  }
}

String logsmsg = '';
Future<void> logs(String? appID) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse("https://api.squarecloud.app/v2/apps/$appID/logs"),
      headers: <String, String>{'Authorization': prefs.getString('key') ?? ''});
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  logsmsg = map['logs'];
}

var file;
Future<List<Map<String, dynamic>>?> files(String? id, String? path) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final get = await http.get(
      Uri.parse(
          'https://api.squarecloud.app/v2/apps/$id/files/list?path=$path'),
      headers: <String, String>{
        'Authorization': prefs.getString('key') ?? '',
      },
    );
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response'];
    file = map;
    print("Chamado getFiles");
    return map;
  } catch (e) {
    print(e);
    return null; // Trate o erro retornando um valor nulo ou outra coisa apropriada
  }
}

var fileread;
Future<void> file_read(String? id, String? name) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final get = await http.get(
      Uri.parse(
          'https://api.squarecloud.app/v2/apps/$id/files/read?path=.%2F$name'),
      headers: <String, String>{
        'Authorization': prefs.getString('key') ?? '',
      },
    );
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response']['data'];
    fileread = map;
  } catch (e) {
    print(e);
  }
}

Future<void> file_create(
    String? id, String? buffer, BuildContext context, String? path) async {
  final prefs = await SharedPreferences.getInstance();

  final get = Uri.parse('https://api.squarecloud.app/v2/apps/$id/files/create');

  var request = http.MultipartRequest("POST", get);
  request.headers["Authorization"] = prefs.getString('key') ?? '';

  var buf = await http.MultipartFile.fromBytes(
      "buffer", Uint8List.fromList(const Utf8Codec().encode(buffer!)));
  request.files.add(buf);
  var file = await http.MultipartFile.fromString("path", path!);
  request.files.add(file);
  showSnack(context, 'Request enviado! Aguarde alguns segundos.');

  try {
    final response = await request.send();
    print(response);
    if (response.reasonPhrase == 'Unauthorized') {
      showSnack(context, 'Não autorizado! Verifique sua chave de api!');
    } else {
      showSnack(context, 'Request enviado com sucesso!');
      pop = true;
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> file_delete(String? id, String? name) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final get = await http.delete(
        Uri.parse(
            'https://api.squarecloud.app/v2/apps/$id/files/delete?path=.%2F$name'),
        headers: <String, String>{
          'Authorization': prefs.getString('key') ?? ''
        });
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response']['data'];
    print(map);
    print(name);
  } catch (e) {
    print(e);
  }
}

Future<void> _launchUrl(String url) async {
  final Uri urlparse = Uri.parse(url);
  if (!await launchUrl(urlparse.toString() as Uri)) {
    throw 'Could not launch $url';
  }
}

Future<void> full_logs(String? id) async {
  final prefs = await SharedPreferences.getInstance();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/full-logs/$id'),
      headers: <String, String>{'Authorization': prefs.getString('key') ?? ''});
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  logsmsg = map['logs'];
}
