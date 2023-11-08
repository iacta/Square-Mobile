import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/foundation.dart';
// Import the language & theme
import 'package:highlight/languages/all.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/api.dart';
import 'package:square/modules/views/routes/main_page/homescreen.dart';

var theme = {
  'root': TextStyle(
      backgroundColor: inputBackgroundColor, color: Color(0xfff8f8f2)),
  'tag': TextStyle(color: Color(0xfff8f8f2)),
  'subst': TextStyle(color: Color(0xfff8f8f2)),
  'strong': TextStyle(color: Color(0xffa8a8a2), fontWeight: FontWeight.bold),
  'emphasis': TextStyle(color: Color(0xffa8a8a2), fontStyle: FontStyle.italic),
  'bullet': TextStyle(color: Color(0xffae81ff)),
  'quote': TextStyle(color: Color(0xffae81ff)),
  'number': TextStyle(color: Color(0xffae81ff)),
  'regexp': TextStyle(color: Color(0xffae81ff)),
  'literal': TextStyle(color: Color(0xffae81ff)),
  'link': TextStyle(color: Color(0xffae81ff)),
  'code': TextStyle(color: Color(0xffa6e22e)),
  'title': TextStyle(color: Color(0xffa6e22e)),
  'section': TextStyle(color: Color(0xffa6e22e)),
  'selector-class': TextStyle(color: Color(0xffa6e22e)),
  'keyword': TextStyle(color: Color(0xfff92672)),
  'selector-tag': TextStyle(color: Color(0xfff92672)),
  'name': TextStyle(color: Color(0xfff92672)),
  'attr': TextStyle(color: Color(0xfff92672)),
  'symbol': TextStyle(color: Color(0xff66d9ef)),
  'attribute': TextStyle(color: Color(0xff66d9ef)),
  'params': TextStyle(color: Color(0xfff8f8f2)),
  'string': TextStyle(color: Color(0xffe6db74)),
  'type': TextStyle(color: Color(0xffe6db74)),
  'built_in': TextStyle(color: Color(0xffe6db74)),
  'builtin-name': TextStyle(color: Color(0xffe6db74)),
  'selector-id': TextStyle(color: Color(0xffe6db74)),
  'selector-attr': TextStyle(color: Color(0xffe6db74)),
  'selector-pseudo': TextStyle(color: Color(0xffe6db74)),
  'addition': TextStyle(color: Color(0xffe6db74)),
  'variable': TextStyle(color: Color(0xffe6db74)),
  'template-variable': TextStyle(color: Color(0xffe6db74)),
  'comment': TextStyle(color: Color(0xff75715e)),
  'deletion': TextStyle(color: Color(0xff75715e)),
  'meta': TextStyle(color: Color(0xff75715e)),
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
    var vs;
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
            child: Container(
                width: 400,
                child: CodeField(
                    controller: _codeController!,
                    textStyle: TextStyle(fontFamily: 'SourceCode'))),
          )
        ])));
  }
}
