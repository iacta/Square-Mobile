/* import 'package:flutter/material.dart';
import 'package:square/modules/functions/api/api.dart';
import 'package:path/path.dart' as path;

class FileExplorer extends StatefulWidget {
  final String? appId;

  const FileExplorer({super.key, this.appId});

  @override
  _FileExplorerState createState() => _FileExplorerState();
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
    var pathParts = currentPath.split('/');
    pathParts.removeLast();
    currentPath = pathParts.join('/');

    setState(() {
      filesFuture = files(widget.appId, currentPath);
      lastPath = currentPath;
    });
  }

  Future<void> _refresh() async {
    try {
      setState(() {
        filesFuture = files(widget.appId, currentPath);
      });
    } catch (e) {
      print('Error refreshing files: $e');
      // Handle the error appropriately, e.g., show an error message.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('File Explorer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
        ),
        body: RefreshIndicator(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Path: $currentPath'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: fileList.length,
                        itemBuilder: (context, index) {
                          final item = fileList[index];
                          return ListTile(
                            title: Text(item['name']),
                            leading: item['type'] == 'directory'
                                ? const Icon(Icons.folder)
                                : const Icon(Icons.file_copy),
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
        ));
  }

  void _openFile(String directoryPath, String fileName) async {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
}

 */