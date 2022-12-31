import 'package:flutter/material.dart';
import './navigation.dart';
import './apps.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _indiceAtual = 0;
  final List<Widget> _telas = [
    const Nv(),
    const Config(),
    const Apps(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _telas[_indiceAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Minha conta'),
          BottomNavigationBarItem(icon: Icon(Icons.token), label: 'Meus Apps'),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _indiceAtual = index;
      if (index == 2) {
        getApps();
      } else {
        list.clear();
        list.add('Gerenciar um App');
      }
    });
  }
}

class Config extends StatelessWidget {
  const Config({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
