import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:square/modules/functions/api/messages.dart';
import 'package:square/modules/functions/database/data.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../views/routes/apps/myapps.dart';
import '../../views/routes/upload/up.dart';
import 'endpoints.dart';

List<Map<String, dynamic>> apps = [];
var data = <String, dynamic>{
  'id': '',
  'name': '',
  'key': '',
  'apps': <Map<String, dynamic>>[],
};
var info = [];
bool online = false;
String logsmsg = '';
var fileread = [];

void handleException(dynamic e, BuildContext context) {
  log(data['name'], 'fatal', 'Erro na solicitação: $e');
  showSnack(context, 'Ocorreu um erro. Tente novamente mais tarde.');
}

Future<void> handleResponse(
  http.Response response,
  BuildContext context,
  void Function() onSuccess,
) async {
  final statusCode = response.statusCode;
  if (!context.mounted) {
    return;
  }
  if (kDebugMode) {
    log(data['name'], 'fatal', statusCode.toString());
  }

  if (statusCode == 401) {
    showSnack(context, Messages.send(context, 'unauthorized'));
  } else if (statusCode == 404) {
    showSnack(context, Messages.send(context, 'notFound'));
  } else if (statusCode == 200) {
    onSuccess();
  }
}

Future<void> login(String apiKey, BuildContext context) async {
  final response = await http.get(
    Uri.parse(Endpoints.user),
    headers: <String, String>{
      'Authorization': apiKey,
    },
  );

  handleResponse(response, context, () async {
    final Map<String, dynamic> req = json.decode(response.body);
    var map = req["response"];
    data['id'] = map["user"]["id"];
    data['tag'] = map["user"]["tag"];
    data['key'] = apiKey;
    data['apps'] = List<Map<String, dynamic>>.from(map["applications"]);
    var duration = map['user']['plan']['duration'];
    final newAccount = Account(apiKey, data['tag'], duration);
    await AccountManager.addAccount(newAccount);
    await AccountManager.selectAccount(newAccount.name);
  });
}

Future account(BuildContext context) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final response = await http.get(
    Uri.parse(Endpoints.user),
    headers: <String, String>{
      'Authorization': currentAccount!.key,
    },
  );
  if (!context.mounted) {
    return;
  }

  handleResponse(response, context, () {
    Map<String, dynamic> req = json.decode(response.body);
    var map = req["response"];
    data['id'] = map["user"]["id"];
    data['email'] = map['user']['email'];
    data['name'] = map["user"]["tag"];
    data['key'] = currentAccount.key;
    data['apps'] = List<Map<String, dynamic>>.from(map["applications"]);
    var duration = map['user']['plan']['duration'];
    currentAccount.planExpire = duration;

    AccountManager.saveAccount(currentAccount);
    showSnack(context, Messages.send(context, 'update'));
  });
  return AccountManager.getAllAccounts();
}

String _getCurrentTime() {
  DateTime now = DateTime.now();
  String formattedTime = '${now.hour}:${now.minute}:${now.second}';
  return formattedTime;
}

String _getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = '${now.day}/${now.month}/${now.year}';
  return formattedDate;
}

Future stats(String appId) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final get = await http.get(
    Uri.parse(Endpoints.appStatus(appId)),
    headers: <String, String>{
      'Authorization': currentAccount!.key,
    },
  );

  Map<String, dynamic> req = json.decode(get.body);
  var map = req["response"];
  if (map == null) {
    return error = true;
  }
  return map['running'] as bool;
}

/* Future<List<Map<String, dynamic>>> getOfflineApps(BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final getAppsStatus = await http.get(
      Uri.parse(Endpoints.appsStatus),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );

    handleResponse(getAppsStatus, context, () async {
      Map<String, dynamic> response = json.decode(getAppsStatus.body);
      if (response['status'] == 'success') {
        List<Map<String, dynamic>> allApps =
            List<Map<String, dynamic>>.from(response['response']);

        List<Map<String, dynamic>> offlineApps = [];

        for (var app in allApps) {
          if (!app['running']) {
            final getAppName = await http.get(
              Uri.parse(Endpoints.appStatus(app['id'])),
              headers: <String, String>{
                'Authorization': currentAccount.key,
              },
            );

            handleResponse(getAppName, context, () {
              Map<String, dynamic> appStatus = json.decode(getAppName.body);
              if (appStatus['status'] == 'success' &&
                  appStatus['response']['name'] != null) {
                offlineApps.add({
                  'id': app['id'],
                  'name': appStatus['response']['name'],
                });
              }
            });
          }
        }

        return offlineApps;
      }
    });

    return [];
  } catch (e) {
    return [];
  }
}
 */
String formattedDuration = "";
Completer<void> _completer = Completer<void>();
Future<void> planinfo(BuildContext context) async {
  try {
    if (!context.mounted) {
      return;
    }
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.get(
      Uri.parse(Endpoints.user),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );

    handleResponse(get, context, () {
      Map<String, dynamic> req = json.decode(get.body);
      var map = req["response"];
      data['plan'] = map["user"]["plan"]["name"];
      data['duration'] = map['user']['plan']['duration'].toString();
      data['limit'] = map['user']['plan']['memory']['limit'].toString();
      data['available'] = map['user']['plan']['memory']['available'].toString();
      data['used'] = map['user']['plan']['memory']['used'].toString();
      data['duration']?.toString() == 'null'
          ? formattedDuration = "PERMANENTE"
          : formattedDuration = formatDuration(data['duration']!, context);
    });
    if (!_completer.isCompleted) {
      _completer.complete(); // Completa apenas se ainda não foi completado
    }
  } catch (e) {
    log(data['name'], 'fatal', 'Erro ao processar plano de informações: $e');
    handleException(e, context);
  }
}

void cancelFunction() {
  if (!_completer.isCompleted) {
    _completer.completeError(
        'Cancelled'); // Completa com um erro para indicar cancelamento
  }
}

Future<Object> statusApp(String? appid, BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final authorizationKey = currentAccount!.key;

    final response = await http.get(
      Uri.parse(Endpoints.appStatus(appid!)),
      headers: <String, String>{
        'Authorization': authorizationKey,
      },
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body)['response'];
      info = [map['cpu'], map['ram'], map['storage'], map['requests']];
      online = map['running'];
      return info;
    } else {
      return {'error': 'Erro desconhecido'};
    }
  } catch (e) {
    handleException(e, context);
    return {'error': e.toString()};
  }
}

Future<void> start(String? appID, BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    int statusCode = 0;

    final response = online == false
        ? await http.post(
            Uri.parse(Endpoints.startApp(appID!)),
            headers: <String, String>{
              'Authorization': currentAccount!.key,
            },
          )
        : await http.post(
            Uri.parse(Endpoints.stopApp(appID!)),
            headers: <String, String>{
              'Authorization': currentAccount!.key,
            },
          );

    statusCode = response.statusCode;

    if (statusCode == 200) {
      showSnack(context, Messages.send(context, 'requestSent'));
    } else if (statusCode == 401) {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else if (statusCode == 404) {
      showSnack(context, Messages.send(context, 'notFound'));
    }
  } catch (e) {
    handleException(e, context);
  }
}

Future<void> restart(String? appID, BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    if (online == false) {
      showSnack(context,
          'Sua aplicação não está ligada para realizar uma reinicialização, inicie-a primeiro!');
    } else {
      final response = await http.post(
        Uri.parse(Endpoints.restartApp(appID!)),
        headers: <String, String>{
          'Authorization': currentAccount!.key,
        },
      );

      if (response.statusCode == 200) {
        showSnack(context, Messages.send(context, 'requestSent'));
      } else if (response.statusCode == 401) {
        showSnack(context, Messages.send(context, 'unauthorized'));
      } else if (response.statusCode == 404) {
        showSnack(context, Messages.send(context, 'notFound'));
      }
    }
  } catch (e) {
    handleException(e, context);
  }
}

Future log(String userID, String erroType, dynamic log) async {
  try {
    final uri = Uri.parse('https://squarelogs.squareweb.app/api/logs');

    final Map<String, dynamic> data = {
      "userid": userID,
      "timestamp": "${_getCurrentTime()} - ${_getCurrentDate()}",
      "errorType": erroType,
      "log": log
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      log("Solicitação bem-sucedida!");
      log("Resposta do servidor: ${response.body}");
    } else {
      log("Erro na solicitação: ${response.statusCode}");
      log("Resposta do servidor: ${response.body}");
    }
  } catch (e) {
    rethrow;
  }
}

Future upload(String path, BuildContext context) async {
  try {
    final uri = Uri.parse(Endpoints.uploadApp);
    final currentAccount = await AccountManager.loadCurrentAccount();

    var request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] = currentAccount!.key;

    var file = await http.MultipartFile.fromPath("body", path);
    request.files.add(file);

    showSnack(context, Messages.send(context, 'requestSent'));

    final response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    if (response.reasonPhrase == 'Unauthorized') {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else {
      if (responseData['status'] == 'sucess') {
        showSnack(context, Messages.send(context, 'requestSuccess'));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogMsg(
              text: responseData['code'],
            );
          },
        );
      }
      return true;
    }
  } catch (e) {
    handleException(e, context);
    rethrow;
  }
}

Future<http.StreamedResponse> commit(
    String? appID, String path, BuildContext context, bool restart) async {
  try {
    Uri uri;
    if (restart == true) {
      uri = Uri.parse(
          'https://api.squarecloud.app/v2/apps/$appID/commit?restart=true');
    } else {
      uri = Uri.parse('https://api.squarecloud.app/v2/apps/$appID/commit');
    }
    final currentAccount = await AccountManager.loadCurrentAccount();

    var request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] = currentAccount!.key;
    var file = await http.MultipartFile.fromPath("body", path);
    request.files.add(file);

    showSnack(context, Messages.send(context, 'requestSent'));

    final response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 401) {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else if (response.statusCode == 404) {
      showSnack(context, Messages.send(context, 'notFound'));
    } else if (response.statusCode == 200) {
      if (responseData['status'] == 'sucess') {
        showSnack(context, Messages.send(context, 'requestSuccess'));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogMsg(
              text: responseData['code'],
            );
          },
        );
      }
    }

    return response;
  } catch (e) {
    handleException(e, context);
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
    showSnack(context, Messages.send(context, 'delete'));
    filteredApps = [];
    await account(context);
    filterManager.setFilter('All');
    Navigator.pop(context);
  } else if (statuscode == 401) {
    showSnack(context, Messages.send(context, 'unauthorized'));
  } else if (statuscode == 404) {
    showSnack(context, Messages.send(context, 'notFound'));
  }
}

Future<void> backup(String? id, BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final response = await http.get(Uri.parse(Endpoints.backup(id!)),
        headers: <String, String>{'Authorization': currentAccount!.key});

    int statusCode = response.statusCode;

    if (statusCode == 200) {
      Map<String, dynamic> req = json.decode(response.body);
      var map = req['response']['downloadURL'];
      _launchUrl(map);
    } else if (statusCode == 401) {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else if (statusCode == 404) {
      showSnack(context, Messages.send(context, 'notFound'));
    }
  } catch (e) {
    handleException(e, context);
  }
}

Future<void> logs(String? appID) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final response = await http.get(
      Uri.parse(Endpoints.logsApp(appID)),
      headers: <String, String>{'Authorization': currentAccount!.key},
    );
    Map<String, dynamic> req = json.decode(response.body);
    var map = req['response'];

    if (map['logs'] != null) {
      logsmsg = map['logs'];
    }
  } catch (e) {
    if (kDebugMode) {
      log(data['name'], 'fatal', 'Erro na solicitação de logs: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> deploys(String? appid) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final response = await http.get(
      Uri.parse(Endpoints.deploys(appid!)),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );

    log(data['name'], 'fatal', '${response.statusCode}');

    if (response.statusCode == 200) {
      var req = json.decode(response.body);

      var map = req['response'];

      List<Map<String, dynamic>> results = [];
      for (var list in map) {
        for (var item in list) {
          results.add({
            'id': item['id'],
            'date': item['date'],
            'status': item['state']
          });
        }
      }
      return results;
    } else {
      throw Exception('Falha ao carregar deploys');
    }
  } catch (e) {
    log(data['name'], 'fatal', '$e');
    throw Exception('Erro inesperado');
  }
}

Future deployCreate(String? key, String? appId, BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();

    final response = await http.post(
      Uri.parse(
          'https://api.squarecloud.app/v2/apps/$appId/deploy/git-webhook'),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'access_token': key,
      }),
    );

    log(data['name'], 'fatal', '${response.statusCode}');

    showSnack(context, Messages.send(context, 'requestSuccess'));
    if (response.statusCode == 401) {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else {
      var req = json.decode(response.body);

      var map = req['response'];
      return {'response': map['webhook'], 'sucess': true};
    }
  } catch (e) {
    log(data['name'], 'fatal', '$e');
    throw Exception('Erro inesperado');
  }
}

Future<List<Map<String, dynamic>>> network(String? appid) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final response = await http.get(
      Uri.parse(Endpoints.deploys(appid!)),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );

    log(data['name'], 'fatal', '${response.statusCode}');

    if (response.statusCode == 200) {
      var req = json.decode(response.body);

      var map = req['response'];
      return map['hostname'];
    } else {
      throw Exception('Falha ao carregar deploys');
    }
  } catch (e) {
    log(data['name'], 'fatal', '$e');
    throw Exception('Erro inesperado');
  }
}

Future networkCreate(String? key, String? appId, BuildContext context) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();

    final response = await http.post(
      Uri.parse(
          'https://api.squarecloud.app/v2/apps/$appId/network/custom/$key'),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
        'Content-Type': 'application/json',
      },
    );

    log(data['name'], 'fatal', '${response.statusCode}');

    showSnack(context, Messages.send(context, 'requestSuccess'));
    if (response.statusCode == 401) {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else {
      var req = json.decode(response.body);

      var map = req['response'];
      return {'response': map['status'], 'sucess': true};
    }
  } catch (e) {
    log(data['name'], 'fatal', '$e');
    throw Exception('Erro inesperado');
  }
}

dynamic file;
Future files(String? id, String? path) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.get(
      Uri.parse(Endpoints.filesList(id!, path!)),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );
    Map<String, dynamic> req = json.decode(get.body);
    var map = req['response'];
    file = map;
    return map;
  } catch (e) {
    return [];
  }
}

Future<String> fileRead(String? id, String? name) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final response = await http.get(
      Uri.parse(Endpoints.filesRead(id!, name!)),
      headers: <String, String>{
        'Authorization': currentAccount!.key,
      },
    );
    final req = json.decode(response.body);
    var res = req['response']['data'];
    List<int> bytes = res.cast<int>();
    String? decodedString = utf8.decode(bytes);
    return decodedString;
  } catch (e) {
    log(data['name'], 'fatal', '$e');
    rethrow;
  }
}

Future<void> fileCreate(
  String? id,
  String? buffer,
  BuildContext context,
  String? path,
) async {
  final currentAccount = await AccountManager.loadCurrentAccount();
  final url = Uri.parse(Endpoints.filesCreate(id!));
  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": currentAccount!.key,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "path": path,
        "buffer": Uint8List.fromList(utf8.encode(buffer!)),
      }),
    );
    showSnack(context, Messages.send(context, 'requestSuccess'));
    if (response.statusCode == 401) {
      showSnack(context, Messages.send(context, 'unauthorized'));
    } else {
      showSnack(context, Messages.send(context, 'send'));
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> fileDelete(BuildContext context, String? id, String? name) async {
  try {
    final currentAccount = await AccountManager.loadCurrentAccount();
    final get = await http.delete(
      Uri.parse(Endpoints.filesDelete(id!, name!)),
      headers: <String, String>{'Authorization': currentAccount!.key},
    );
    if (get.statusCode == 200) {
      showSnack(context, Messages.send(context, 'requestSuccess'));
    } else {
      showSnack(context, Messages.send(context, 'badRequest'));
    }
  } catch (e) {
    log(data['name'], 'fatal', '$e');
  }
}

Future<void> _launchUrl(String url) async {
  final Uri urlparse = Uri.parse(url);
  if (!await launchUrl(urlparse.toString() as Uri)) {
    throw 'Could not launch $url';
  }
}

void showSnack(BuildContext context, String text) {
  if (!context.mounted) return;
  var snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(
        color: Colors.white, /* fontWeight: FontWeight.bold */
      ),
    ),
    backgroundColor: const Color.fromARGB(188, 18, 7, 122),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String formatDuration(String duration, BuildContext context) {
  int milliseconds = int.tryParse(duration) ?? 0;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  if (dateTime.isBefore(DateTime.now())) {
    return translate(
        context.locale.toString(), 'date_messages', 'already_occurred');
  } else if (dateTime.isAtSameMomentAs(DateTime.now())) {
    return translate(context.locale.toString(), 'date_messages', 'now');
  } else if (dateTime.isBefore(DateTime.now().add(const Duration(days: 1)))) {
    return translate(context.locale.toString(), 'date_messages', 'tomorrow');
  } else if (dateTime.isBefore(DateTime.now().add(const Duration(days: 2)))) {
    return translate(context.locale.toString(), 'date_messages', 'today');
  } else {
    return _formatDate(dateTime, context);
  }
}

String _formatDate(DateTime dateTime, BuildContext context) {
  if (context.locale.toString() == 'en') {
    return ' ${_getMonthName(dateTime.month, context)} ${dateTime.day}, ${dateTime.year}';
  } else {
    return ' ${dateTime.day} de ${_getMonthName(dateTime.month, context)} de ${dateTime.year}';
  }
}

String _getMonthName(int month, BuildContext context) {
  return translate('months', context.locale.toString(), '${month - 1}');
}
