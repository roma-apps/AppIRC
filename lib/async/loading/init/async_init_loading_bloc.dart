import 'dart:async';

import 'package:flutter_appirc/async/loading/async_loading_service.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_model.dart';

abstract class IAsyncInitLoadingBloc extends IAsyncLoadingService {
  Stream<AsyncInitLoadingState> get initLoadingStateStream;

  Future performAsyncInit();

  AsyncInitLoadingState get initLoadingState;

  // catched Error or Exception
  dynamic get initLoadingException;
}
