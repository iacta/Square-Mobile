import 'dart:async';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

var text1 = '';
var imageUrl = '';
/*  */

class BotListScreen extends StatefulWidget {
  const BotListScreen({Key? key}) : super(key: key);

  @override
  _BotListScreenState createState() => _BotListScreenState();
}

class _BotListScreenState extends State<BotListScreen> {
  String filter = 'Todos';
  bool non = false;
  String searchText = '';
  List<Map<String, dynamic>> filteredApps = [];
  Timer? timer;
  Future<void> _statusFuture = Future.value();

  @override
  void initState() {
    super.initState();
    filterApps();
    _statusFuture = planinfo(context);
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> refreshData() async {
    await account(context);
    filterApps();
  }

  void filterApps() {
    final List<Map<String, dynamic>> app =
        List<Map<String, dynamic>>.from(data['apps'] ?? []);
    if (app.isEmpty) {
      return setState(() {
        non = true;
      });
    } else {
      setState(() {
        filteredApps = app.where((appData) {
          final nameMatches = appData['tag']
                  ?.toLowerCase()
                  ?.contains(searchText.toLowerCase()) ??
              false;

          if (filter == 'Todos') {
            return nameMatches;
          } else if (filter == 'Website') {
            return nameMatches && appData['isWebsite'] == true;
          } else if (filter == 'Bot') {
            return nameMatches && appData['isWebsite'] == false;
          }

          return false;
        }).toList();
      });
    }
  }

  var s = false;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
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
                              color: const Color.fromARGB(255, 46, 58, 163),
                              offset: const Offset(0, -1),
                              blurRadius: s ? 20 : 10,
                            ),
                            BoxShadow(
                              color: const Color.fromARGB(255, 98, 113, 255),
                              offset: const Offset(0, 1),
                              blurRadius: s ? 20 : 10,
                            ),
                          ],
                          color: inputBackgroundColor,
                          border: Border.all(
                            color: const Color.fromARGB(255, 40, 18, 121),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(17)),
                        ),
                        child: Column(
                          children: [
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
                          ],
                        ),
                      ),
                    )
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
                setState(() {
                  searchText = text;
                  filterApps();
                });
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
          Visibility(
              visible: non,
              child: const Expanded(child: Center(
                  child: Column(children: [
                    SizedBox(height: 10,),
                Text("Você não tem aplicações registradas em nossa plataforma!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(
                  'Você pode adicionar uma nova aplicação utilizando o botão ao lado',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurpleAccent),
                )
              ])))),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredApps.length,
            itemBuilder: (context, index) {
              final app = filteredApps[index];
              return FutureBuilder<dynamic>(
                future: stats(app['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final status = snapshot.data;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          text1 = app['tag'];
                          imageUrl = app['avatar'];
                        });
                        Navigator.pushNamed(context, '/dash',
                            arguments: {'id': app['id']});
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
                                    backgroundImage:
                                        NetworkImage(app['avatar']),
                                  ),
                                  title: Text(app['tag']),
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
                                            child: Text("${app['ram']} MB"),
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
                                            child: Text(app['lang']),
                                          ),
                                          Container(
                                            width: 15,
                                            height: 15,
                                            margin: EdgeInsets.only(
                                              bottom: 10.0,
                                              left: app['lang'] == 'static'
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
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final String activeFilter;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.text,
    required this.activeFilter,
    required this.onPressed,
  }) : super(key: key);

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
