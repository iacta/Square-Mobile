
import 'package:code_text_field/code_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:highlight/languages/all.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:path/path.dart' as paths;
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/apps/dash.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:square/modules/views/routes/upload/up.dart';
import 'package:url_launcher/url_launcher.dart';

var vs = false;
var theme = {
  'root': TextStyle(
      backgroundColor: inputBackgroundColor, color: const Color(0xfff8f8f2)),
  'tag': const TextStyle(color: Color(0xfff8f8f2)),
  'subst': const TextStyle(color: Color(0xfff8f8f2)),
  'strong':
      const TextStyle(color: Color(0xffa8a8a2), fontWeight: FontWeight.bold),
  'emphasis':
      const TextStyle(color: Color(0xffa8a8a2), fontStyle: FontStyle.italic),
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
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
CodeController? _codeController;
late Future<String> _fileReadFuture;

// ignore: must_be_immutable
class Editing extends StatefulWidget {
  String? lang;
  final String? path;
  final String? appid;
  Editing(
      {super.key, required this.lang, required this.appid, required this.path});

  @override
  State<Editing> createState() => _EditingState();
}

var filesopen = [];
String getLanguageFromFileName(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  final languageMap = {
    'dart': 'dart',
    'py': 'python',
    'js': 'javascript',
    'go': 'go',
    'ts': 'typescript',
    'html': 'html',
    'json': 'json',
    'css': 'css'
  };

  return languageMap[ext] ?? 'javascript';
}

var fill = '';

class _EditingState extends State<Editing> {
  Future<void> updateFileReadFuture(String? path, String fileName) async {
    try {
      setState(() {
        _fileReadFuture = Future.value('');
      });

      String newFileContent = await fileRead(widget.appid, path);

      setState(() {
        _fileReadFuture = Future.value(newFileContent);
        fill = fileName;
        widget.lang = fileName;
      });
    } catch (error) {
      log(data['name'], 'fatal', 'Erro ao recarregar dados do arquivo: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _fileReadFuture = fileRead(widget.appid, widget.path);
    fill = widget.lang!;
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _codeController?.dispose();
  }

  Future<void> _launchUrl(String s) async {
    if (!await launchUrl(Uri.parse(s))) {
      throw 'Could not launch $s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: FileExplorer(
          appId: widget.appid,
        ),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 11, 15, 19),
          centerTitle: true,
          title: Text(fill,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(PhosphorIconsBold.arrowLeft)),
            IconButton(
                onPressed: () async {
                  await fileDelete(context, widget.appid, widget.path);
                  await fileCreate(widget.appid, _codeController!.text, context,
                      widget.path);
                },
                icon: const Icon(
                  PhosphorIconsBold.floppyDisk,
                  color: Colors.blue,
                )),
            IconButton(
              onPressed: () => _showHelpDialog(context),
              icon: SvgPicture.asset(
                'assets/images/discord.svg',
                width: 24,
                height: 24,
              ),
            ),
            const LanguageSwitcher(),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: SingleChildScrollView(
            child: Column(children: [
          FutureBuilder(
              future: _fileReadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);
                  var language =
                      getLanguageFromFileName(widget.lang.toString());
                  _codeController = CodeController(
                    text: snapshot.data.toString(),
                    language: builtinLanguages[language],
                  );
                  return CodeTheme(
                    data: CodeThemeData(styles: theme),
                    child: SizedBox(
                        width: double.maxFinite,
                        child: CodeField(
                            controller: _codeController!,
                            textStyle:
                                const TextStyle(fontFamily: 'SourceCode'))),
                  );
                }
              }),
        ])));
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('pt', 'help', 'helpTitle')),
          content: Text(translate('pt', 'help', 'helpBody')),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(translate('pt', 'help', 'negative')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _launchUrl(
                    'https://discord.com/channels/898377990906454016/1140271484242243686');
              },
              child: Text(translate('pt', 'help', 'positive')),
            ),
          ],
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/squarecloud.gif',
              height: 200, fit: BoxFit.cover)
        ],
      ),
    );
  }
}

/* class ShowFiles extends StatefulWidget {
  final String? appid;
  final String? lang;
  final String? path;

  const ShowFiles({super.key, this.appid, this.lang, this.path});

  @override
  State<ShowFiles> createState() => _ShowFilesState();
}

void reset() {
  path = './';
}

class _ShowFilesState extends State<ShowFiles> {
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  late final Future<void> filesFuture;
  bool show = false;
  var path = '';
  bool click = false;
  Future<void> _refresh() async {
    await files(widget.appid, '.%2F');
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  void initState() {
    super.initState();
    filesFuture = files(widget.appid, '.%2F');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Explorer',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border.all(
                color: const Color.fromARGB(255, 66, 64, 64),
                width: 0.4,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            width: 390,
            child: Text('/ root $path'),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => backup(widget.appid, context),
                  icon: const Icon(
                    PhosphorIconsThin.downloadSimple,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      show = !show;
                    });
                  },
                  icon: Row(
                    children: [
                      const Icon(
                        PhosphorIconsThin.plus,
                        color: Colors.blue,
                        size: 24.0,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        show
                            ? PhosphorIconsThin.caretUp
                            : PhosphorIconsThin.caretDown,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (show)
            Container(
              margin: const EdgeInsets.only(bottom: 8, right: 108),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black87,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextButton(
                    onPressed: () {
                      input(context, widget.appid);
                      setState(() {
                        show = !show;
                      });
                    },
                    icon: const Icon(
                      PhosphorIconsBold.file,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: 'File',
                  ),
                  _buildTextButton(
                    onPressed: () {
                      _showConfigDialog(context);
                      setState(() {
                        show = !show;
                      });
                    },
                    icon: const Icon(
                      PhosphorIconsBold.fileZip,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: 'Commit',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 5),
          if (vs)
            GestureDetector(
              onTap: () async {
                await files(widget.appid, '.%2F');
                setState(() {
                  vs = false;
                  path = '';
                });
              },
              child: const ListTile(
                title: Row(
                  children: [
                    Icon(Icons.drive_folder_upload),
                    SizedBox(width: 8),
                    Text('..'),
                  ],
                ),
                subtitle: SizedBox(
                  height: 5,
                ),
              ),
            ),
          FutureBuilder(
            future: filesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final List<Map<String, dynamic>> directories = [];
                final List<Map<String, dynamic>> filesList = [];

                for (final item in file) {
                  if (item['type'] == 'directory') {
                    directories.add(item);
                  } else {
                    filesList.add(item);
                  }
                }

                directories.sort((a, b) => a['name'].compareTo(b['name']));
                filesList.sort((a, b) => a['name'].compareTo(b['name']));

                final List<Map<String, dynamic>> sortedList = [
                  ...directories,
                  ...filesList
                ];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    final item = sortedList[index];
                    return Column(
                      children: [
                        ListTile(
                          onTap: () async {
                            if (item['type'] == 'directory') {
                              await files(widget.appid, './${item['name']}');
                              setState(() {
                                vs = true;
                                path = '$path/${item['name']}';
                              });
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scaffoldKey.currentState?.closeDrawer();
                              });
                              _EditingState? editingState = context
                                  .findAncestorStateOfType<_EditingState>();
                              if (editingState != null) {
                                if (path != null) {
                                  await editingState.updateFileReadFuture(
                                      '.%2F/$path', item['name']);
                                } else {
                                  await editingState.updateFileReadFuture(
                                      '.%2F/${sortedList[index]['name']}',
                                      item['name']);
                                }
                              }
                              setState(() {
                                fill = item['name'];
                              });
                            }
                          },
                          title: Row(
                            children: [
                              _buildFileIcon(item['type'], item['name']),
                              const SizedBox(width: 8),
                              Text(item['name']),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: inputBackgroundColor,
                                    border: Border.all(
                                      color: fieldBackgroundColor,
                                      width: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Text(item['type']),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: inputBackgroundColor,
                                    border: Border.all(
                                      color: inputBackgroundColor,
                                      width: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Text('${item['size'].toString()}KB'),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await fileDelete(
                                context,
                                widget.appid,
                                "./${item['name']}",
                              );
                              await _refresh();
                              setState(() {});
                            },
                            icon: const Icon(
                              PhosphorIconsRegular.trash,
                              size: 28,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Divider(
                          color: fieldBackgroundColor,
                          thickness: 1,
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(height: 300),
        ],
      ),
    );
  }

  Widget _buildTextButton({
    required VoidCallback onPressed,
    required Icon icon,
    required String label,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Commit(
          id: widget.appid,
        );
      },
    );
  }
}
 */

class FileExplorer extends StatefulWidget {
  final String? appId;
  const FileExplorer({super.key, this.appId});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  late String currentPath;
  late Future filesFuture;
  late String lastPath;

  @override
  void initState() {
    super.initState();
    currentPath = './';
    filesFuture = files(widget.appId, currentPath);
  }

  Future<void> _goBack() async {
    if (currentPath == './') {}
    var pathParts = currentPath.split('/');
    pathParts.removeLast();
    currentPath = pathParts.join('/');
    setState(() {
      filesFuture = files(widget.appId, currentPath);
      if (currentPath.startsWith('/')) {
        currentPath = './';
      }
      lastPath = currentPath;
    });
  }

  Future<void> _refresh() async {
    try {
      setState(() {
        filesFuture = files(widget.appId, currentPath);
      });
    } catch (e) {
      log(data['name'], 'fatal', 'Error refreshing files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentDirectoryName = currentPath == './' ||
            currentPath == '/' ||
            currentPath == '.' ||
            currentPath == ''
        ? 'root'
        : paths.basename(currentPath);

    return Drawer(
      backgroundColor: const Color.fromARGB(255, 11, 14, 19),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: RefreshIndicator(
          onRefresh: () => _refresh(),
          child: FutureBuilder(
            future: filesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final fileList = snapshot.data ?? [];
                fileList.sort((a, b) {
                  if (a['type'] == 'directory' && b['type'] != 'directory') {
                    return -1;
                  } else if (a['type'] != 'directory' &&
                      b['type'] == 'directory') {
                    return 1;
                  } else {
                    return (a['name'] as String)
                        .toLowerCase()
                        .compareTo((b['name'] as String).toLowerCase());
                  }
                });

                return Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '/$currentDirectoryName',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      centerTitle: false,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _goBack,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => backup(widget.appId, context),
                          icon: const Icon(
                            PhosphorIconsThin.downloadSimple,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              show = !show;
                            });
                          },
                          icon: Row(
                            children: [
                              const Icon(
                                PhosphorIconsThin.plus,
                                color: Colors.blue,
                                size: 24.0,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                show
                                    ? PhosphorIconsThin.caretUp
                                    : PhosphorIconsThin.caretDown,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (show) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black87,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextButton(
                              onPressed: () {
                                input(context, widget.appId);
                                setState(() {
                                  show = !show;
                                });
                              },
                              icon: const Icon(
                                PhosphorIconsBold.file,
                                size: 24,
                                color: Colors.white,
                              ),
                              label: 'File',
                            ),
                            _buildTextButton(
                              onPressed: () {
                                _showConfigDialog(context);
                                setState(() {
                                  show = !show;
                                });
                              },
                              icon: const Icon(
                                PhosphorIconsBold.fileZip,
                                size: 24,
                                color: Colors.white,
                              ),
                              label: 'Commit',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    /* Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: bgBlack900.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 2,
                            color: borderBlack700,
                          )),
                      child: Text(
                        'Current Path: $currentPath',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ), */
                    Expanded(
                      child: ListView.builder(
                        itemCount: fileList.length,
                        itemBuilder: (context, index) {
                          final item = fileList[index];
                          return ListTile(
                            title: Text(item['name']),
                            leading: _buildFileIcon(
                                item['type'],
                                item[
                                    'name']), // Ícone de arquivo/diretório à esquerda
                            trailing: _buildDeleteIcon(() async {
                              _showDeleteConfirmationDialog(
                                  context, item['name']);
                            }), // Ícone de lixeira à direita
                            onTap: () async {
                              if (item['type'] == 'directory') {
                                _openDirectory(item['name']);
                              } else {
                                _openFile(currentPath, item['name']);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate(
              context.locale.toString(), 'fileDelete', 'confirmDeleteTitle')),
          content: Text(translate(context.locale.toString(), 'fileDelete',
                  'confirmDeleteMessage') +
              fileName),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(translate(context.locale.toString(), 'fileDelete',
                  'confirmDeleteNegativeButton')),
            ),
            TextButton(
              onPressed: () async {
                // Coloque aqui a lógica para deletar o arquivo
                await fileDelete(context, widget.appId, fileName);
                await _refresh();

                Navigator.of(context).pop();
              },
              child: Text(translate(context.locale.toString(), 'fileDelete',
                  'confirmDeletePositiveButton')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteIcon(VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        PhosphorIconsBold.trashSimple,
        color: Colors.red,
      ),
    );
  }

  bool show = false;

  Widget _buildTextButton({
    required VoidCallback onPressed,
    required Icon icon,
    required String label,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Commit(
          id: widget.appId,
        );
      },
    );
  }

  void _openFile(String directoryPath, String fileName) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.closeDrawer();
    });

    _EditingState? editingState =
        context.findAncestorStateOfType<_EditingState>();

    if (editingState != null) {
      await editingState.updateFileReadFuture(
          '$directoryPath/$fileName', fileName);
    }

    setState(() {
      fill = fileName;
    });
  }

  void _openDirectory(String directoryName) {
    setState(() {
      lastPath = currentPath;

      currentPath = paths.join(currentPath, directoryName);
      filesFuture = files(widget.appId, currentPath);
    });
  }

  Widget _buildFileIcon(String fileType, String namefile) {
    return fileType == 'directory'
        ? const Icon(PhosphorIconsFill.folder)
        : iconForExtension(namefile);
  }

  Widget iconForExtension(String fileName) {
    Map<String, IconData> extensionIcons = {
      'jpg': PhosphorIconsFill.fileJpg,
      'js': PhosphorIconsFill.fileJs,
      'css': PhosphorIconsFill.fileCss,
      'jsx': PhosphorIconsFill.fileJsx,
      'svg': PhosphorIconsFill.fileSvg,
      'sql': PhosphorIconsFill.fileSql,
      'ts': PhosphorIconsFill.fileTs,
      'tsx': PhosphorIconsFill.fileTsx,
      'html': PhosphorIconsFill.fileHtml,
      'png': PhosphorIconsFill.filePng,
      'rs': PhosphorIconsFill.fileRs,
      'app': PhosphorIconsFill.fileCloud,
      'config': PhosphorIconsFill.fileCloud,
    };

    String extension = fileName.split('.').last.toLowerCase();

    if (extensionIcons.containsKey(extension)) {
      return Icon(extensionIcons[extension]);
    } else if (fileName.contains('requirements') ||
        fileName.contains('package.json')) {
      return const Icon(PhosphorIconsFill.package);
    } else {
      return const Icon(PhosphorIconsFill.file);
    }
  }
}

//////