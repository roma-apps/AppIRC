import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider_context_bloc.dart';
import 'package:provider/provider.dart';

abstract class IAppContextBloc extends IProviderContextBloc {
  static IAppContextBloc of(BuildContext context, {bool listen = true}) =>
      Provider.of<IAppContextBloc>(context, listen: listen);
}
