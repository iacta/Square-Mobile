import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

class Network extends StatefulWidget {
  final String? appid;
  const Network({super.key, this.appid});

  @override
  State<Network> createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  final TextEditingController _control = TextEditingController();
  late Future<dynamic> dataFuture;
  late Timer timer;
  var visible = false;
  var webhook = '';
  @override
  void initState() {
    super.initState();
    dataFuture = network(widget.appid);
    timer =
        Timer.periodic(const Duration(minutes: 1), (Timer t) => reloadFuture());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> reloadFuture() async {
    setState(() {
      dataFuture = network(widget.appid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 10),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(20),
        width: 370,
        decoration: BoxDecoration(
          color: inputBackgroundColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                translate(context.locale.toString(), 'network', 'networkTitle'),
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                translate(
                    context.locale.toString(), 'network', 'networkSubtitle'),
                style: const TextStyle(fontSize: 20),
              ),
            ])
          ],
        ),
      ),
      Visibility(
          visible: visible,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(20),
                  width: 370,
                  decoration: BoxDecoration(
                      color: inputBackgroundColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.green)),
                  child: Column(children: [
                    Text(
                      translate(context.locale.toString(), 'network',
                          'networkSucess'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      webhook,
                      style: const TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(
                            PhosphorIconsBold.clipboardText,
                            size: 30,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: webhook));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(translate(context.locale.toString(),
                                  'config', 'copyToClipboard')),
                            ));
                          },
                        ))
                  ])),
              const SizedBox(
                height: 15,
              )
            ],
          )),
      const SizedBox(height: 15),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(20),
        width: 370,
        decoration: BoxDecoration(
          color: inputBackgroundColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Webhooks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text.rich(TextSpan(children: <TextSpan>[
              TextSpan(
                text: translate(context.locale.toString(), 'network',
                    'webhooksDescription'),
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const TextSpan(
                  text: " GitHub",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              TextSpan(
                  text: translate(
                      context.locale.toString(), 'network', 'webhooks2'),
                  style: const TextStyle(color: Colors.grey, fontSize: 15))
            ])),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 240,
                  height: 70,
                  child: TextField(
                    controller: _control,
                    decoration: InputDecoration(
                      labelText: translate(context.locale.toString(), 'network',
                          'insertAccessToken'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    try {
                      final request = await networkCreate(
                          _control.text, widget.appid, context);

                      if (request['sucess']) {
                        setState(() {
                          visible = true;
                          webhook = request['response'];
                        });
                        Future.delayed(const Duration(seconds: 20), () {
                          setState(() {
                            visible = false;
                          });
                        });
                      }
                    } catch (e) {
                      log(data['name'], 'fatal', 'Erro ao criar network: $e');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return const Color.fromARGB(255, 73, 55, 241);
                      },
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  child: Text(translate(
                      context.locale.toString(), 'network', 'saveButton')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              translate(context.locale.toString(), 'network',
                  'removeIntegrationDescription'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    ]);
  }
}
