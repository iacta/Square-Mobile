import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/functions/notifications/notify.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:square/themes/themes.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import './login.dart';
import 'modules/functions/database/data.dart';
import 'modules/views/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await EasyLocalization.ensureInitialized();

  //initializeWorkManager();

  runApp(EasyLocalization(
    supportedLocales: const <Locale>[
      Locale('pt'),
      Locale('en'),
      Locale('es'),
      Locale('hr'),
      Locale('zh')
    ],
    path: 'assets/translations',
    child: await decideInitialScreen(),
  ));
  tz.initializeTimeZones();

  Timer.periodic(const Duration(hours: 24), (Timer timer) async {
    final accountManager = AccountManager();
    await accountManager.checkPlanExpiration();
  });
}

Future<Widget> decideInitialScreen() async {
  if (!await hasInternetConnection()) {
    return const NoInternetScreen();
  }

  final accounts = await AccountManager.getAllAccounts();

  if (accounts.isNotEmpty) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorKey: Routes.navigatorKey,
      routes: Routes.list,
      debugShowCheckedModeBanner: false,
      theme: defaultTheme,
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

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: defaultTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFF0B0E13),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  'assets/images/tomada.png',
                  color: const Color(0xFFADFFF9),
                  height: 150, // Adjust the height as needed
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
                        'Oops...',
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
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Parece que os gnomos da internet mexeram\nem alguma coisa errada!',
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Tentar Novamente'),
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late List<String> messages;
  late String currentMessage;
  late Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Agora você pode obter o contexto localizado para tradução
    messages = [
      translate(context.locale.toString(), 'load', 'loading'),
      translate(context.locale.toString(), 'load', 'communityInfo'),
      translate(context.locale.toString(), 'load', 'additionalMessage'),
    ];
    currentMessage = messages[0];

    // Define um temporizador para alternar as mensagens a cada 2 segundos
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentMessage =
            messages[(messages.indexOf(currentMessage) + 1) % messages.length];
      });
    });
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 14, 19),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/squarecloud.gif',
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(currentMessage,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic))),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: WaveWidget(
              config: CustomConfig(
                gradients: [
                  [Colors.purple, Colors.purple],
                  [
                    Colors.indigo[900] ?? Colors.transparent,
                    Colors.indigo[900] ?? Colors.transparent
                  ], // Azul escuro
                  [
                    Colors.indigo[400] ?? Colors.transparent,
                    Colors.indigo[400] ?? Colors.transparent
                  ], // Azul claro
                ],
                durations: [19440, 10800, 6000],
                heightPercentages: [0.05, 0.02, 0.03],
                blur: const MaskFilter.blur(BlurStyle.solid, 10),
                gradientBegin: Alignment.bottomLeft,
                gradientEnd: Alignment.topRight,
              ),
              waveAmplitude: 0,
              backgroundColor: Colors.transparent,
              size: const Size(double.infinity, 60.0),
            ),
          ),
        ],
      ),
    );
  }
}
