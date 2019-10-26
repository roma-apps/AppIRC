import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/state/chat_connection_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/preview/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/special/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

typedef NetworkListener(NetworkWithState network);
typedef NetworkConnectionListener(ChatNetworkPreferences networkPreferences);
typedef NetworkStateListener(NetworkState networkState);
typedef NetworkChannelListener(NetworkChannelWithState channel);
typedef NetworkChannelStateListener(NetworkChannelState channelState);
typedef NetworkChannelMessageListener(ChatMessage message);
typedef NetworkChannelMessagePreviewListener(
    PreviewForMessage previewForMessage);

abstract class ChatBackendService implements Providable {
  Stream<ChatConnectionState> get connectionStateStream;

  bool get isConnected;
  Stream<bool> get isConnectedStream;

  ChatConnectionState get connectionState;

  ChatConfig get chatConfig;

  Stream<ChatConfig> get chatConfigStream;

  Stream<bool> get chatConfigExistStream;

  ChatInitInformation get chatInit;

  bool get isReadyToConnect;

  Future<RequestResult<ConnectResult>> connectChat();

  Future<RequestResult<bool>> disconnectChat({bool waitForResult: false});

  Future<RequestResult<NetworkWithState>> joinNetwork(
      ChatNetworkPreferences preferences,
      {bool waitForResult: false});

  Future<RequestResult<bool>> leaveNetwork(Network network,
      {bool waitForResult: false});

  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
      Network network,
      {bool waitForResult: false});

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(Network network,
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

  Future<RequestResult<NetworkChannelUser>> requestUserInfo(
      Network network, NetworkChannel channel, String userNick,
      {bool waitForResult: false});

  Future<RequestResult<RegularMessage>> printNetworkChannelBannedUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult: false});

  Future<RequestResult<List<NetworkChannelUser>>> requestNetworkChannelUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult: false});

  Future<RequestResult<bool>> editNetworkChannelTopic(
      Network network, NetworkChannel channel, String newTopic,
      {bool waitForResult: false});

  Future<RequestResult<bool>> sendChannelOpenedEventToServer(
      Network network, NetworkChannel channel);

  Future<RequestResult<bool>> sendDevicePushFCMTokenToServer(String newToken,
      {bool waitForResult: false});

  Future<RequestResult<RegularMessage>> sendNetworkChannelRawMessage(
      Network network, NetworkChannel channel, String rawMessage,
      {bool waitForResult: false});

  Future<RequestResult<MessageTogglePreview>> togglePreview(Network network,
      NetworkChannel channel, RegularMessage message, MessagePreview preview);

  Future<RequestResult<ChatLoadMoreData>> loadMoreHistory(
      Network network, NetworkChannel channel, int lastMessageId);

  Future<RequestResult<String>> uploadFile(File file);

  Disposable listenForNetworkState(
      Network network,
      NetworkState Function() currentStateExtractor,
      NetworkStateListener listener);

  Disposable listenForNetworkJoin(NetworkListener listener);

  Disposable listenForNetworkLeave(Network network, VoidCallback listener);

  Disposable listenForNetworkEdit(
      Network network, NetworkConnectionListener listener);

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
      NetworkChannel channel, Function(List<NetworkChannelUser>) listener);

  Disposable listenForNetworkChannelUsers(
      Network network, NetworkChannel channel, VoidCallback listener);

  Disposable listenForMessages(Network network, NetworkChannel channel,
      NetworkChannelMessageListener listener);

  Disposable listenForMessagePreviews(Network network, NetworkChannel channel,
      NetworkChannelMessagePreviewListener listener);

  Disposable listenForMessagePreviewToggle(Network network,
      NetworkChannel channel, Function(MessageTogglePreview) callback);

  Disposable listenForChannelPreviewToggle(Network network,
      NetworkChannel channel, Function(ChannelTogglePreview) callback);
}

ChatNetworkPreferences createDefaultNetworkPreferences(BuildContext context) {
  var backendService = Provider.of<ChatBackendService>(context);
  var chatConfig = backendService.chatConfig;
  var channels = chatConfig.defaultChannels;

  return ChatNetworkPreferences(chatConfig.defaultNetwork,
      [ChatNetworkChannelPreferences.name(name: channels, password: "")]);
}
