import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:highlight/languages/all.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/views/routes/main_page/home.dart';

var theme = {
  'root': TextStyle(
      backgroundColor: inputBackgroundColor, color: const Color(0xfff8f8f2)),
  'tag': const TextStyle(color: Color(0xfff8f8f2)),
  'subst': const TextStyle(color: Color(0xfff8f8f2)),
  'strong': const TextStyle(color: Color(0xffa8a8a2), fontWeight: FontWeight.bold),
  'emphasis': const TextStyle(color: Color(0xffa8a8a2), fontStyle: FontStyle.italic),
  'bullet': const TextStyle(color: Color(0xffae81ff)),
  'quote': const TextStyle(color: Color(0xffae81ff)),
  'number': const TextStyle(color: Color(0xffae81ff)),
  'regexp': const TextStyle(color: Color(0xffae81ff)),
  'literal': const TextStyle(color: Color(0xffae81ff)),
  'link': const TextStyle(color: Color(0xffae81ff)),
  'code': const TextStyle(color: Color(0xffa6e22e)),
  'title': const TextStyle(color: Color(0xffa6e22e)),
  'section': const TextStyle(color: Color(0xffa6e22e)),
  'selector-class': const TextStyle(color: Color(0xffa6e22e)),
  'keyword': const TextStyle(color: Color(0xfff92672)),
  'selector-tag': const TextStyle(color: Color(0xfff92672)),
  'name': const TextStyle(color: Color(0xfff92672)),
  'attr': const TextStyle(color: Color(0xfff92672)),
  'symbol': const TextStyle(color: Color(0xff66d9ef)),
  'attribute': const TextStyle(color: Color(0xff66d9ef)),
  'params': const TextStyle(color: Color(0xfff8f8f2)),
  'string': const TextStyle(color: Color(0xffe6db74)),
  'type': const TextStyle(color: Color(0xffe6db74)),
  'built_in': const TextStyle(color: Color(0xffe6db74)),
  'builtin-name': const TextStyle(color: Color(0xffe6db74)),
  'selector-id': const TextStyle(color: Color(0xffe6db74)),
  'selector-attr': const TextStyle(color: Color(0xffe6db74)),
  'selector-pseudo': const TextStyle(color: Color(0xffe6db74)),
  'addition': const TextStyle(color: Color(0xffe6db74)),
  'variable': const TextStyle(color: Color(0xffe6db74)),
  'template-variable': const TextStyle(color: Color(0xffe6db74)),
  'comment': const TextStyle(color: Color(0xff75715e)),
  'deletion': const TextStyle(color: Color(0xff75715e)),
  'meta': const TextStyle(color: Color(0xff75715e)),
};

class Editing extends StatefulWidget {
  final String? source;
  final String? lang;
  final String? path;
  final String? appid;
  const Editing(
      {Key? key,
      required this.source,
      required this.lang,
      required this.appid,
      required this.path})
      : super(key: key);

  @override
  State<Editing> createState() => _EditingState();
}

class _EditingState extends State<Editing> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    var language = getLanguageFromFileName(widget.lang.toString());
    _codeController = CodeController(
      text: widget.source,
      language: builtinLanguages[language],
    );
  }

  // Verifique se a extensão existe no mapa e retorne a linguagem correspondent
  String getLanguageFromFileName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    // Mapeie a extensão para a linguagem correspondente
    final languageMap = {
      'dart': 'dart',
      'py': 'python',
      'js': 'javascript',
      'go': 'go',
      'ts': 'typescript'
      // Adicione outras correspondências conforme necessário
    };

    // Verifique se a extensão existe no mapa e retorne a linguagem correspondente
    return languageMap[ext] ??
        'javascript'; // 'auto' ou qualquer valor padrão desejado
  }

  @override
  void dispose() {
    super.dispose();
    _codeController?.dispose();
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
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
              margin: const EdgeInsets.all(4),
              width: 300,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return bottons;
                      // Cor padrão do botão azul
                    })),
                onPressed: () async {
                  //await file_delete(widget.appid, widget.path);
                  await file_create(widget.appid, _codeController!.text, context,
                      widget.path);
                },
                child: const Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white),
                ),
              )),
          CodeTheme(
            data: CodeThemeData(styles: theme),
            child: SizedBox(
                width: 400,
                child: CodeField(
                    controller: _codeController!,
                    textStyle: const TextStyle(fontFamily: 'SourceCode'))),
          )
        ])));
  }
}
