// ignore_for_file: library_private_types_in_public_api

import 'package:any_link_preview/any_link_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main_page/home.dart';

var s = false;

var statuscode = 0, msgreturn = '';
List<String> list = <String>['Recomendada', 'Última'];

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> with TickerProviderStateMixin {
  final control = TextEditingController();
  bool vs = false;
  Future<void> _launchUrl(String s) async {
    if (!await launchUrl(Uri.parse(s))) {
      throw 'Could not launch $s';
    }
  }

  @override
  void initState() {
    super.initState();
    planinfo(context);
  }

  @override
  void dispose() {
    super.dispose();
    control.dispose();
    cancelFunction();
  }

  @override
  build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    'https://i0.wp.com/cdn.squarecloud.app/avatars/0.png?ssl=1'),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? '...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(PhosphorIconsBold.identificationCard),
                        const SizedBox(width: 5),
                        Text(
                          data['id'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Text.rich(
                        style: const TextStyle(fontSize: 17),
                        TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: translate(context.locale.toString(), 'plan',
                                  'yourEmail'),
                              style: const TextStyle(fontSize: 15)),
                          TextSpan(
                              text: data['email'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16))
                        ])),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Plan(),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20),
          width: 370,
          height: 180,
          decoration: BoxDecoration(
            color: bgBlack900.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1,
              color: borderBlack700,
            ),
          ),
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'squarecloud.app',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  translate(context.locale.toString(), 'config',
                      'generateConfigurationButton'),
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _launchUrl('https://config.squareweb.app/');
                      },
                      icon: const Icon(Icons.data_array_outlined),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            return bgBlue;
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      label: Text(translate(context.locale.toString(), 'config',
                          'generateConfigurationFile')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgBlack900.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: borderBlack700,
              ),
            ),
            child: GestureDetector(
                onTap: () => _launchUrl('https://changelog.squarecloud.app/'),
                child: AnyLinkPreview(
                  link: 'https://changelog.squarecloud.app/',
                  displayDirection: UIDirection.uiDirectionVertical,
                  cache: const Duration(hours: 1),
                  backgroundColor: bgBlack900,
                  bodyStyle: const TextStyle(
                      color: Color.fromARGB(255, 184, 184, 184)),
                  // Widget to display when there's an error fetching preview
                  errorWidget: Container(
                    color: Colors.grey[300],
                    child: const Text('Oops!'),
                  ),
                )))
      ],
    ));
  }
}

class Plan extends StatelessWidget {
  const Plan({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: planinfo(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Erro: ${snapshot.error}");
        } else {
          return Column(
            children: [
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: bgBlack900.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: borderBlack700,
                  ),
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      translate(
                          context.locale.toString(), 'plan', 'yourInformation'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 0.1,
                      thickness: 0.2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      /*  decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(10),
                              ), */
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsBold.calendarBlank,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                translate(context.locale.toString(), 'plan',
                                    'yourInformation'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data['plan']?.toUpperCase() ?? '',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 173, 172, 172),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            translate(context.locale.toString(), 'plan',
                                    'expires') +
                                formattedDuration,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 173, 172, 172),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate(context.locale.toString(), 'plan',
                                    'ramUsage'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(children: [
                                Text(
                                  '${data['used'] ?? "0"}MB / ${data['limit'] ?? "0"}MB',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 173, 172, 172),
                                  ),
                                ),
                                const Text(' •',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 173, 172, 172),
                                    )),
                                Text(
                                  ' ${data['available'] ?? "0"}MB',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.green,
                                  ),
                                ),
                              ])
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }
      },
    );
  }
}
