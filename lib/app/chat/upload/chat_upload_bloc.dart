import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

class ChatUploadBloc extends DisposableOwner {
  final LoungeBackendService backendService;

  bool get isUploadSupported => backendService.chatConfig.fileUpload == true;

  int get maxUploadSizeInBytes =>
      backendService.chatConfig.fileUploadMaxSizeInBytes;

  ChatUploadBloc({
    @required this.backendService,
  });

  Future<RequestResult<String>> uploadFile(File file) =>
      backendService.uploadFile(
        file: file,
      );
}
