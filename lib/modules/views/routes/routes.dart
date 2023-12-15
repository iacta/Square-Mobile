import 'package:flutter/material.dart';
import 'package:square/modules/views/routes/main_page/up.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

import 'apps/dash.dart';
import 'apps/edit/edit.dart';
import 'main_page/config.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/home': (_) => const HomePage(),
    '/config': (_) => const Config(),
    '/dash': (BuildContext context) {
      final Map<String, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? appID = arguments?['id'];
      return SheetConfigApps(appid: appID,);
    },
    '/edit': (BuildContext context) {
      final Map<dynamic, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
      final String appID = arguments?['appid'] ?? '';
      final String lang = arguments?['lang'] ?? '';
      final String path = arguments?['path'] ?? '';
      final String source = arguments?['source'] ?? '';
      return Editing(
        source: source,
        lang: lang,
        appid: appID,
        path: path,
      );
    },
    '/commit': (BuildContext context) {
      final Map<dynamic, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
      final String appID = arguments?['appId'] ?? '';
      return Commit(id: appID);
    },
    '/upload': (_) => const FilePickerUpload(),
    '/squareconfig': (_) => const SquareConfig()
  };

  static String initial = '/home';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
