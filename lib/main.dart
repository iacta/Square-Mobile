import 'package:flutter/material.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final double _largura = 100;
  double _altura = 100;
  bool vs = false;

  play() {
    setState(() {
      _largura + 50.0;
      _altura = 320.0;
    });
  }

  atualizar(){
    setState(() => vs = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(title: const Center(child: Text('SquareCloud'))),
        body: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(microseconds: 500),
                    width: _largura,
                    height: _altura,
                    child: Image.asset('assets/images/logo.webp'),
                  )
                ],
              ),
              Visibility(
                visible: vs,
                child: Row(
                  children: [],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
