import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

void main() {
  logsCreate('1234', 'fatal', 'askdoakdoasdokoadksodoakdokad');
}

void upload(String path) async {
  dynamic responseData;
  try {
    final uri = Uri.parse('https://api.squarecloud.app/v2/apps/upload');
    var request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] =
        '858677648317481010-059a83a9d4bffc0561c0a667a130da456bb8453a36b5ae16512082094d32a57f ';

    var file = await http.MultipartFile.fromPath("body", path);
    request.files.add(file);

    final response = await request.send();
    var responsed = await http.Response.fromStream(response);
    responseData = json.decode(responsed.body);
    log(responseData);
    if (response.reasonPhrase == 'Unauthorized') {
      log('sem autoziação');
    } else {
      //log(responseData);
      log('data salve ${responseData['code']}');
    }
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

Future<http.StreamedResponse> commit(
    String? appID, String path, bool restart) async {
  try {
    Uri uri;
    if (restart == true) {
      uri = Uri.parse(
          'https://api.squarecloud.app/v2/apps/$appID/commit?restart=true');
    } else {
      uri = Uri.parse('https://api.squarecloud.app/v2/apps/$appID/commit');
    }

    var request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] =
        '858677648317481010-059a83a9d4bffc0561c0a667a130da456bb8453a36b5ae16512082094d32a57f';
    var file = await http.MultipartFile.fromPath("body", path);
    request.files.add(file);

    final response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    log(response.statusCode.toString());

    log(responseData);

    if (response.statusCode == 401) {
    } else if (response.statusCode == 404) {
    } else if (response.statusCode == 200) {}

    return response;
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

Future logsCreate(String userID, String erroType, dynamic logs) async {
  try {
    final uri = Uri.parse('https://squarelogs.squareweb.app/api/logs');

    final Map<String, dynamic> data = {
      "userid": userID,
      "timestamp": "${_getCurrentTime()} - ${_getCurrentDate()}",
      "errorType": erroType,
      "log": logs
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
