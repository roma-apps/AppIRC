import 'dart:convert';
import 'dart:io';

import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/upload/lounge_upload_file_model.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

final String _loungeInstanceUploadRelativePath = "/uploads/new/";
final String _uploadMultipartRequestMethod = 'POST';
final String _uploadFileResponseBodyRelativePathFieldName = "file";
final int _successResponseCode = 200;

var _durationToCheckResponseDecode = Duration(milliseconds: 100);
var _durationToTimeoutResponseDecode = Duration(seconds: 5);

MyLogger _logger =
    MyLogger(logTag: "lounge_upload_file_helper.dart", enabled: true);

Future<String> uploadFileToLounge(String loungeURL, File file,
    String uploadAuthToken, int maximumPossibleUploadFileSizeInBytes) async {
  if (uploadAuthToken?.isNotEmpty != true) {
    throw ServerAuthInvalidLoungeUploadException(
        file, loungeURL, uploadAuthToken, maximumPossibleUploadFileSizeInBytes);
  }

  if (maximumPossibleUploadFileSizeInBytes != null &&
      maximumPossibleUploadFileSizeInBytes > 0) {
    var fileLength = await file.length();

    if (fileLength > maximumPossibleUploadFileSizeInBytes) {
      throw FileSizeExceededLoungeUploadException(file, loungeURL,
          uploadAuthToken, maximumPossibleUploadFileSizeInBytes, fileLength);
    }
  }

  loungeURL = _removeTrailingSlashIfExist(loungeURL);

  var postUri = _calculatePostURI(loungeURL, uploadAuthToken);
  _logger.d(() => "uploadFileToLounge $postUri");
  var request = MultipartRequest(_uploadMultipartRequestMethod, postUri);
  request.files.add(await _createPostMultipartFile(file));

  var response = await request.send();

  _logger.d(() => "uploadFileToLounge"
      " response.statusCode ${response.statusCode}");
  _logger.d(() => "uploadFileToLounge"
      " response.contentLength ${response.contentLength}");

  var responseCode = response.statusCode;
  if (responseCode == _successResponseCode) {
    String decodedResponseBody;
    bool timeout = false;
    var listener =
        response.stream.transform(utf8.decoder).listen((responseBody) {
      decodedResponseBody = responseBody;
    });

    Future.delayed(_durationToTimeoutResponseDecode, () {
      if (decodedResponseBody == null) {
        timeout = true;
      }
    });

    while (decodedResponseBody == null && !timeout) {
      await Future.delayed(_durationToCheckResponseDecode);
    }

    listener.cancel();

    if (timeout) {
      throw TimeoutHttpLoungeUploadException(file, loungeURL,
          uploadAuthToken, maximumPossibleUploadFileSizeInBytes);
    } else {
      _logger.d(() => "uploadFileToLounge response body $decodedResponseBody");

      var responseBody = LoungeResponseUploadResponseBody.fromJson(
          json.decode(decodedResponseBody));

      if (responseBody?.url == null) {
        throw InvalidHttpResponseBodyLoungeUploadException(
            file,
            loungeURL,
            uploadAuthToken,
            maximumPossibleUploadFileSizeInBytes,
            decodedResponseBody);
      } else {
        return _calculateUploadedFileURL(loungeURL, responseBody?.url);
      }
    }
  } else {
    throw InvalidHttpResponseCodeLoungeUploadException(file, loungeURL,
        uploadAuthToken, maximumPossibleUploadFileSizeInBytes, responseCode);
  }
}

String _calculateUploadedFileURL(String loungeURL, String relativePath) =>
    loungeURL + "/" + relativePath;


Future<MultipartFile> _createPostMultipartFile(File file) async {
  return MultipartFile.fromBytes(
      _uploadFileResponseBodyRelativePathFieldName, await file.readAsBytes(),
      filename: basename(file.path));
}

Uri _calculatePostURI(String loungeURL, String uploadAuthToken) =>
    Uri.parse(loungeURL + _loungeInstanceUploadRelativePath + uploadAuthToken);

String _removeTrailingSlashIfExist(String loungeURL) {
  if (loungeURL.endsWith("/")) {
    loungeURL = loungeURL.substring(0, loungeURL.length - 1);
  }
  return loungeURL;
}
