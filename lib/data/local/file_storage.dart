import 'dart:io';

class FileStorage {
  final String fileName;
  final Future<Directory> Function() getDirectory;

  const FileStorage(
    this.fileName,
    this.getDirectory,
  );

  Future<String> load() async {
    final file = await _getLocalFile();
    return file.readAsString();
  }

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
