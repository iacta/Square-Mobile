// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'functions/api.dart';
import 'routes/main_page/home.dart';

void main() => runApp(const Login());

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final control = TextEditingController();
  @override
  void dispose() {
    control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
          appBar: AppBar(centerTitle: true, title: const Text('Square Login')),
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                alignment: AlignmentDirectional.center,
                child: SizedBox(
                    width: 400,
                    child: Theme(
                        data: Theme.of(context).copyWith(
                          inputDecorationTheme: Theme.of(context)
                              .inputDecorationTheme
                              .copyWith(iconColor:
                                  MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                            if (states.contains(MaterialState.focused)) {
                              return const Color.fromARGB(255, 22, 255, 22);
                            }
                            if (states.contains(MaterialState.error)) {
                              return Colors.deepOrange;
                            }
                            return Colors.grey;
                          })),
                        ),
                        child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: control,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              label: const Text(
                                'Insira sua APIKey',
                                style: TextStyle(color: Colors.white),
                              ),
                              prefixIcon: const Icon(Icons.key),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(60),
                                  borderSide: const BorderSide(
                                      width: 3,
                                      color:
                                          Color.fromARGB(255, 221, 101, 101))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 3,
                                      color: Color.fromARGB(255, 22, 255, 22))),
                            ))))),
            Showbox(control: control.text)
          ])),
    );
  }
}

class Showbox extends StatelessWidget {
  String control = '';
  Showbox({super.key, required this.control});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(255, 22, 255, 22)),
          padding:
              MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)),
        ),
        onPressed: () async {
          var encoder = utf8.encoder;
          var crypt = encoder.convert(control);
          await login(crypt);
          if (onerr == true) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      errMsg[0],
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    content: Text(errMsg[1]),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                });
          } else {
            account();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeApp(),
                ));
          }
          //print(data['response']['user']['id']);
        },
        child: const Text('Logar'));
  }
}
