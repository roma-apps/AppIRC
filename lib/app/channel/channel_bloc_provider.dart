import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

/// It is not possible to simple use NetworkChannelBloc as Provider
/// app shouldn't dispose NetworkChannelBloc instances during UI changes
/// NetworkChannelBloc disposed in ChatNetworkChannelsBlocsBloc
class NetworkChannelBlocProvider extends Providable {
  NetworkChannelBloc networkChannelBloc;
  NetworkChannelBlocProvider(this.networkChannelBloc);
}
