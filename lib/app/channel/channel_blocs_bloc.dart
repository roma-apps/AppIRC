import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/push/chat_push_service.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:provider/provider.dart';

class ChannelBlocsBloc extends ChannelListListenerBloc {
  static ChannelBlocsBloc of(BuildContext context) {
    return Provider.of<ChannelBlocsBloc>(context);
  }

  final Map<Channel, ChannelBloc> _blocs = {};
  final ChatBackendService backendService;
  final ChatPushesService chatPushesService;
  final ChannelStatesBloc channelsStatesBloc;

  ChannelBlocsBloc({
    @required this.backendService,
    @required this.chatPushesService,
    @required NetworkListBloc networksListBloc,
    @required this.channelsStatesBloc,
  }) : super(
          networksListBloc: networksListBloc,
        ) {
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
  void onChannelJoined(
    Network network,
    ChannelWithState channelWithState,
  ) {
    _blocs[channelWithState.channel] = ChannelBloc(
      backendService: backendService,
      chatPushesService: chatPushesService,
      network: network,
      channelWithState: channelWithState,
      channelsStatesBloc: channelsStatesBloc,
    );
  }

  @override
  void onChannelLeaved(
    Network network,
    Channel channel,
  ) {
    _disposeChannelBloc(
      _blocs.remove(
        channel,
      ),
    );
  }
}
