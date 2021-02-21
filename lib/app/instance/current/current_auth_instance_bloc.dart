import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:provider/provider.dart';

abstract class ICurrentAuthInstanceBloc implements IDisposable {
  static ICurrentAuthInstanceBloc of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<ICurrentAuthInstanceBloc>(context, listen: listen);

  LoungePreferences get currentInstance;

  Stream<LoungePreferences> get currentInstanceStream;

  Future changeCurrentInstance(LoungePreferences instance);

  bool isCurrentInstance(LoungePreferences instance);

  Future logoutCurrentInstance();
}
