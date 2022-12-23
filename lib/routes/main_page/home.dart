import 'package:flutter/material.dart';
import './modules/home/homescreen.dart';

void main() => runApp(const HomeApp());


class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => HomeAppState();
}

class HomeAppState extends State<HomeApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }
}