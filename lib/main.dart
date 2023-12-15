import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:square/modules/functions/notify.dart';

import 'modules/functions/api.dart';
import './login.dart';
import 'modules/views/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  //prefs.clear();
  runApp(await decideInitialScreen());
}

Future<Widget> decideInitialScreen() async {
  if (!await hasInternetConnection()) {
    return const NanInternet();
  }

  final accounts = await AccountManager.getAllAccounts();
  if (accounts.isNotEmpty) {
    List<Map<String, dynamic>> offlineApps = await getOfflineApps();

    if (offlineApps.isNotEmpty) {
      String offlineAppDetails =
          offlineApps.map((app) => '${app['name']} (${app['id']})').join(', ');
    } else {
    }
    return MaterialApp(
      navigatorKey: Routes.navigatorKey,
      routes: Routes.list,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      initialRoute: Routes.initial,
    );
  } else {
    return const Login();
  }
}

Future<bool> hasInternetConnection() async {
  ConnectivityResult result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}

class NanInternet extends StatelessWidget {
  const NanInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  'assets/images/tomada.png',
                  color: const Color.fromARGB(255, 173, 225, 255),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'OopS...... ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.yellowAccent,
                        ),
                      ),
                      Text(
                        '😮', // emoji characters
                        style: TextStyle(
                          fontFamily: 'EmojiOne',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Parece que os gnomos da internet mexeram \nem alguma coisa errada!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Verifique sua conexão com a internet!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Tentar novamente'),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
