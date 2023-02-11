import 'package:flutter/material.dart';
import 'package:hidable/hidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square/functions/api.dart';
import '../../home/apps.dart';
import '../../home/config.dart';
import '../../home/status.dart';

List<String> app = <String>['Gerenciar um App'];
List<String> id = <String>[];

var avatar = {};
var infoapp = {};
final ScrollController scrollController = ScrollController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    update(context);
  }

  int _indiceAtual = 0;
  final List<Widget> _telas = [
    const Status(),
    const Config(),
    const Apps(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color.fromARGB(255, 18, 26, 43),
        appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/images/logo.webp',
                height: 80, fit: BoxFit.cover),
            backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
        body: _telas[_indiceAtual],
        bottomNavigationBar: Hidable(
            controller: scrollController,
            wOpacity: true, // As default it's true.
            child: BottomNavigationBar(
              fixedColor: const Color.fromARGB(255, 0, 81, 255),
              backgroundColor: const Color.fromARGB(255, 15, 23, 42),
              currentIndex: _indiceAtual,
              onTap: onTabTapped,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Minha conta'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.token), label: 'Meus Apps'),
              ],
            )));
  }

  Future<void> onTabTapped(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _indiceAtual = index;
      if (index == 2) {
        var appname = prefs.getStringList('app-name');
        var appid = prefs.getStringList('app-id');
        var appavatar = prefs.getStringList('app-avatar');
        app.addAll(appname as Iterable<String>);
        id.addAll(appid as Iterable<String>);
        avatar = Map.fromIterables(appid!, appavatar!);
        infoapp = Map.fromIterables(appname!, appid!);
        print(infoapp);
      } else {
        app.clear();
        infoapp.clear();
        app.add('Gerenciar um App');
      }
    });
  }
}
