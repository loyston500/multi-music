import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void saveFileLocally(String fileName, String content) async {
  Directory? dir = await getExternalStorageDirectory();
  if (dir != null) {
    if (await Permission.storage.request().isGranted) {
      var folders = dir.path.split('/');
      var index = folders.indexOf('Android');
      if (index > 0) {
        // What the actual f*ck
        var dir =
            Directory("${folders.sublist(0, index).join('/')}/Multi Music");
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        if (await dir.exists()) {
          File file = File("${dir.path}/$fileName");
          file.writeAsString(content);
        }
      }
    }
  }
}
