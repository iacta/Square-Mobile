import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square/modules/functions/apps.dart';
import 'package:url_launcher/url_launcher.dart';


class Account {
  String key;
  String name;
  int? id;
  bool isSelected;

  Account(this.key, this.name, {this.isSelected = false});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      json['key'] as String,
      json['name'] as String,
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'isSelected': isSelected,
      };
}

class AccountManager {
  static const String _sharedPreferencesKey = "accounts";
  static const String _selectAccountKey = "selectAccount";

  static Future<List<Account>> getAllAccounts() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountsString = sharedPreferences.getString(_sharedPreferencesKey);

    if (accountsString == null) {
      return [];
    }

    final dynamic decodedData = json.decode(accountsString);

    if (decodedData is List &&
        decodedData.every((element) => element is Map<String, dynamic>)) {
      final accounts =
          decodedData.cast<Map<String, dynamic>>().map((accountMap) {
        final account = Account.fromJson(accountMap);
        return account;
      }).toList();

      return accounts;
    } else {
      throw const FormatException("Invalid format for accounts data");
    }
  }

  static Future<bool> addAccount(Account account) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accounts = await getAllAccounts();
    if (accounts.any((a) => a.name == account.name)) {
      return false;
    }
    accounts.add(account);
    final accountsString = json.encode(accounts);
    await sharedPreferences.setString(_sharedPreferencesKey, accountsString);
    return true;
  }

  static Future<bool> deleteAccount(String accountName) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accounts = await getAllAccounts();
    final index = accounts.indexWhere((a) => a.name == accountName);
    if (index == -1) {
      return false;
    }
    accounts.removeAt(index);
    final accountsString = json.encode(accounts);
    await sharedPreferences.setString(_sharedPreferencesKey, accountsString);
    return true;
  }

  static Future<bool> selectAccount(String accountName) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_selectAccountKey, accountName);
    return true;
  }

  static Future<Account?> getCurrentAccount() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountName = sharedPreferences.getString(_selectAccountKey);
    if (accountName == null) {
      return null;
    }
    final accounts = await getAllAccounts();
    final account = accounts.firstWhere((a) => a.name == accountName);
    return account;
  }

  static Future<Account?> loadCurrentAccount() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountName = sharedPreferences.getString(_selectAccountKey);

    if (accountName == null) {
      return null;
    }

    final accounts = await getAllAccounts();

    if (accounts.isEmpty) {
      return null;
    }

    final account = accounts.firstWhere((a) => a.name == accountName);
    return account;
  }

  Future<int?> getSelectedAccountId() async {
    final account = await loadCurrentAccount();
    if (account == null) {
      return null;
    } else {
      return account.id;
    }
  }
}

List<Map<String, dynamic>> apps = [];
var data = <String, dynamic>{
  'id': '',
  'name': '',
  'key': '',
  'apps': <Map<String, dynamic>>[],
};

Future<void> login(String k, BuildContext context) async {
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

  if (stats == 401) {
    return showSnack(
      context,
      'Não Autorizado, Verifique se sua chave de API está correta!',
    );
  } else if (stats == 404) {
    return showSnack(context, 'O usuário não existe!');
  } else if (stats == 200) {
    final Map<String, dynamic> req = json.decode(get.body);
    var map = req["response"];
    data['id'] = map["user"]["id"];
    data['tag'] = map["user"]["tag"];
    data['key'] = k;
    data['apps'] = List<Map<String, dynamic>>.from(map["applications"]);
    final newAccount = Account(k, data['tag']);
    await AccountManager.addAccount(newAccount);
    await AccountManager.selectAccount(newAccount.key);
  }
}

String user = "...";

Future<void> account(BuildContext key) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v2/user'),
    headers: <String, String>{
      'Authorization': currentAccount!.key,
    },
  );
  var stats = get.statusCode;

  if (stats == 401) {
    showSnack(
      key,
      'Não Autorizado, Verifique se sua chave de API está correta!\nVocê pode trocá-la em (Minha Conta/Trocar minha APIKey)',
    );
  } else if (stats == 404) {
    return showSnack(key, 'O usuário não existe!');
  } else if (stats == 200) {
    Map<String, dynamic> req = json.decode(get.body);
    var map = req["response"];
    data['id'] = map["user"]["id"];
    data['name'] = map["user"]["tag"];
    data['key'] = currentAccount.key;
    data['apps'] = List<Map<String, dynamic>>.from(map["applications"]);
    return showSnack(key, 'Dados atualizados com sucesso!');
  }
}

Future stats(String appid) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.get(
    Uri.parse('https://api.squarecloud.app/v2/apps/$appid/status'),
    headers: <String, String>{
      'Authorization': currentAccount!.key,
    },
  );
  Map<String, dynamic> req = json.decode(get.body);
  var map = req["response"];

  return map['running'] as bool;
}

Future<List<Map<String, dynamic>>> getOfflineApps() async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final getAppsStatus = await http.get(
      Uri.parse('https://api.squarecloud.app/v2/apps/all/status'),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );

    if (getAppsStatus.statusCode == 200) {
      Map<String, dynamic> response = json.decode(getAppsStatus.body);
      if (response['status'] == 'success') {
        List<Map<String, dynamic>> allApps =
            List<Map<String, dynamic>>.from(response['response']);

        List<Map<String, dynamic>> offlineApps = [];

        for (var app in allApps) {
          if (!app['running']) {
            final getAppName = await http.get(
              Uri.parse(
                  'https://api.squarecloud.app/v2/apps/${app['id']}/status'),
              headers: <String, String>{
                'Authorization': currentAccount.key,
              },
            );

            if (getAppName.statusCode == 200) {
              Map<String, dynamic> appStatus = json.decode(getAppName.body);
              if (appStatus['status'] == 'success' &&
                  appStatus['response']['name'] != null) {
                offlineApps.add({
                  'id': app['id'],
                  'name': appStatus['response']['name'],
                });
              } else {}
            } else {}
          }
        }

        return offlineApps;
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

String formattedDuration = "";

Future planinfo(BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v2/user'),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
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
    if (kDebugMode) {
      print('Erro na solicitação: $e');
    }
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
    String? appid, BuildContext context) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final authorizationKey = currentAccount!.key;
  try {
    final response = await http.get(
      Uri.parse("https://api.squarecloud.app/v2/apps/$appid/status"),
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
  final currentAccount = await AccountManager.loadCurrentAccount();
  int statuscode = 0;
  final get = on == false
      ? await http.post(
          Uri.parse("https://api.squarecloud.app/v2/apps/$appID/start"),
          headers: <String, String>{
              'Authorization': currentAccount!.key,
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
  final currentAccount = await AccountManager.loadCurrentAccount();
  if (on == false) {
    showSnack(context,
        'Sua aplicação não está ligada para realizar um reinicialização, inicie-a primeiro!');
  } else {
    final get = await http.post(
        Uri.parse("https://api.squarecloud.app/v2/apps/$appID/restart"),
        headers: <String, String>{
          'Authorization': currentAccount!.key,
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
  final currentAccount = await AccountManager.loadCurrentAccount();

  var request = http.MultipartRequest("POST", uri);
  request.headers["Authorization"] = currentAccount!.key;

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
  final currentAccount = await AccountManager.loadCurrentAccount();

  var request = http.MultipartRequest("POST", uri);
  request.headers["Authorization"] = currentAccount!.key;
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
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.delete(
      Uri.parse("https://api.squarecloud.app/v2/apps/$appID/delete"),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      });
  int statuscode = get.statusCode;
  if (kDebugMode) {}
  if (statuscode == 200) {
    showSnack(
        context, 'O seu app foi deletado!\nAguarde o tempo de processamento!!');
    await account(context);
  } else if (statuscode == 401) {
    showSnack(context, 'Não autorizado!\nVerifique sua chave de APIKey');
  } else if (statuscode == 404) {
    showSnack(context, 'A aplicação não existe!');
  }
  Navigator.pop(context);
}

Future<void> backup(String? id, BuildContext context) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v2/backup/$id'),
      headers: <String, String>{'Authorization': currentAccount!.key});

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
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.get(
      Uri.parse("https://api.squarecloud.app/v2/apps/$appID/logs"),
      headers: <String, String>{'Authorization': currentAccount!.key});
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  if (map['logs'] != null) {
    logsmsg = map['logs'];
  }
}

var file;
Future<List<Map<String, dynamic>>?> files(String? id, String? path) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.get(
      Uri.parse(
          'https://api.squarecloud.app/v2/apps/$id/files/list?path=$path'),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response'];
    file = map;
    return map;
  } catch (e) {
    return null; // Trate o erro retornando um valor nulo ou outra coisa apropriada
  }
}

var fileread;
Future<void> file_read(String? id, String? name) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.get(
      Uri.parse(
          'https://api.squarecloud.app/v2/apps/$id/files/read?path=.%2F$name'),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response']['data'];
    fileread = map;
  } catch (e) {}
}

Future<void> file_create(
    String? id, String? buffer, BuildContext context, String? path) async {
  final currentAccount = await AccountManager.loadCurrentAccount();

  final get = Uri.parse('https://api.squarecloud.app/v2/apps/$id/files/create');

  var request = http.MultipartRequest("POST", get);
  request.headers["Authorization"] = currentAccount!.key;

  var buf = http.MultipartFile.fromBytes(
      "buffer", Uint8List.fromList(const Utf8Codec().encode(buffer!)));
  request.files.add(buf);
  var file = http.MultipartFile.fromString("path", path!);
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
  } catch (e) {
    rethrow;
  }
}

Future<void> file_delete(String? id, String? name) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.delete(
        Uri.parse(
            'https://api.squarecloud.app/v2/apps/$id/files/delete?path=.%2F$name'),
        headers: <String, String>{'Authorization': currentAccount!.key});
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response']['data'];
  } catch (e) {}
}

Future<void> _launchUrl(String url) async {
  final Uri urlparse = Uri.parse(url);
  if (!await launchUrl(urlparse.toString() as Uri)) {
    throw 'Could not launch $url';
  }
}

Future<void> full_logs(String? id) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.get(
      Uri.parse('https://api.squarecloud.app/v1/public/full-logs/$id'),
      headers: <String, String>{'Authorization': currentAccount!.key});
  Map<String, dynamic> req = json.decode(get.body);
  var map = req['response'];
  logsmsg = map['logs'];
}
