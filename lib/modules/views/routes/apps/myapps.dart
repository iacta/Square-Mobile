import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

var text1 = '';
var imageUrl = '';

class FilterManager {
  late String _filter;
  late Function(String) _filterCallback;

  String get filter => _filter;

  set filterCallback(Function(String) callback) {
    _filterCallback = callback;
  }

  void setFilter(String newFilter) {
    _filter = newFilter;
    _filterCallback(newFilter);
  }
}

final filterManager = FilterManager();

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

bool error = false;
List<Map<String, dynamic>> filteredApps = [];

class _AppsScreenState extends State<AppsScreen> {
  bool non = false;
  String filter = 'All';

  String searchText = '';
  Timer? timer;
  void filterApps() {
    final List<Map<String, dynamic>> app =
        List<Map<String, dynamic>>.from(data['apps'] ?? []);
    if (app.isEmpty) {
      setState(() {
        non = true;
      });
    }

    setState(() {
      non = false;
      filteredApps = app.where((appData) {
        final nameMatches =
            appData['tag']?.toLowerCase()?.contains(searchText.toLowerCase()) ??
                false;

        if (filter == 'All') {
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

  @override
  void initState() {
    super.initState();
    filterManager.filterCallback = (newFilter) {
      setState(() {
        filter = newFilter;
        filterApps();
      });
    };
    filterManager.setFilter('All');
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> refreshData() async {
    setState(() {
      account(context);
      filterApps();
      planinfo(context);
    });
  }

  var s = false;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: refreshData,
        child: Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                  translate(context.locale.toString(), 'greetings', 'projects'),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)))),
          const Divider(
            thickness: 0.5,
          ),
          const SizedBox(
            height: 15,
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(1.0),
                width: 380,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: backgroundColor,
                    labelText: translate(
                      context.locale.toString(),
                      'greetings',
                      'search',
                    ),
                    suffixIcon: const Icon(PhosphorIconsBold.magnifyingGlass),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 70, 70, 70),
                        width: 0.1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 70, 70, 70),
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
                  const Text(
                    'Filter by ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FilterButton(
                    text: 'All',
                    activeFilter: filter,
                    onPressed: () {
                      setState(() {
                        filter = 'All';
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            translate(context.locale.toString(), 'messages',
                                'noApplications'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            translate(context.locale.toString(), 'messages',
                                'addNewApplication'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          Text(
                            translate(context.locale.toString(), 'messages',
                                'messageErro'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
              Visibility(
                visible:
                    error, // A mensagem de erro será visível apenas se erroGenerico for true
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          translate(context.locale.toString(), 'messages',
                              'genericError'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          translate(context.locale.toString(), 'messages',
                              'genericError2'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic>? app = filteredApps[index];
                  return FutureBuilder<dynamic>(
                    future: stats(app['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (data['apps'] == null) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  translate(context.locale.toString(),
                                      'messages', 'noApplications'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  translate(context.locale.toString(),
                                      'messages', 'addNewApplication'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                                Text(
                                  translate(context.locale.toString(),
                                      'messages', 'messageErro'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (app.containsValue(null) ||
                          snapshot.hasError ||
                          !snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  translate(context.locale.toString(),
                                      'messages', 'genericError'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  translate(context.locale.toString(),
                                      'messages', 'genericError2'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final status = snapshot.data;
                        return GestureDetector(
                          onTap: () {
                            if (overlayEntry!.mounted) {
                              overlayEntry!.remove();
                            }
                            setState(() {
                              text1 = app['tag'];
                            });
                            Navigator.pushNamed(context, '/dash',
                                arguments: {'id': app['id']});
                          },
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(
                                top: 8, left: 5, right: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: bgBlack900,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: borderBlack700,
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(app['tag']),
                                      subtitle: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: CircleAvatar(
                                                  radius: 6,
                                                  backgroundColor:
                                                      status == true
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: bgBlack900,
                                                  border: Border.all(
                                                    color: borderBlack700,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Text("${app['ram']} MB"),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: bgBlack900,
                                                  border: Border.all(
                                                    color: borderBlack700,
                                                    width: 0.8,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Text(app['lang']),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
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
          )
        ]));
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
            text == activeFilter ? const Color.fromARGB(120, 49, 49, 51) : null,
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      ),
    );
  }
}
