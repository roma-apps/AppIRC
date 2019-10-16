import 'dart:convert';
import 'dart:io';

import 'package:flutter_appirc/logger/logger.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

final String _uploadPath = "/uploads/new/";
var uploadFileFieldName = 'file';

var _logger = MyLogger(logTag: "uploadFileToLounge", enabled: true);

Future<String> uploadFileToLounge(
    String loungeURL, String uploadAuthToken, File file) async {
  if (loungeURL.endsWith("/")) {
    loungeURL = loungeURL.substring(0, loungeURL.length - 1);
  }

  var postUri = Uri.parse(loungeURL + _uploadPath + uploadAuthToken);
  _logger.d(() => "uploadFileToLounge $postUri");
  var request = MultipartRequest("POST", postUri);
  var multipartFile = MultipartFile.fromBytes(uploadFileFieldName,
      await file.readAsBytes(), filename: basename(file.path));

  request.files.add(multipartFile);

  var response = await request.send();

  _logger.d(() => "uploadFileToLounge response.statusCode ${response.statusCode}");
  _logger.d(() => "uploadFileToLounge response.contentLength ${response.contentLength}");

  String uploadedFileURL;

  if (response.statusCode == 200) {

  }

  response.stream.transform(utf8.decoder).listen((value) {
    _logger.d(() => "uploadFileToLounge response body $value");
    uploadedFileURL = loungeURL +"/" + json.decode(value)["url"];
  });

  await Future.delayed(Duration(seconds: 1));

  if(uploadedFileURL == null) {
    throw HttpUploadException();
  }

  return uploadedFileURL;
}


class FileSizeUploadException implements Exception {

}


class ServerAuthUploadException implements Exception {

}

class HttpUploadException implements Exception {

}
