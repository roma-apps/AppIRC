import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'lounge_upload_file_model.g.dart';

@JsonSerializable()
class LoungeResponseUploadResponseBody {
  final String url;

  LoungeResponseUploadResponseBody(this.url);

  @override
  String toString() {
    return 'LoungeResponseUploadResponse{url: $url}';
  }

  factory LoungeResponseUploadResponseBody.fromJson(
          Map<String, dynamic> json) =>
      _$LoungeResponseUploadResponseBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LoungeResponseUploadResponseBodyToJson(this);
}

abstract class LoungeUploadException implements Exception {
  String get loungeURL;

  File get file;

  String get uploadAuthToken;

  int get maximumPossibleUploadFileSizeInBytes;
}

class FileSizeExceededLoungeUploadException implements LoungeUploadException {
  @override
  final File file;

  @override
  final String loungeURL;

  @override
  final String uploadAuthToken;

  @override
  final int maximumPossibleUploadFileSizeInBytes;

  final int actualSizeInBytes;

  FileSizeExceededLoungeUploadException(
    this.file,
    this.loungeURL,
    this.uploadAuthToken,
    this.maximumPossibleUploadFileSizeInBytes,
    this.actualSizeInBytes,
  );
}

class ServerAuthInvalidLoungeUploadException implements LoungeUploadException {
  @override
  final File file;

  @override
  final String loungeURL;

  @override
  final String uploadAuthToken;

  @override
  final int maximumPossibleUploadFileSizeInBytes;

  ServerAuthInvalidLoungeUploadException(
    this.file,
    this.loungeURL,
    this.uploadAuthToken,
    this.maximumPossibleUploadFileSizeInBytes,
  );
}

class InvalidHttpResponseBodyLoungeUploadException
    implements LoungeUploadException {
  @override
  final File file;

  @override
  final String loungeURL;

  @override
  final String uploadAuthToken;

  @override
  final int maximumPossibleUploadFileSizeInBytes;

  final String responseBody;

  InvalidHttpResponseBodyLoungeUploadException(
    this.file,
    this.loungeURL,
    this.uploadAuthToken,
    this.maximumPossibleUploadFileSizeInBytes,
    this.responseBody,
  );
}

class InvalidHttpResponseCodeLoungeUploadException
    implements LoungeUploadException {
  @override
  final File file;

  @override
  final String loungeURL;

  @override
  final String uploadAuthToken;

  @override
  final int maximumPossibleUploadFileSizeInBytes;

  final int responseCode;

  InvalidHttpResponseCodeLoungeUploadException(
    this.file,
    this.loungeURL,
    this.uploadAuthToken,
    this.maximumPossibleUploadFileSizeInBytes,
    this.responseCode,
  );
}

class TimeoutHttpLoungeUploadException implements LoungeUploadException {
  @override
  final File file;

  @override
  final String loungeURL;

  @override
  final String uploadAuthToken;

  @override
  final int maximumPossibleUploadFileSizeInBytes;

  TimeoutHttpLoungeUploadException(
    this.file,
    this.loungeURL,
    this.uploadAuthToken,
    this.maximumPossibleUploadFileSizeInBytes,
  );
}
