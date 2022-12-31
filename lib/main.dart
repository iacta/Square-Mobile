import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/main_page/home.dart';
import './login.dart';

Future<void> main() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('key')) {
    runApp(const HomeApp());
  } else {
    runApp(const Login());
  }
}
