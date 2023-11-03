import 'package:flutter/material.dart';
import 'package:square/modules/views/routes/main_page/apps/myapps.dart';

import '../views/routes/main_page/homescreen.dart';

var totalapps = 0;
var load = false;
bool on = false;
bool pop = false;
var info = [];
var network = {};
var vs = false;
String msgreturn = '';
String? id = '';
var statuscode = 0;
int opt = 0;
bool vsp = false;

class Apps extends StatefulWidget {
  const Apps({super.key});

  @override
  State<Apps> createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  double buttonSize = 100.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Alinhar os botões ao centro
          children: [
            const SizedBox(
              height: 20,
            ),
            buildButtonWithDialog(
              label: 'Minhas Aplicações',
              dialogType: 1,
              context: context,
              icon: Icons.settings_applications_outlined,
              iconColor: const Color(0xFF2563EB),
              size: buttonSize,
            ),
            const SizedBox(height: 20),
           
          ],
        ),
      ),
    );
  }

  // Resto do código...

  Widget buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required BuildContext context,
    IconData? icon,
    Color? iconColor,
    double? size, // Tamanho do botão
  }) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size>(
          const Size(180, 180), // Define o tamanho do botão
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(
              15), // Remova o preenchimento para que o tamanho seja respeitado
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return fieldBackgroundColor;
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Tornamos o botão redondo
            side: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: size, // Tamanho do ícone proporcional ao tamanho do botão
            color: iconColor ?? Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonWithNavigation({
    required String label,
    required Widget route,
    required BuildContext context,
    IconData? icon,
    Color? iconColor,
    double? size,
  }) {
    return buildActionButton(
      label: label,
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
      context: context,
      icon: icon,
      iconColor: iconColor,
      size: size!,
    );
  }

  Widget buildButtonWithDialog({
    required String label,
    required int dialogType,
    required BuildContext context,
    IconData? icon,
    Color? iconColor,
    double? size,
  }) {
    return buildActionButton(
      label: label,
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BotListScreen()));
      },
      context: context,
      icon: icon,
      iconColor: iconColor,
      size: size,
    );
  }
}



/* var logsmsg = '';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 90,
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: Column(children: [
          SizedBox(
              height: 500,
              child: Container(
                  color: const Color.fromARGB(176, 59, 56, 56),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: const Color.fromARGB(111, 0, 0, 0),
                        child: Text(
                          logsmsg,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      )
                    ],
                  )))
        ]));
  }
}

class LogsPage2 extends StatelessWidget {
  const LogsPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 90,
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(logsmsg),
                  icon: const Icon(Icons.account_tree_sharp),
                  label: const Text('Clique aqui para acessar seu terminal')))
        ]));
  }
} */

