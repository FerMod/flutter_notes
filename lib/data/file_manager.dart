import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataStorage {
  static final fileName = 'data.json';
  final _encoder = JsonEncoder.withIndent('  ');

  Future<File> get _localFile async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final filePath = join(documentsDirectory.path, fileName);
    return File(filePath);
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;

      // Read the file
      var contents = await file.readAsString();

      return contents;
    } on Exception {
      // If encountering an error, return 0
      return null;
    }
  }

  Future<File> writeData(String json) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(_encoder.convert(json));
  }
}
