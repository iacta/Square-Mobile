class Endpoints {
  static const String baseUrl = 'https://api.squarecloud.app/v2';
  static const String user = '$baseUrl/user';
  static const String appsStatus = '$baseUrl/apps/all/status';

  static String appStatus(String appId) => '$baseUrl/apps/$appId/status';
  static String backup(String id) => '$baseUrl/backup/$id';
  static String deploys(String appId) => '$baseUrl/apps/$appId/deploy/list';
  static String filesList(String id, String path) =>
      '$baseUrl/apps/$id/files/list?path=$path';
  static String filesRead(String id, String name) =>
      '$baseUrl/apps/$id/files/read?path=.%2F$name';
  static String filesCreate(String id) => '$baseUrl/apps/$id/files/create';
  static String filesDelete(String id, String name) =>
      '$baseUrl/apps/$id/files/delete?path=$name';

  static const String uploadApp = '$baseUrl/apps/upload';
  static const String commitApp = '$baseUrl/apps/commit';
  static String logsApp(String? appId) => '$baseUrl/apps/$appId/logs';

  static String startApp(String? appId) => '$baseUrl/apps/$appId/start';
  static String stopApp(String? appId) => '$baseUrl/apps/$appId/stop';
  static String restartApp(String? appId) => '$baseUrl/apps/$appId/restart';

  static String deleteApp(String? appId) => '$baseUrl/apps/$appId/delete';
}

