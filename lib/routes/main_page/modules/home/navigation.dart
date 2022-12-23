import 'package:flutter/material.dart';

class Nv extends StatefulWidget {
  const Nv({super.key});

  @override
  State<Nv> createState() => NvState();
}

class NvState extends State<Nv> {
  int indice = 0;
  final List<Widget> _tl = [const News(), const Update(), const Status()];
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[ 
      BottomNavigationBar(
        currentIndex: indice,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(
            icon: Icon(Icons.backup), label: "Update's"),
          BottomNavigationBarItem(
              icon: Icon(Icons.troubleshoot), label: 'Status'),
      ]),
      _tl[indice]

    ]);
  }

  void onTabTapped(int index) {
    setState(() {
      indice = index;      
    });
  }
}

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    return const Text('News');
  }
}

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    return const Text('Status');
  }
}

class Update extends StatelessWidget {
  const Update({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('a'),
    );
  }
}
