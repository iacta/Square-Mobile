import 'package:flutter/material.dart';
import './navigation.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _indiceAtual = 0;
  final List<Widget> _telas = [
    const Home(),
    const NewPageScreen("Minha conta"),
    const NewPageScreen("Meus pedidos")  
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Minha conta'),
          BottomNavigationBarItem(
            icon: Icon(Icons.token), label: 'Meus Apps'),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }
}

class NewPageScreen extends StatelessWidget {
  final String texto;

  const NewPageScreen(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(texto),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Nv()
      ],
    );
  }
}
