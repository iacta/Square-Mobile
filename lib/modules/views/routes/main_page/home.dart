// ignore_for_file: camel_case_types, library_private_types_in_public_api, unused_import

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/notifications/plan.dart';
import 'package:square/modules/functions/database/data.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:square/modules/views/routes/apps/myapps.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'dart:developer' as developer;

import '../user/user.dart';
import 'news.dart';
import '../upload/up.dart';

OverlayEntry? overlayEntry;
final shorebirdCodePush = ShorebirdCodePush();

List<String> id = <String>[];
double vs2 = 1.0;
final List<Widget> _telas = [
  const Main(),
  const FilePickerUpload(),
  const Config(),
];
Color backgroundColor = const Color(0xFF0B0E13);
Color fieldBackgroundColor = const Color(0xFF12171F);
Color inputBackgroundColor = const Color(0xFF151B24);
Color bottons = const Color.fromARGB(255, 35, 49, 97);
Color bgBlack900 = const Color.fromRGBO(11, 14, 19, 1.0);
Color borderBlack700 = const Color.fromRGBO(21, 27, 36, 1.0);
Color bgBlue = const Color.fromARGB(255, 24, 51, 139);
var infoapp = {};
final ScrollController scrollController = ScrollController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

GlobalKey _buttonKey = GlobalKey();
int indiceAtual = 0;

class UpdateAlert extends StatelessWidget {
  const UpdateAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Atualização Disponível'),
      content: const Text(
          'Uma nova versão do aplicativo está disponível. Deseja atualizar agora?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Future.delayed(Duration.zero, () {
              developer.log('Realizando o reinício agora.');
              developer.postEvent(
                  'restart', <String, dynamic>{'reason': 'user_restart'});
            });
          },
          child: const Text('Atualizar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
          },
          child: const Text('Agora não'),
        ),
      ],
    );
  }
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime planExpire;
  late DateTime lastTime;

  late Timer timer;

  int indiceAtual = 0;
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    _tutorial(context);
    WidgetsBinding.instance.addObserver(this);
    checkUpdate();
  }

  void _onScroll() {
    final newOpacity = 1.0 - (scrollController.offset / 300.0);

    setState(() {
      vs2 = newOpacity.clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const UpdateAlert();
      },
    );
  }

  void checkUpdate() async {
    final isUpdateAvailable =
        await shorebirdCodePush.isNewPatchReadyToInstall();
    if (isUpdateAvailable) {
      showUpdateDialog(context);
    }
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
              height: 60, fit: BoxFit.cover),
          backgroundColor: const Color.fromARGB(255, 11, 15, 19),
          elevation: 1,
          actions: const [LanguageSwitcher()],
        ),
        body: _telas[indiceAtual],
        floatingActionButton: help(),
        persistentFooterButtons: [
          BottomNavigationBar(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF12171F).withOpacity(0.3),
            currentIndex: indiceAtual,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(PhosphorIconsBold.house, size: 24),
                label: translate(
                    context.locale.toString(), 'greetings', 'projects'),
              ),
              BottomNavigationBarItem(
                icon: Transform.translate(
                  offset: const Offset(0.0, 5.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 8, 76, 221),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 33, 72, 243)
                              .withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsBold.plus,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                label: ' ',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    setState(() {
                      onTabTapped(2);
                    });
                  },
                  onLongPress: () {
                    if (overlayEntry!.mounted) {
                      overlayEntry!.remove();
                    }
                    _mostrarMenuContas(context);
                  },
                  child: CircleAvatar(
                    key: _buttonKey,
                    radius: 24,
                    backgroundImage: const NetworkImage(
                      'https://i0.wp.com/cdn.squarecloud.app/avatars/0.png?ssl=1',
                    ),
                  ),
                ),
                label: translate(context.locale.toString(), 'greetings', 'you'),
              ),
            ],
          ),
        ]);
  }

  Future<void> _mostrarMenuContas(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate(context.locale.toString(), 'input',
                      'tapToSelectOrHoldForOptions'),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _adicionarConta(_scaffoldKey.currentContext!);
                  },
                  child: Text(
                    translate(context.locale.toString(), 'input', 'addAccount'),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Account>>(
                  future: AccountManager.getAllAccounts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Nenhuma conta encontrada.');
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final acccount = snapshot.data![index];
                          bool? select =
                              prefs.get('selectAccount') == acccount.name;

                          return ListTile(
                            title: Text(acccount.name),
                            leading: Container(
                              width: 64.0, // Ajuste conforme necessário
                              height: 64.0, // Ajuste conforme necessário
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: select
                                      ? Colors.green
                                      : Colors.transparent,
                                  width:
                                      2.0, // Ajuste a largura da borda conforme necessário
                                ),
                              ),
                              child: CircleAvatar(
                                  radius: 30,
                                  foregroundColor: select ? Colors.green : null,
                                  backgroundImage: const NetworkImage(
                                      'https://i0.wp.com/cdn.squarecloud.app/avatars/0.png?ssl=1')),
                            ),
                            onTap: () async {
                              data.clear();
                              await AccountManager.selectAccount(acccount.name);
                              await account(context);
                              planinfo(context);
                              filterManager.setFilter('All');
                              setState(() {
                                data['name'];
                              });
                              Navigator.pop(context);
                            },
                            onLongPress: () {
                              Navigator.pop(context);
                              _mostrarOpcoesConta(
                                  _scaffoldKey.currentContext!, acccount.name);
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isScreenActive = true;
  Future<void> _mostrarOpcoesConta(BuildContext ctx, String account) async {
    if (!_isScreenActive) return;

    showModalBottomSheet(
      context: ctx,
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title:
                  Text(translate(context.locale.toString(), 'input', 'edit')),
              onTap: () async {
                if (!_isScreenActive) {
                  return;
                }
                await _editarConta(_scaffoldKey.currentContext, account);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title:
                  Text(translate(context.locale.toString(), 'input', 'delete')),
              onTap: () async {
                if (!_isScreenActive) {
                  return;
                }
                await AccountManager.deleteAccount(account);
                Navigator.pop(ctx);
                showSnack(
                    ctx,
                    translate(
                        context.locale.toString(), 'input', 'accountDeleted'));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _adicionarConta(BuildContext? ctx) async {
    if (!_isScreenActive) return;

    final FocusNode focusNode = FocusNode();
    final TextEditingController control = TextEditingController();

    await showModalBottomSheet(
      context: ctx!,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {
            // Fechar o teclado se estiver aberto
            focusNode.unfocus();
          },
          child: SingleChildScrollView(
            reverse: true, // Inverte a ordem dos elementos no ListView
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 50.0,
                right: 50.0,
                top: 50.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translate(context.locale.toString(), 'input', 'addAccount'),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: control,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: translate(
                          context.locale.toString(), 'input', 'apiKey'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_isScreenActive) {
                        return;
                      }
                      data.clear();
                      await login(control.text, ctx);
                      await account(context);
                      planinfo(context);
                      filterManager.setFilter('All');
                      setState(() {
                        data['name'];
                      });
                      Navigator.pop(ctx);
                      showSnack(
                          ctx,
                          translate(context.locale.toString(), 'input',
                              'accountAdded'));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editarConta(BuildContext? ctx, String name) async {
    if (!_isScreenActive) return;

    final FocusNode focusNode = FocusNode();
    final TextEditingController control = TextEditingController();

    await showModalBottomSheet(
      context: ctx!,
      isScrollControlled:
          true, // Permite que o BottomSheet utilize toda a altura da tela
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {
            // Fechar o teclado se estiver aberto
            focusNode.unfocus();
          },
          child: SingleChildScrollView(
            reverse: true, // Inverte a ordem dos elementos no ListView
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 50.0,
                right: 50.0,
                top: 50.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translate(
                        context.locale.toString(), 'input', 'editAccount'),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: control,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: translate(
                          context.locale.toString(), 'input', 'enterNewKey'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_isScreenActive) {
                        return; // Verifique novamente antes de continuar
                      }
                      AccountManager.changeAccountKey(name, control.text);
                      await account(ctx);
                      if (_isScreenActive) {
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onTabTapped(int index) async {
    if (overlayEntry!.mounted) {
      overlayEntry!.remove();
    }
    setState(() {
      indiceAtual = index;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    _isScreenActive = false;
  }

  void _tutorial(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_buttonKey.currentContext == null ||
          !_buttonKey.currentContext!.findRenderObject()!.attached) {
        return; // Sair se o contexto do botão não estiver anexado
      }

      final RenderBox buttonRenderBox =
          _buttonKey.currentContext!.findRenderObject() as RenderBox;

      final overlay = Overlay.of(context);

      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: buttonRenderBox.localToGlobal(const Offset(0, -80)).dy,
            left: buttonRenderBox.localToGlobal(const Offset(0, 0)).dx +
                buttonRenderBox.size.width / 2 -
                200,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(children: [
                      Text(
                        translate(
                          context.locale.toString(),
                          'input',
                          'holdToSeeOptions',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(
                        PhosphorIconsBold.arrowBendRightDown,
                        color: Colors.white,
                        size: 30,
                      ),
                    ])
                  ],
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(overlayEntry!);

      Future.delayed(const Duration(seconds: 10), () {
        if (overlayEntry!.mounted) {
          overlayEntry!.remove();
        }
      });
    });
  }
}

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  PopupMenuItem<String> buildPopupMenuItem(String locale) {
    return PopupMenuItem<String>(
      value: locale,
      child: SvgPicture.asset(
        'assets/images/flags/$locale.svg',
        width: 24,
        height: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.toString();
    return PopupMenuButton(
      icon: SvgPicture.asset(
        'assets/images/flags/$currentLocale.svg',
        width: 24,
        height: 24,
      ),
      onSelected: (String locale) {
        context.setLocale(Locale(locale));
      },
      color: Colors.black.withOpacity(0.6),
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) => [
        if (currentLocale != 'pt') buildPopupMenuItem('pt'),
        if (currentLocale != 'en') buildPopupMenuItem('en'),
        if (currentLocale != 'es') buildPopupMenuItem('es'),
        if (currentLocale != 'zh') buildPopupMenuItem('zh'),
        if (currentLocale != 'hr') buildPopupMenuItem('hr'),
      ],
    );
  }
}

Future<void> _launchUrl(String s) async {
  if (!await launchUrl(Uri.parse(s))) {
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
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      const SizedBox(
        height: 5,
      ),
      FutureBuilder(
          future: account(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        'aerro',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Container(
                  decoration: BoxDecoration(
                      color: bgBlack900,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: borderBlack700,
                      )),
                  width: 400,
                  child: const Column(children: [
                    AppsScreen(),
                    SizedBox(
                      height: 10,
                    ),
                  ]));
            }
          }),
      const SizedBox(height: 50),
      const Footer()
    ]));
  }

  String obterPeriodoDoDia() {
    DateTime agora = DateTime.now();
    int hora = agora.hour;
    String periodoDoDia;

    if (hora >= 6 && hora < 12) {
      periodoDoDia = translate(context.locale.toString(), 'hours', '1');
    } else if (hora >= 12 && hora < 18) {
      periodoDoDia = translate(context.locale.toString(), 'hours', '2');
    } else if (hora >= 18 && hora < 24) {
      periodoDoDia = translate(context.locale.toString(), 'hours', '3');
    } else {
      periodoDoDia = translate(context.locale.toString(), 'hours', '4');
    }

    return periodoDoDia;
  }
}

class NavButtons extends StatelessWidget {
  const NavButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor:
                    const Color.fromARGB(31, 82, 81, 81).withOpacity(0.3)),
            child: const Icon(PhosphorIconsBold.gearSix),
          ),
        ]));
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate(context.locale.toString(), 'footer', 'title'),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _launchUrl(
                          'https://www.instagram.com/squarecloudofc/'),
                      icon: SvgPicture.asset(
                        'assets/images/instagram.svg',
                        width:
                            24, // Defina a largura desejada para a imagem SVG
                        height:
                            24, // Defina a altura desejada para a imagem SVG
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _launchUrl('https://twitter.com/squarecloudofc/'),
                      icon: SvgPicture.asset(
                        'assets/images/twitter.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _launchUrl('https://discord.com/invite/squarecloud'),
                      icon: SvgPicture.asset(
                        'assets/images/discord.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            translate(
                                context.locale.toString(), 'footer', 'company'),
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _launchUrl('https://squarecloud.app/about'),
                            child: Text(
                              translate(
                                  context.locale.toString(), 'footer', 'about'),
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _launchUrl('https://squarecloud.app/plans'),
                            child: Text(
                              translate(
                                  context.locale.toString(), 'footer', 'plans'),
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20), // Espaço entre as colunas
                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              translate(context.locale.toString(), 'footer',
                                  'helpCenter'),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () => _launchUrl(
                                  'https://docs.squarecloud.app/introduction'),
                              child: Text(
                                translate(context.locale.toString(), 'footer',
                                    'docs'),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _launchUrl(
                                  'https://docs.squarecloud.app/api-reference/authentication'),
                              child: Text(
                                translate(context.locale.toString(), 'footer',
                                    'apiHelp'),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      translate(context.locale.toString(), 'footer', 'legal'),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrl('https://squarecloud.app/legal'),
                      child: Text(
                        translate(context.locale.toString(), 'footer', 'terms'),
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrl(
                          'https://squarecloud.app/pt-BR/legal/policy'),
                      child: Text(
                        translate(
                            context.locale.toString(), 'footer', 'policy'),
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        translate(context.locale.toString(), 'footer', 'init'),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                          onTap: () =>
                              _launchUrl('https://status.squarecloud.app/'),
                          child: const Text(
                            'Status',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.webp',
                      width: 100,
                      height: 100,
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Square Cloud | 2021-2023\nCNPJ: 51.893.307/0001-08',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )));
  }
}

Widget help() {
  return FloatingActionButton(
    mini: false,
    backgroundColor: Colors.black.withOpacity(0.1),
    onPressed: () => _launchUrl('http://wa.me/551151949484'),
    child: Image.asset('assets/images/wpp.png', height: 160, fit: BoxFit.cover),
  );
}
