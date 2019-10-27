import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

/// It is not possible to simple use NetworkBloc as Provider
/// app shouldn't dispose NetworkBloc instances during UI changes
/// NetworkBloc disposed in ChatNetworksBlocsBloc
class NetworkBlocProvider extends Providable {
  final NetworkBloc networkBloc;
  NetworkBlocProvider(this.networkBloc);
}
