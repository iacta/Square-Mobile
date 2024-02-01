import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

class Deploy extends StatefulWidget {
  final String? appid;
  const Deploy({super.key, this.appid});

  @override
  State<Deploy> createState() => _DeployState();
}

class _DeployState extends State<Deploy> {
  final TextEditingController _control = TextEditingController();
  late Future<dynamic> dataFuture;
  late Timer timer;
  var visible = false;
  var webhook = '';
  @override
  void initState() {
    super.initState();
    dataFuture = deploys(widget.appid);
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
      dataFuture = deploys(widget.appid);
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
            Text(
              translate(context.locale.toString(), 'deploy', 'deployTitle'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              translate(context.locale.toString(), 'deploy', 'deploySubtitle'),
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
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
                      translate(
                          context.locale.toString(), 'deploy', 'deploySucess'),
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
                text: translate(
                    context.locale.toString(), 'deploy', 'webhooksDescription'),
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
                      context.locale.toString(), 'deploy', 'webhooks2'),
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
                      labelText: translate(context.locale.toString(), 'deploy',
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
                      final request = await deployCreate(
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
                      log(data['name'], 'fatal', 'Erro ao criar deploy: $e');
                    }
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: 20), // Ajuste conforme necessário
                    ),
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
                      context.locale.toString(), 'deploy', 'saveButton')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              translate(context.locale.toString(), 'deploy',
                  'removeIntegrationDescription'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      buildDataContainer(),
    ]);
  }

  Widget buildDataContainer() {
    return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(20),
        width: 370,
        decoration: BoxDecoration(
          color: inputBackgroundColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: FutureBuilder(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar os dados'));
            } else if (!snapshot.hasData || snapshot.data.isEmpty) {
              return SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      translate(
                        context.locale.toString(),
                        'deploy',
                        'noDeploysCaptured',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              List<Map<String, dynamic>> items =
                  snapshot.data as List<Map<String, dynamic>>;

              return buildListItem(items);
            }
          },
        ));
  }

  Widget buildListItem(List<Map<String, dynamic>> stepList) {
    // Agrupa os deploys pelo ID
    Map<String, List<String>> statusesById = {};

    final deployDataList = stepList;

    for (var deployData in deployDataList) {
      final deployId = deployData['id'];
      final deployStatus = deployData['status'];
      final deployTime = deployData['date'];

      statusesById.putIfAbsent(deployId, () => []);
      statusesById[deployId]!.add('[$deployTime]: $deployStatus');
    }

    return Column(
      children: statusesById.entries.map((entry) {
        final deployId = entry.key;
        final statuses = entry.value;
        bool hasError = statuses.any((status) => status.contains('error'));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Row(children: [
              hasError
                  ? const Icon(PhosphorIconsBold.warningCircle,
                      color: Colors.red)
                  : const Icon(PhosphorIconsBold.checkCircle,
                      color: Colors.green),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                  child: Text(
                'Deploy $deployId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            ]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: statuses
                  .map((status) => Text(
                        status,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
