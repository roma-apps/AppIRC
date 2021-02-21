import 'package:flutter_appirc/async/loading/async_loading_service.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:rxdart/rxdart.dart';

typedef Future LoadingFunction();

abstract class AsyncLoadingService extends DisposableOwner
    implements IAsyncLoadingService {
  // ignore: close_sinks
  final BehaviorSubject<bool> _isLoadingSubject =
      BehaviorSubject<bool>.seeded(false);

  @override
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  @override
  bool get isLoading => _isLoadingSubject.value;

  AsyncLoadingService() {
    addDisposable(subject: _isLoadingSubject);
  }

  Future performLoading(LoadingFunction loadingFunction) async {
    if (!_isLoadingSubject.isClosed) {
      _isLoadingSubject.add(true);
    }
    await loadingFunction();
    if (!_isLoadingSubject.isClosed) {
      _isLoadingSubject.add(false);
    }
  }
}
