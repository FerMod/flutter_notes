import 'dart:io';

import 'db/database_service.dart';

class FileStorage extends LocalDatabaseService<String> {
  final String fileName;
  final Future<Directory> Function() getDirectory;

  FileStorage(
    this.fileName,
    this.getDirectory,
  );

  @override
  Future<String> load() async {
    final file = await _getLocalFile();
    return file.readAsString();
  }

  @override
  Future<File> save(String content) async {
    final file = await _getLocalFile();
    return file.writeAsString(content);
  }

  Future<File> _getLocalFile() async {
    final dir = await getDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<FileSystemEntity> clean() async {
    final file = await _getLocalFile();
    return file.delete();
  }
}
