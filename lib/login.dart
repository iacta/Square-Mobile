import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:square/themes/themes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'modules/functions/api/api.dart';
import 'modules/functions/language/lang.dart';
import 'modules/views/routes/routes.dart';

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
  final pages = [const Page1(), const PageLogin()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: Routes.navigatorKey,
        routes: Routes.list,
        debugShowCheckedModeBanner: false,
        theme: defaultTheme,
        home: Scaffold(
            appBar: AppBar(
                actions: const [LanguageSwitcher()],
                /*centerTitle: true,
                title: Image.asset('assets/images/logo.webp',
                    height: 80, fit: BoxFit.cover), */
                backgroundColor: const Color.fromARGB(255, 11, 15, 19)),
            backgroundColor: const Color.fromARGB(255, 11, 14, 19),
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
                color: const Color.fromARGB(255, 11, 14, 19),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _launchUrl(
                            'https://discord.com/invite/squarecloud'),
                        icon: SvgPicture.asset('assets/images/discord.svg'),
                      ),
                      IconButton(
                        onPressed: () => _launchUrl(
                            'https://www.instagram.com/squarecloudofc/'),
                        icon: SvgPicture.asset('assets/images/instagram.svg'),
                      ),
                      IconButton(
                        onPressed: () =>
                            _launchUrl('https://twitter.com/squarecloudofc/'),
                        icon: SvgPicture.asset('assets/images/twitter.svg'),
                      ),
                    ],
                  ),
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
            Text(translate(context.locale.toString(), 'page1', 'welcome'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text.rich(TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: translate(context.locale.toString(), 'page1',
                            'officialAppOf'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    /* TextSpan(
                        text: translate(
                            context.locale.toString(), 'page1', 'squareCloud'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 129, 64, 251))), */
                    TextSpan(
                        text: translate(context.locale.toString(), 'page1',
                            'officialOfThe'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ])),
                  const Center(
                      child: Text.rich(
                    TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: 'Square',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromARGB(255, 78, 65, 255))),
                      TextSpan(
                          text: 'Cloud',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Color.fromARGB(255, 74, 34, 255)))
                    ]),
                  ))
                ],
              ),
            ),
          ],
        ),
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
        const ClipOval(child: Icon(Icons.key)),
        const SizedBox(height: 50),
        Center(
          child: Text.rich(TextSpan(children: <TextSpan>[
            TextSpan(
                text:
                    translate(context.locale.toString(), 'page2', 'firstLogin'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextSpan(
                text: translate(
                    context.locale.toString(), 'page2', 'obtainKeyInMyAccount'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 204, 129, 17)))
          ])),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          /* Text(
              translate(
                  context.locale.toString(), 'page2', 'youCanGetItInThe'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )), */
          GestureDetector(
            onTap: () => _launchUrl('https://squarecloud.app/dashboard/me'),
            child: Text(
              translate(context.locale.toString(), 'page2', 'account'),
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                  color: Color.fromARGB(255, 103, 138, 255)),
            ),
          )
        ]),
        const SizedBox(
          height: 80,
        ),
      ],
    );
  }
}

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final control_ = TextEditingController();

  @override
  void dispose() {
    control_.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Text(
              translate(
                  context.locale.toString(), 'pageLogin', 'connectWithApiKey'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 5,),
            Text(
              translate(context.locale.toString(), 'pageLogin',
                  'acquireKeyInMyAccount'),
              style: const TextStyle(fontSize: 16, color: Colors.grey,), textAlign: TextAlign.center,
            ),
          ])),
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
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 60, 9, 241),
                            width: 2), //<-- SEE HERE
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 60, 9, 241),
                              width: 2)),
                      hintText: translate(context.locale.toString(),
                          'pageLogin', 'insertApiKey'),
                    ),
                  )))),
      const SizedBox(
        height: 5,
      ),
      showBox(context),
    ]);
  }

  Widget showBox(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(bottons),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.only(right: 100, left: 100)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          )),
        ),
        onPressed: () async {
          await login(control_.text, context);
          Navigator.pushReplacementNamed(context, '/home');
        },
        child: Text(
          translate(context.locale.toString(), 'pageLogin', 'logIn'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }
}
