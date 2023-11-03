import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/views/routes/main_page/apps/edit/edit.dart';
import 'package:square/modules/views/routes/main_page/homescreen.dart';

class Files extends StatefulWidget {
  final String? id;
  const Files({Key? key, required this.id}) : super(key: key);

  @override
  State<Files> createState() => _FilesState();
}

class _FilesState extends State<Files> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset('assets/images/logo.webp',
            height: 80, fit: BoxFit.cover),
        backgroundColor: const Color.fromARGB(255, 15, 23, 42),
      ),
      backgroundColor: const Color.fromARGB(255, 11, 14, 19),
      body: FutureBuilder(
        future: files(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar uma única barra de progresso enquanto os itens estão sendo carregados.
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Quando os itens foram carregados, exibir a lista.
            return SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: file.length,
                itemBuilder: (context, index) {
                  return Column(children: [
                    GestureDetector(
                        onTap: () async {
                          await file_read(widget.id);
                          if (file[index]['type'] == 'directory') {
                          } else {
                            List<int> bytes = fileread.cast<int>();
                            String decodedString = utf8.decode(bytes);

                            print(decodedString);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Editing(
                                      source: decodedString,
                                      lang: file[index]['name'])),
                            );
                          }
                        },
                        child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.all(8),
                            child: Container(
                              color: const Color(0xFF12171F),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                    title: Text(file[index]["name"]),
                                    subtitle: Column(
                                      children: [
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
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child:
                                                    Text(file[index]['type']),
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
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Text(
                                                    '${file[index]['size'].toString()}KB'),
                                              )
                                            ]),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    )),
                              ),
                            )))
                  ]);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
