import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc_impl.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider_context_bloc.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart' as provider_lib;

var _logger = Logger("provider_context_bloc_impl.dart");

typedef provider_lib.Provider<T> ProviderBuilder<T extends IDisposable>();

class DisposableEntry<T extends IDisposable> {
  T disposable;
  ProviderBuilder<T> providerBuilder;

  DisposableEntry(this.disposable, this.providerBuilder);
}

abstract class ProviderContextBloc extends AsyncInitLoadingBloc
    implements IProviderContextBloc {
  final Map<Type, DisposableEntry> _storage = {};

  @override
  IDisposable register<T extends IDisposable>(T disposable) {
    var type = T;
    if (_storage.containsKey(type)) {
      throw "Can't register $IDisposable because {$type} already registered";
    }

    ProviderBuilder<T> providerCreator = () {
//      _logger.fine(() => "providerCreator for $type context $context");
      return provider_lib.Provider<T>.value(value: disposable);
    };

    _storage[type] = DisposableEntry<T>(disposable, providerCreator);

    return CustomDisposable(() async => await unregister<T>(disposable));
  }

  @override
  Future unregister<T extends IDisposable>(T object) async {
    var type = T;
    if (!_storage.containsKey(type)) {
      throw "Can't unregister $object because {$type} not registred";
    }

    var objInStorage = _storage[type];
    if (objInStorage != object) {
      throw "Can't unregister $object because obj {$object} not equal to "
          "registered $objInStorage";
    }

    await objInStorage.disposable.dispose();

    _storage.remove(type);
  }

  @override
  Widget provideContextToChild({@required Widget child}) {
    _logger.fine(() => "provideToChildContext ${_storage.length}");

    var providers =
        _storage.values.map((entry) => entry.providerBuilder()).toList();
    return provider_lib.MultiProvider(
      providers: providers,
      child: child,
    );
  }

  @override
  Future<IDisposable> asyncInitAndRegister<T extends IDisposable>(T obj,
      {Future Function(T obj) additionalAsyncInit}) async {
    if (obj is AsyncInitLoadingBloc) {
      AsyncInitLoadingBloc asyncInitLoadingBloc = obj;
      await asyncInitLoadingBloc.performAsyncInit();
    }

    if (additionalAsyncInit != null) {
      await additionalAsyncInit(obj);
    }

    return register<T>(obj);
  }

  @override
  T get<T extends IDisposable>() => _storage[T].disposable;
}
