import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File> pickFileForUpload(FileType fileType) async {
  return await FilePicker.getFile(type: fileType);
}
