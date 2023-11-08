import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/views/routes/main_page/apps/dash.dart';

import 'package:square/modules/views/routes/main_page/homescreen.dart';

var text1 = '';
var imageUrl = '';

class App {
  final String id;
  final String tag;
  final int ram;
  final String lang;
  final String type;
  final bool isWebsite;
  final String avatar;

  App({
    required this.id,
    required this.tag,
    required this.ram,
    required this.lang,
    required this.type,
    required this.isWebsite,
    required this.avatar,
  });
  factory App.fromMap(String id, Map<String, dynamic> data) {
    return App(
      id: data['id'] ?? '',
      tag: data['tag'] ?? '',
      ram: data['ram'] ?? 0,
      lang: data['lang'] ?? '',
      type: data['type'] ?? '',
      isWebsite: data['isWebsite'] ?? false,
      avatar: data['avatar'] ?? '',
    );
  }
}

class BotListScreen extends StatefulWidget {
  const BotListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BotListScreenState createState() => _BotListScreenState();
}

class _BotListScreenState extends State<BotListScreen> {
  String filter = 'Todos';
  String searchText = '';
  List<App> filteredApps = [];
  List<App> apps2 = [];
  late Future _statusFuture;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _statusFuture = planinfo(context);
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _statusFuture;
      });
    });
    filterApps();
  }

  void filterApps() {
    setState(() {
      final apps2 = apps.map((app) => App.fromMap(app['id'], app)).toList();

      filteredApps = apps2.where((app) {
        final nameMatches =
            app.tag.toLowerCase().contains(searchText.toLowerCase());

        if (filter == 'Todos') {
          return nameMatches;
        } else if (filter == 'Website') {
          return nameMatches && app.isWebsite == true;
        } else if (filter == 'Bot') {
          return nameMatches && app.isWebsite == false;
        }

        return false;
      }).toList();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  var s = false;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          setState(() async {
            await update(context);
            filterApps();
          });
        },
        child: ListView(
          controller: scrollController,
          children: [
            FutureBuilder(
              future: _statusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Erro: ${snapshot.error}");
                } else {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                          onHover: (value) {
                            setState(() {
                              s = value;
                            });
                          },
                          onTap: () {},
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 46, 58, 163),
                                    offset: Offset(0, -1),
                                    blurRadius: s ? 20 : 10,
                                  ),
                                  BoxShadow(
                                      color: Color.fromARGB(255, 98, 113, 255),
                                      offset: Offset(0, 1),
                                      blurRadius: s ? 20 : 10),
                                ],
                                color: inputBackgroundColor,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 40, 18, 121),
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(17)),
                              ),
                              child: Column(children: [
                                const Text(
                                  'Suas Informações',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  height: 0.1,
                                  thickness: 0.5,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'Seu Plano',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Text(
                                          data['plan']!.toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 173, 172, 172)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          'Expira em',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Text(
                                          formattedDuration,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 173, 172, 172)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          'Uso de RAM',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Text(
                                          '${data['used']!}MB / ${data['available']!}MB',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 173, 172, 172)),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ])))
                    ],
                  );
                }
              },
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar...',
                  suffixIcon: const Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 60, 9, 241),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 60, 9, 241),
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (text) {
                  searchText = text;
                  filterApps();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterButton(
                  text: 'Todos',
                  activeFilter: filter,
                  onPressed: () {
                    setState(() {
                      filter = 'Todos';
                      filterApps();
                    });
                  },
                ),
                FilterButton(
                  text: 'Website',
                  activeFilter: filter,
                  onPressed: () {
                    setState(() {
                      filter = 'Website';
                      filterApps();
                    });
                  },
                ),
                FilterButton(
                  text: 'Bot',
                  activeFilter: filter,
                  onPressed: () {
                    setState(() {
                      filter = 'Bot';
                      filterApps();
                    });
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];

                return FutureBuilder<dynamic>(
                  future: stats(app.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // You can return a loading indicator or placeholder here if needed.
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Handle the error if the future call fails.
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final status = snapshot.data;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            text1 = app.tag;
                            imageUrl = app.avatar;
                          });
                          print(app.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SheetConfigApps(
                                id: app.id,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.all(8),
                          child: Container(
                            color: const Color(0xFF12171F),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(app.avatar),
                                    ),
                                    title: Text(app.tag),
                                    subtitle: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: inputBackgroundColor,
                                                border: Border.all(
                                                  color: fieldBackgroundColor,
                                                  width: 0.8,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.all(5),
                                              child: Text("${app.ram} MB"),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: inputBackgroundColor,
                                                border: Border.all(
                                                  color: inputBackgroundColor,
                                                  width: 0.8,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.all(5),
                                              child: Text(app.lang),
                                            ),
                                            Container(
                                              width: 15,
                                              height: 15,
                                              margin: EdgeInsets.only(
                                                bottom: 10.0,
                                                left: app.lang == 'static'
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.26
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.2,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: status == true
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16)
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            )
          ],
        ));
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final String activeFilter;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.text,
    required this.activeFilter,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            text == activeFilter ? const Color.fromARGB(255, 49, 49, 51) : null,
      ),
      child: Text(text),
    );
  }
}
