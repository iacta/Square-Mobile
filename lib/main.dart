import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'home.dart';
import './login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  hasInternetConnection();
}

Future hasInternetConnection() async {
  ConnectivityResult result = await Connectivity().checkConnectivity();
  if (result == ConnectivityResult.none) {
    runApp(const NanInternet());
  } else {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('key')) {
      runApp(const HomeApp());
    } else {
      runApp(const Login());
    }
  }
}

class _NanInternetState extends State<NanInternet> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
            backgroundColor: const Color.fromARGB(255, 11, 14, 19),

            body: Flex(
              direction: Axis.vertical,
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                    flex: 4,
                    child: Center(
                        child: Image.asset(
                      'assets/images/tomada.png',
                      color: const Color.fromARGB(255, 173, 225, 255),
                    ))),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('OopS...... ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellowAccent)),
                            Text(
                              '😮', // emoji characters
                              style: TextStyle(
                                  fontFamily: 'EmojiOne',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ]),
                      const Wrap(alignment: WrapAlignment.center, children: [
                        Text(
                            'Parece que os gnomos da internet mexeram \nem alguma coisa errada!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ))
                      ]),
                      const Text('Verifique sua conexão com a internet!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueGrey)),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: const Text('Tentar novamente')))
                    ],
                  ),
                ),
                const Expanded(flex: 2, child: SizedBox()),
              ],
            )));
  }
}

class NanInternet extends StatefulWidget {
  const NanInternet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NanInternetState createState() => _NanInternetState();
}
