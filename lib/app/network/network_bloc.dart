import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/app/network/state/network_states_bloc.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:provider/provider.dart';

class NetworkBloc extends DisposableOwner {
  final ChatBackendService backendService;
  final Network network;
  final NetworkStatesBloc networksStateBloc;
  final ChannelStatesBloc channelsStateBloc;
  final ChatActiveChannelBloc activeChannelBloc;

  NetworkBloc({
    @required this.backendService,
    @required this.network,
    @required this.networksStateBloc,
    @required this.channelsStateBloc,
    @required this.activeChannelBloc,
  });

  NetworkState get _networkState => networksStateBloc.getNetworkState(network);

  Stream<NetworkState> get _networkStateStream =>
      networksStateBloc.getNetworkStateStream(network);

  NetworkTitle get networkTitle =>
      NetworkTitle(_networkState.name, _networkState.nick);

  Stream<NetworkTitle> get networkTitleStream => _networkStateStream
      .map(
        (state) => NetworkTitle(
          _networkState.name,
          _networkState.nick,
        ),
      )
      .distinct();

  String get networkNick => _networkState.nick;

  Stream<String> get networkNickStream =>
      _networkStateStream.map((state) => state?.nick).distinct();

  String get networkName => _networkState.name;

  Stream<String> get networkNameStream =>
      _networkStateStream.map((state) => state?.name).distinct();

  bool get networkConnected => _networkState.connected;

  Stream<bool> get networkConnectedStream =>
      _networkStateStream.map((state) => state?.connected).distinct();

  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels({
    bool waitForResult = false,
  }) async =>
      await backendService.printNetworkAvailableChannels(
        network: network,
        waitForResult: waitForResult,
      );

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers({
    bool waitForResult = false,
  }) async =>
      await backendService.printNetworkIgnoredUsers(
        network: network,
        waitForResult: waitForResult,
      );

  Future<RequestResult<bool>> enableNetwork({
    bool waitForResult = false,
  }) async =>
      await backendService.enableNetwork(
        network: network,
        waitForResult: waitForResult,
      );

  Future<RequestResult<bool>> disableNetwork({
    bool waitForResult = false,
  }) async =>
      await backendService.disableNetwork(
        network: network,
        waitForResult: waitForResult,
      );

  Future<RequestResult<Network>> editNetworkSettings(
    NetworkPreferences networkPreferences, {
    bool waitForResult = false,
  }) async =>
      await backendService.editNetworkSettings(
        network: network,
        networkPreferences: networkPreferences,
        waitForResult: waitForResult,
      );

  Future<RequestResult<ChannelWithState>> joinChannel(
    ChannelPreferences channelPreferences, {
    bool waitForResult = false,
  }) async {
    var alreadyJoinedChannel = network.channels.firstWhere(
      (channel) => channel.name == channelPreferences.name,
      orElse: () => null,
    );

    if (alreadyJoinedChannel != null) {
      await activeChannelBloc.changeActiveChanel(alreadyJoinedChannel);

      var channelState = channelsStateBloc.getChannelState(
        network,
        alreadyJoinedChannel,
      );
      var initMessages = <ChatMessage>[];
      var initUsers = <ChannelUser>[];
      return RequestResult.withResponse(
        ChannelWithState(
          alreadyJoinedChannel,
          channelState,
          initMessages,
          initUsers,
        ),
      );
    } else {
      return await backendService.joinChannel(
        network: network,
        channelPreferences: channelPreferences,
        waitForResult: waitForResult,
      );
    }
  }

  Future<RequestResult<bool>> leaveNetwork({
    bool waitForResult = false,
  }) async =>
      await backendService.leaveNetwork(
        network: network,
        waitForResult: waitForResult,
      );

  static NetworkBloc of(
    BuildContext context, {
    bool listen = true,
  }) =>
      Provider.of<NetworkBloc>(
        context,
        listen: listen,
      );
}
