import 'package:flutter/material.dart';

import 'home.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

var info =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
var info2 = "Salve favela tmj";

class _NewsState extends State<News> {
  var filter = 'news';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: bgBlack900,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 2,
              color: borderBlack700,
            )),
        width: 400,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
              padding: EdgeInsets.all(10),
              child: Text('🔔 - Alertas',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          const Divider(
            indent: 2,
            thickness: 0.4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterButton(
                text: '📢 Announcements',
                activeFilter: filter,
                onPressed: () {
                  setState(() {
                    filter = 'news';
                  });
                },
              ),
              FilterButton(
                text: '📰 ChangeLog',
                activeFilter: filter,
                onPressed: () {
                  setState(() {
                    filter = 'update';
                  });
                },
              ),
            ],
          ),
          GestureDetector(
              onTap: () {},
              child: (() {
                if (filter == 'news') {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(top: 8, left: 5, right: 5),
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: bgBlack900,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: borderBlack700,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Joao Otavio'),
                          subtitle: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  info,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (filter == 'update') {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(top: 8, left: 5, right: 5),
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: bgBlack900,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: borderBlack700,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('iacta'),
                          subtitle: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  info2,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              })()),
          const SizedBox(
            height: 10,
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
