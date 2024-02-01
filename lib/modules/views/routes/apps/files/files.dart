
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:square/modules/functions/language/lang.dart';
import 'package:square/modules/views/routes/apps/dash.dart';
import 'package:square/modules/views/routes/apps/files/edit.dart';
import 'package:square/modules/views/routes/main_page/home.dart';
import 'package:square/modules/views/routes/upload/up.dart';
import 'package:path/path.dart' as paths;

bool select = false;
var infoFile = {};
var vs = false;

class Files extends StatefulWidget {
  final String? appid;
  const Files({super.key, this.appid});

  @override
  State<Files> createState() => _FilesState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _FilesState extends State<Files> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 90,
          title: Image.asset(
            'assets/images/logo.webp',
            height: 60,
            fit: BoxFit.cover,
          ),
          backgroundColor: const Color.fromARGB(255, 11, 15, 19),
          elevation: 1,
          actions: [
            const LanguageSwitcher(),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(PhosphorIconsBold.arrowLeft)),
          ],
        ),
        drawer: Drawer(
            child: FileExplorer(
          appId: widget.appid,
        )),
        backgroundColor: const Color.fromARGB(255, 11, 14, 19),
        body: Builder(builder: (BuildContext context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldKey.currentState?.openDrawer();
          });
          return Center(
              child: Text(translate(
            context.locale.toString(),
            'messages',
            'fileWarn',
          )));
        }));
  }
}

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
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Editing(
            lang: fileName,
            appid: widget.appId,
            path: '$directoryPath/$fileName',
          ),
        ));
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
