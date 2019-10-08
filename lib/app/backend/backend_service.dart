import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

typedef NetworkListener(NetworkWithState network);
typedef NetworkConnectionListener(ChatNetworkPreferences networkPreferences);
typedef NetworkStateListener(NetworkState networkState);
typedef NetworkChannelListener(NetworkChannelWithState channel);
typedef NetworkChannelStateListener(NetworkChannelState channelState);
typedef NetworkChannelMessageListener(ChatMessage message);
typedef NetworkChannelMessagePreviewListener(PreviewForMessage previewForMessage);

abstract class ChatBackendService implements Providable {
  Stream<ChatConnectionState> get connectionStateStream;

  bool get isConnected;

  ChatConnectionState get connectionState;

  ChatConfig get chatConfig;
  ChatInitInformation get chatInit;

  bool get isReadyToConnect;
}

abstract class ChatOutputBackendService implements ChatBackendService {

  Disposable listenForNetworkState(
      Network network,
      NetworkState Function() currentStateExtractor,
      NetworkStateListener listener);

  Disposable listenForNetworkJoin(NetworkListener listener);

  Disposable listenForNetworkLeave(Network network, VoidCallback listener);
  Disposable listenForNetworkEdit(Network network, NetworkConnectionListener listener);

  Disposable listenForNetworkChannelJoin(
      Network network, NetworkChannelListener listener);

  Disposable listenForNetworkChannelLeave(
      Network network, NetworkChannel channel, VoidCallback listener);

  Disposable listenForNetworkChannelState(
      Network network,
      NetworkChannel channel,
      NetworkChannelState Function() currentStateExtractor,
      NetworkChannelStateListener listener);



  Disposable listenForNetworkChannelNames(Network network,
      NetworkChannel channel, Function(List<ChannelUserInfo>) listener);



  Disposable listenForNetworkChannelUsers(Network network,
      NetworkChannel channel, VoidCallback listener);



  Disposable listenForMessages(Network network, NetworkChannel channel,
      NetworkChannelMessageListener listener);


  Disposable listenForMessagePreviews(Network network, NetworkChannel channel,
      NetworkChannelMessagePreviewListener listener);

}

abstract class ChatInputBackendService implements ChatBackendService {


  Future<RequestResult<ConnectResult>> connectChat();

  Future<RequestResult<bool>> disconnectChat({bool waitForResult: false});

  Future<RequestResult<NetworkWithState>> joinNetwork(ChatNetworkPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<bool>> leaveNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<List<SpecialMessage>>>
      printNetworkAvailableChannels(Network network,
          {bool waitForResult: false});

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(
      Network network,
      {bool waitForResult: false});

  Future<RequestResult<bool>> enableNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<bool>> disableNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<Network>> editNetworkSettings(
      Network network, ChatNetworkPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<NetworkChannelWithState>> joinNetworkChannel(
      Network network, ChatNetworkChannelPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<NetworkChannelWithState>> openDirectMessagesChannel(
      Network network, NetworkChannel channel, String nick,
      {bool waitForResult: false});

  Future<RequestResult<bool>> leaveNetworkChannel(
      Network network, NetworkChannel channel,
      {bool waitForResult: false});

  Future<RequestResult<ChannelUserInfo>> printUserInfo(
      Network network, NetworkChannel channel, String userNick,
      {bool waitForResult: false});

  Future<RequestResult<RegularMessage>> printNetworkChannelBannedUsers(
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

  Future<RequestResult<RegularMessage>> sendNetworkChannelRawMessage(
      Network network, NetworkChannel channel, String rawMessage,
      {bool waitForResult: false});
}

abstract class ChatInputOutputBackendService
    implements ChatInputBackendService, ChatOutputBackendService {

}

ChatNetworkPreferences createDefaultNetworkPreferences(
    BuildContext context)
{
  var backendService =
  Provider.of<ChatOutputBackendService>(context);
  var chatConfig = backendService.chatConfig;
  var channels = chatConfig.defaultChannels;

  return ChatNetworkPreferences(
      chatConfig.defaultNetwork, [
    ChatNetworkChannelPreferences.name(name: channels, password: "")
  ]);
}
