import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

typedef NetworksListListener(List<Network> networks);
typedef NetworkListener(Network network);
typedef NetworkStateListener(NetworkState networkState);
typedef NetworkChannelListener(NetworkChannel channel);
typedef NetworkChannelStateListener(NetworkChannelState channelState);
typedef NetworkChannelMessageListener(IRCChatMessage message);

abstract class ChatBackendService implements Providable {
  Stream<ChatConnectionState> get connectionStateStream;

  bool get isConnected;

  ChatConnectionState get connectionState;

  ChatConfig get chatConfig;

  bool get isReadyToConnect;
}

abstract class ChatOutputBackendService implements ChatBackendService {

  Disposable listenForNetworkState(
      Network network,
      NetworkState Function() currentStateExtractor,
      NetworkStateListener listener);

  Disposable listenForNetworkEnter(NetworkListener listener);

  Disposable listenForNetworkExit(Network network, VoidCallback listener);

  Disposable listenForNetworkChannelJoin(
      Network network, NetworkChannelListener listener);

  Disposable listenForNetworkChannelState(
      Network network,
      NetworkChannel channel,
      NetworkChannelState Function() currentStateExtractor,
      NetworkChannelStateListener listener);

  Disposable listenForNetworkChannelLeave(
      Network network, NetworkChannel channel, VoidCallback listener);

  Disposable listenForNetworkChannelUsers(Network network,
      NetworkChannel channel, Function(List<ChannelUserInfo>) listener);

  Disposable listenForMessages(Network network, NetworkChannel channel,
      NetworkChannelMessageListener listener);
}

abstract class ChatInputBackendService implements ChatBackendService {


  Future<RequestResult<bool>> connectChat();

  Future<RequestResult<bool>> disconnectChat({bool waitForResult: false});

  Future<RequestResult<Network>> joinNetwork(IRCNetworkPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<bool>> leaveNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<List<IRCChatSpecialMessage>>>
      printNetworkAvailableChannels(Network network,
          {bool waitForResult: false});

  Future<RequestResult<NetworkChannelMessage>> printNetworkIgnoredUsers(
      Network network,
      {bool waitForResult: false});

  Future<RequestResult<bool>> enableNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<bool>> disableNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<Network>> editNetworkSettings(
      Network network, IRCNetworkPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<NetworkChannel>> joinNetworkChannel(
      Network network, IRCNetworkChannelPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<bool>> leaveNetworkChannel(
      Network network, NetworkChannel channel,
      {bool waitForResult: false});

  Future<RequestResult<ChannelUserInfo>> getUserInfo(
      Network network, NetworkChannel channel, String userNick,
      {bool waitForResult: false});

  Future<RequestResult<NetworkChannelMessage>> printNetworkChannelBannedUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult: false});

  Future<RequestResult<List<ChannelUserInfo>>> getNetworkChannelUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult: false});

  Future<RequestResult<bool>> editNetworkChannelTopic(
      Network network, NetworkChannel channel, String newTopic,
      {bool waitForResult: false});

  Future<RequestResult<bool>> onOpenNetworkChannel(
      Network network, NetworkChannel channel);

  Future<RequestResult<NetworkChannelMessage>> sendNetworkChannelRawMessage(
      Network network, NetworkChannel channel, String rawMessage,
      {bool waitForResult: false});
}

abstract class ChatInputOutputBackendService
    implements ChatInputBackendService, ChatOutputBackendService {

}
