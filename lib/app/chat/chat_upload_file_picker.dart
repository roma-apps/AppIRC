import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File> pickFileForUpload() async {
  return await FilePicker.getFile();
}
