import 'package:flutter/material.dart';
import 'home/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('key')) {
    runApp(const HomeApp());
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => HomeAppState();
}

class HomeAppState extends State<HomeApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }
}
