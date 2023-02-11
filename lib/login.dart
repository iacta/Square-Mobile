import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'functions/api.dart';
import 'routes/main_page/home.dart';

final pageController = PageController(initialPage: 0);
bool handler = false;
Future<void> _launchUrl(String url) async {
  final Uri urlparse = Uri.parse(url);
  if (!await launchUrl(urlparse)) {
    throw 'Could not launch $url';
  }
}

void main() => runApp(const Login());

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final pages = [const Page1(), const Page2(), const PageLogin()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
            appBar: AppBar(
                /*centerTitle: true,
                title: Image.asset('assets/images/logo.webp',
                    height: 80, fit: BoxFit.cover), */
                backgroundColor: const Color.fromARGB(255, 15, 23, 42)),
            backgroundColor: const Color.fromARGB(255, 18, 26, 43),
            floatingActionButton: Stack(children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceIn);
                },
                backgroundColor: Colors.transparent,
                hoverElevation: 50,
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              )
            ]),
            bottomNavigationBar: Container(
                height: 100.0,
                color: const Color.fromARGB(255, 19, 27, 44),
                child: Column(children: [
                  /* const Expanded(
                    child: Divider(
                  color: Colors.white,
                  height: 150,
                )),
                const Text(
                  '© 2021-2023 Square Cloud. Todos os direitos reservados.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
                const Text('[beta - v0.1]',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic)), */

                  SmoothPageIndicator(
                      controller: pageController, // PageController
                      count: pages.length,
                      effect: const WormEffect(
                        dotHeight: 12,
                        dotWidth: 12,
                        type: WormType.thin,
                        activeDotColor: Colors.blueAccent,
                      ),
                      onDotClicked: (index) {
                        pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.bounceIn);
                      }),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        onPressed: () => _launchUrl(
                            'https://discord.com/invite/squarecloud'),
                        icon: const ImageIcon(
                          AssetImage('assets/images/discord.png'), //discord
                          color: Color.fromARGB(255, 75, 42, 221),
                        )),
                    IconButton(
                        onPressed: () =>
                            _launchUrl('https://github.com/squarecloudofc'),
                        icon: const ImageIcon(
                          AssetImage('assets/images/github.png'), // git
                        )),
                    IconButton(
                        onPressed: () => _launchUrl(
                            'https://www.instagram.com/squarecloudofc/'),
                        icon: const ImageIcon(
                          AssetImage('assets/images/instagram.png'), //insta
                          color: Color.fromARGB(255, 219, 18, 152),
                        )),
                    IconButton(
                        onPressed: () =>
                            _launchUrl('https://twitter.com/squarecloudofc/'),
                        icon: const ImageIcon(
                          AssetImage('assets/images/twitter.png'), //twitter
                          color: Color.fromARGB(255, 4, 205, 255),
                        ))
                  ])
                ])),
            body: Stack(children: [
              PageView.builder(
                  controller: pageController,
                  itemBuilder: (_, index) {
                    return pages[index % pages.length];
                  }),
            ])));
  }
}

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Image.asset('assets/images/squarecloud.gif',
                height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            const Text('Seja bem vindo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            const SizedBox(height: 10),
            const Center(
                child: Column(children: [
              Text.rich(TextSpan(children: <TextSpan>[
                TextSpan(
                    text: 'este é o ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                TextSpan(
                    text: 'APP ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 129, 64, 251))),
                TextSpan(
                    text: 'oficial da ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                TextSpan(
                    text: 'Square',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 78, 65, 255))),
                TextSpan(
                    text: 'Cloud',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 74, 34, 255)))
              ]))
            ])),
          ],
        ),
        Column(children: [
          const SizedBox(
            height: 50,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/help2.png',
                height: 50, color: Colors.white),
            Image.asset(
              'assets/images/help1.png',
              height: 50,
              color: Colors.white,
            )
          ]),
          const SizedBox(height: 20),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Use os botões ou Arraste para continuar',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 217, 255)))
          ])
        ])
      ],
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
            child: Container(
          width: 200,
          color: const Color.fromARGB(255, 77, 76, 76),
          child: Image.asset('assets/images/key.png'),
        )),
        const SizedBox(height: 50),
        const Center(
            child: Text.rich(TextSpan(children: <TextSpan>[
          TextSpan(
              text: 'Realize seu primeiro login com sua ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextSpan(
              text: 'APIKey.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.yellowAccent))
        ]))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Você pode obte-la na aba ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
          GestureDetector(
            onTap: () => _launchUrl('https://squarecloud.app/dashboard/me'),
            child: const Text(
              'minha conta',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  color: Colors.blue),
            ),
          )
        ]),
        const SizedBox(
          height: 80,
        ),
        Center(
            child: RichText(
                text: const TextSpan(
          children: <TextSpan>[
            TextSpan(
                text:
                    'Dica: Continue a rolagem de telas pelos botões ou arrastando!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            TextSpan(
              text: '🤩', // emoji characters
              style: TextStyle(
                  fontFamily: 'EmojiOne',
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ],
        ))),
      ],
    );
  }
}

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}
final control_ = TextEditingController();
class _PageLoginState extends State<PageLogin> {
  
  @override
  void dispose() {
    control_.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          alignment: AlignmentDirectional.center,
          child: SizedBox(
              width: 400,
              child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: Theme.of(context)
                        .inputDecorationTheme
                        .copyWith(iconColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                      if (states.contains(MaterialState.focused)) {
                        return const Color.fromARGB(255, 0, 174, 255);
                      }
                      if (states.contains(MaterialState.error)) {
                        return Colors.deepOrange;
                      }
                      return const Color.fromARGB(255, 196, 227, 231);
                    })),
                  ),
                  child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: control_,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        label: const Text(
                          'Insira sua APIKey',
                          style: TextStyle(color: Colors.white),
                        ),
                        prefixIcon: const Icon(Icons.key,
                            color: Color.fromARGB(255, 37, 0, 250)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                                width: 3,
                                color: Color.fromARGB(255, 0, 153, 255))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                                width: 3,
                                color: Color.fromARGB(255, 2, 69, 255))),
                      ))))),
      const SizedBox(
        height: 20,
      ),
      const Showbox(),
    ]);
  }
}

class Showbox extends StatelessWidget {
  
  const Showbox({super.key, });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(255, 2, 196, 255)),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.only(right: 100, left: 100)),
        ),
        onPressed: () async {
          var encoder = utf8.encoder;
          var crypt = encoder.convert(control_.text);
          await login(crypt, context);
          if (onerr == false) {
            account();
            //status();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeApp(),
                ));
          }
          //print(data['response']['user']['id']);
        },
        child: const Text(
          'Logar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }
}
