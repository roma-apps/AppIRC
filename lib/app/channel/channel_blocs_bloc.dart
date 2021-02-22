import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:provider/provider.dart';

class ChannelBlocsBloc extends ChannelListListenerBloc {
  static ChannelBlocsBloc of(BuildContext context) {
    return Provider.of<ChannelBlocsBloc>(context);
  }

  final Map<Channel, ChannelBloc> _blocs = {};
  final ChatBackendService _backendService;
  final ChatPushesService chatPushesService;
  final ChannelStatesBloc _channelsStatesBloc;

  ChannelBlocsBloc(
    this._backendService,
    this.chatPushesService,
    NetworkListBloc networksListBloc,
    this._channelsStatesBloc,
  ) : super(networksListBloc) {
    addDisposable(
      disposable: CustomDisposable(
        () {
          _blocs.values.forEach((bloc) => _disposeChannelBloc(bloc));
          _blocs.clear();
        },
      ),
    );
  }

  void _disposeChannelBloc(ChannelBloc bloc) => bloc.dispose();

  ChannelBloc getChannelBloc(Channel channel) => _blocs[channel];

  @override
  void onChannelJoined(Network network, ChannelWithState channelWithState) {
    _blocs[channelWithState.channel] = ChannelBloc(
      _backendService,
      chatPushesService,
      network,
      channelWithState,
      _channelsStatesBloc,
    );
  }

  @override
  void onChannelLeaved(Network network, Channel channel) {
    _disposeChannelBloc(_blocs.remove(channel));
  }
}
