import 'package:flutter/material.dart';
import 'package:square/main.dart';
import 'package:square/modules/views/routes/upload/up.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

import 'apps/dash.dart';
import 'apps/files/edit.dart';
import 'user/user.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/splash':  (_) => const SplashScreen(),
    '/home': (_) => const HomePage(),
    '/config': (_) => const Config(),
    '/dash': (BuildContext context) {
      final Map<String, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? appID = arguments?['id'];
      return SheetConfigApps(appid: appID);
    },
     '/edit': (BuildContext context) {
      final Map<dynamic, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
      final String appID = arguments?['appid'] ?? '';
      final String lang = arguments?['lang'] ?? '';
      final String path = arguments?['path'] ?? '';
      return Editing(appid: appID, lang: lang, path: path,
        
      );
    }, 
    '/commit': (BuildContext context) {
      final Map<dynamic, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
      final String appID = arguments?['appId'] ?? '';
      return Commit(id: appID);
    },
    '/upload': (_) => const FilePickerUpload(),
  };

  static String initial = '/splash';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
