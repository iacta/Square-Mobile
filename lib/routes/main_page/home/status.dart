import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square/routes/main_page/modules/functions/getstatus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modules/views/homescreen.dart';

final Uri _url = Uri.parse('https://status.squarecloud.app/');

var msg = '';
var percent = {
  'WebSite\nsquarecloud.app': '',
  'Api': '',
  'florida-1': '',
  'florida-2': '',
  'florida-3': '',
  'florida-free': ''
};

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
}

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  Color c1 = const Color.fromARGB(255, 13, 183, 237);
  Color c2 = const Color.fromARGB(92, 24, 39, 241);

  late Future _statusFuture;

  @override
  void initState() {
    _statusFuture = status();
    Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {
        _statusFuture = status();
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(direction: Axis.vertical, children: [
      Flexible(
          child: RawScrollbar(
              thumbColor: const Color.fromARGB(255, 53, 7, 255),
              radius: const Radius.circular(20),
              thickness: 10,
              child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _statusFuture = status();
                    });
                    return _statusFuture;
                  },
                  child: FutureBuilder(
                    future: _statusFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            controller: scrollController,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              var key = percent.keys.elementAt(index);
                              var value = percent[key];
                              return Column(children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(
                                          shape: const RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 124, 82, 240),
                                                  width: 3),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(30),
                                                  bottomRight:
                                                      Radius.circular(30),
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                          elevation: 50,
                                          shadowColor: const Color.fromARGB(
                                              255, 60, 16, 255),
                                          color: c2,
                                          child: SizedBox(
                                              width: 300,
                                              height: 200,
                                              child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ), //SizedBox
                                                    Text(
                                                      key,
                                                      style: TextStyle(
                                                        fontSize: 30,
                                                        color: c1,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ), //Textstyle
                                                    ), //Text
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        // default text style
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: value!
                                                                      .isEmpty
                                                                  ? 'Aguarde! Estamos pegando os dados!'
                                                                  : value,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          89,
                                                                          92,
                                                                          255))),
                                                        ],
                                                      ),
                                                    ),
                                                  ])))),
                                    ]),
                              ]);
                            });
                      } else if (snapshot.hasError) {
                        return Text("Erro: ${snapshot.error}");
                      }
                      return const CircularProgressIndicator();
                    },
                  )))),
      SizedBox(
        width: 230,
        child: ElevatedButton(
          onPressed: () => _launchUrl(),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 20, 123, 241))),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Row(
              children: [
                Icon(Icons.touch_app),
                Text('Link para status completo')
              ],
            ),
          ),
        ),
      )
    ]);
  }

  Future status() async {
    await website();
    //documentation();
    await api();
    //services
    //services();
    //Clusters
    await clusters();
    setState(() {});
    return percent;
  }
}








/* Card(
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide(
                                        color:
                                            Color.fromARGB(255, 124, 82, 240),
                                        width: 3),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                elevation: 50,
                                shadowColor:
                                    const Color.fromARGB(255, 60, 16, 255),
                                color: c2,
                                child: SizedBox(
                                    width: 300,
                                    height: 200,
                                    child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(children: [
                                          const SizedBox(
                                            height: 10,
                                          ), //SizedBox
                                          Text(
                                            "Api Status",
                                            style: TextStyle(
                                              fontSize: 30,
                                              color: c1,
                                              fontWeight: FontWeight.w500,
                                            ), //Textstyle
                                          ), //Text
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              // default text style
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: percent['api'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors
                                                            .lightGreenAccent)),
                                              ],
                                            ),
                                          ),
                                        ])))),
                            Card(
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide(
                                        color:
                                            Color.fromARGB(255, 124, 82, 240),
                                        width: 3),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                elevation: 50,
                                shadowColor:
                                    const Color.fromARGB(255, 60, 16, 255),
                                color: c2,
                                child: SizedBox(
                                    width: 300,
                                    height: 200,
                                    child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(children: [
                                          const SizedBox(
                                            height: 10,
                                          ), //SizedBox
                                          Text.rich(
                                            TextSpan(
                                              // default text style
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: 'Cluster Status\n',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: c1)),
                                                const TextSpan(
                                                    text: '\tFlorida-Free',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors
                                                            .indigoAccent)),
                                              ],
                                            ),
                                          ), //Text
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              // default text style
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: percent['api'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors
                                                            .lightGreenAccent)),
                                              ],
                                            ),
                                          ),
                                        ])))), */