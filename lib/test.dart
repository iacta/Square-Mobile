import 'package:flutter/material.dart';

void main() => runApp(const Main());

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("teste"),
        ),
        body: Column(
            children: const <Widget>[
              /*AnimationController(
                vsync:,
                 
              )*/
            ],
        ),
      ),
    );
  }
}
