import 'package:flutter_appirc/app/context/app_context_bloc_impl.dart';
import 'package:flutter_appirc/app/init/init_bloc.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc_impl.dart';

class InitBloc extends AsyncInitLoadingBloc implements IInitBloc {
  @override
  AppContextBloc appContextBloc;

  @override
  Future internalAsyncInit() async {
    appContextBloc = AppContextBloc();
    addDisposable(disposable: appContextBloc);

    await appContextBloc.performAsyncInit();
  }
}
