import 'dart:io';

import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_upload_helper.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChatUploadBloc extends Providable {
  final LoungeBackendService _backendService;

  bool get isUploadSupported => _backendService.chatConfig.fileUpload;

  int get maxUploadSizeInBytes => _backendService.chatConfig.fileUploadMaxSizeInBytes;

  ChatUploadBloc(this._backendService);

  Future<RequestResult<String>> uploadFile(File file) async {

    var lengthInBytes = await file.length();
    if(lengthInBytes > maxUploadSizeInBytes) {
      throw FileSizeUploadException();
    }
    return await _backendService.uploadFile(file);
  }
}

