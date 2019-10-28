import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

/// It is not possible to simple use ChannelBloc as Provider
/// app shouldn't dispose ChannelBloc instances during UI changes
/// ChannelBloc disposed in ChatChannelsBlocsBloc
class ChannelBlocProvider extends Providable {
  ChannelBloc channelBloc;
  ChannelBlocProvider(this.channelBloc);
}
