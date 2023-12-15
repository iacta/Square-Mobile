// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:square/modules/views/routes/main_page/myapps.dart';
import 'config.dart';

List<String> app = <String>['Gerenciar um App'];
List<String> id = <String>[];
double vs2 = 1.0;
int _indiceAtual = 0;
final List<Widget> _telas = [
  const Main(),
  const Config(),
  const BotListScreen(),
];
Color backgroundColor = const Color(0xFF0B0E13);
Color fieldBackgroundColor = const Color(0xFF12171F);
Color inputBackgroundColor = const Color(0xFF151B24);
Color bottons = const Color.fromARGB(255, 35, 49, 97);

var avatar = {};
var infoapp = {};
final ScrollController scrollController = ScrollController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    account(context);
  }

  void _onScroll() {
    final newOpacity = 1.0 - (scrollController.offset / 300.0);

    setState(() {
      // Atualize a opacidade do botão
      vs2 = newOpacity.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color.fromARGB(255, 11, 14, 19),
          appBar: AppBar(
              toolbarHeight: 90,
              centerTitle: true,
              title: Image.asset('assets/images/logo.webp',
                  height: 80, fit: BoxFit.cover),
              backgroundColor: const Color(0xFF12171F)),
          body: _telas[_indiceAtual],
          floatingActionButton: _indiceAtual == 2
              ? AnimatedOpacity(
                  opacity: vs2,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0, right: 0.0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.pushNamed(
                            context,
                            '/upload');
                      },
                      icon: const Icon(Icons.cloud_upload_outlined,
                          color: Colors.white),
                      label: const Text(
                        'Adicionar nova aplicação',
                      ),
                      backgroundColor: const Color.fromARGB(255, 44, 83, 211),
                    ),
                  ))
              : null,
          persistentFooterButtons: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () =>
                      _launchUrl('https://discord.com/invite/squarecloud'),
                  icon: const ImageIcon(
                    AssetImage('assets/images/discord.png'),
                    color: Color(0xFF2563EB),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _launchUrl('https://github.com/squarecloudofc'),
                  icon: const ImageIcon(
                    AssetImage('assets/images/github.png'),
                    color: Color(0xFF2563EB),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _launchUrl('https://www.instagram.com/squarecloudofc/'),
                  icon: const ImageIcon(
                    AssetImage('assets/images/instagram.png'),
                    color: Color(0xFF2563EB),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _launchUrl('https://twitter.com/squarecloudofc/'),
                  icon: const ImageIcon(
                    AssetImage('assets/images/twitter.png'),
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            BottomNavigationBar(
              fixedColor: const Color.fromARGB(255, 0, 81, 255),
              backgroundColor: fieldBackgroundColor,
              currentIndex: _indiceAtual,
              onTap: onTabTapped,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Minha conta'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.token), label: 'Meus Apps'),
              ],
            ),
          ],
        );
  }

  Future<void> onTabTapped(int index) async {
    setState(() {
      _indiceAtual = index;
    });
  }
}

Future<void> _launchUrl(String s) async {
  if (!await launchUrl(s as Uri)) {
    throw 'Could not launch $s';
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

_MainState state = _MainState();

class _MainState extends State<Main> {
  var test = '...';
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: account(context), // Chame a função assíncrona diretamente aqui
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || data['name'] == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Erro: ${snapshot.error}");
          } else {
            return Column(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Olá, ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                            TextSpan(
                              text: data['name'] ?? '...',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                            const TextSpan(
                              text: ' 👋.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 200,
                ),
                Center(
                  child: SizedBox(
                    width: 270,
                    child: ElevatedButton(
                      onPressed: () => _launchUrl(''),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          bottons.withOpacity(0.5),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(Icons.touch_app),
                            Text('Link para status da Square'),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        });
  }
}

class DropDown_ extends StatefulWidget {
  const DropDown_({super.key});

  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown_> {
  String _selectedOption =
      'Opção 1'; // Inicialize com uma das opções existentes.

  final List<String> _options = [
    'Opção 1',
    'Opção 2',
    'Opção 3',
    'Outra Opção', // Esta será a opção que permite a digitação.
  ];

  final TextEditingController _customOptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDropdownWithCustomInput(),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Enviar'),
        ),
      ],
    );
  }

  Widget _buildDropdownWithCustomInput() {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value!;
            });
          },
          items: _options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option), // Exibe o rótulo do item
            );
          }).toList(),
        ),
        if (_selectedOption == 'Outra Opção')
          TextFormField(
            controller: _customOptionController,
            decoration: const InputDecoration(
              labelText: 'Digite sua opção personalizada',
            ),
          ),
      ],
    );
  }
}

