import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Saves the PDF to local storage on Android/iOS/Desktop.
Future<String?> saveAndDownloadPdf(Uint8List bytes, String filename) async {
  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);
      return path;
    }
  } catch (_) {}
  return null;
}
