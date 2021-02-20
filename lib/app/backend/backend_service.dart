import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

typedef void NetworkListener(NetworkWithState network);
typedef void NetworkConnectionListener(NetworkPreferences networkPreferences);
typedef void NetworkStateListener(NetworkState networkState);
typedef void ChannelListener(ChannelWithState channel);
typedef void ChannelStateListener(ChannelState channelState);
typedef void ChannelMessageListener(MessagesForChannel messagesForChannel);
typedef void ChannelMessagePreviewListener(
    MessagePreviewForRemoteMessageId previewForMessage);

abstract class ChatBackendService implements Providable {
  Stream<ChatConnectionState> get connectionStateStream;

  bool get isConnected;

  Stream<bool> get isConnectedStream;

  ChatConnectionState get connectionState;

  ChatConfig get chatConfig;

  Stream<ChatConfig> get chatConfigStream;

  Stream<bool> get isChatConfigExistStream;

  ChatInitInformation get chatInit;

  bool get isReadyToConnect;

  Future<RequestResult<ChatLoginResult>> connectChat();

  Future<RequestResult<bool>> disconnectChat({
    bool waitForResult = false,
  });

  Future<RequestResult<ChatInitInformation>> authAfterReconnect({
    @required String token,
    @required int activeChannelId,
    @required int lastMessageId,
    @required String user,
    bool waitForResult = false,
  });

  Future<RequestResult<NetworkWithState>> joinNetwork(
    NetworkPreferences preferences, {
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> leaveNetwork(
    Network network, {
    bool waitForResult = false,
  });

  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
    Network network, {
    bool waitForResult = false,
  });

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(
    Network network, {
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> enableNetwork(
    Network network, {
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> disableNetwork(
    Network network, {
    bool waitForResult = false,
  });

  Future<RequestResult<Network>> editNetworkSettings(
    Network network,
    NetworkPreferences preferences, {
    bool waitForResult = false,
  });

  Future<RequestResult<ChannelWithState>> joinChannel(
    Network network,
    ChannelPreferences preferences, {
    bool waitForResult = false,
  });

  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel(
    Network network,
    Channel channel,
    String nick, {
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> leaveChannel(
    Network network,
    Channel channel, {
    bool waitForResult = false,
  });

  Future<RequestResult<ChannelUser>> requestUserInfo(
    Network network,
    Channel channel,
    String userNick, {
    bool waitForResult = false,
  });

  Future<RequestResult<RegularMessage>> printChannelBannedUsers(
    Network network,
    Channel channel, {
    bool waitForResult = false,
  });

  Future<RequestResult<List<ChannelUser>>> requestChannelUsers(
    Network network,
    Channel channel, {
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> editChannelTopic(
    Network network,
    Channel channel,
    String newTopic, {
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> sendChannelOpenedEventToServer(
    Network network,
    Channel channel,
  );

  Future<RequestResult<bool>> sendDevicePushFCMTokenToServer(
    String newToken, {
    bool waitForResult = false,
  });

  Future<RequestResult<RegularMessage>> sendChannelRawMessage(
    Network network,
    Channel channel,
    String rawMessage, {
    bool waitForResult = false,
  });

  Future<RequestResult<ToggleMessagePreviewData>> togglePreview(
    Network network,
    Channel channel,
    RegularMessage message,
    MessagePreview preview,
  );

  Future<RequestResult<MessageListLoadMore>> loadMoreHistory(
    Network network,
    Channel channel,
    int lastMessageId,
  );

  Future<RequestResult<String>> uploadFile(
    File file,
  );

  Disposable listenForNetworkState(
    Network network,
    NetworkState Function() currentStateExtractor,
    NetworkStateListener listener,
  );

  Disposable listenForNetworkJoin(
    NetworkListener listener,
  );

  Disposable listenForNetworkLeave(
    Network network,
    VoidCallback listener,
  );

  Disposable listenForNetworkEdit(
    Network network,
    NetworkConnectionListener listener,
  );

  Disposable listenForChannelJoin(
    Network network,
    ChannelListener listener,
  );

  Disposable listenForChannelLeave(
    Network network,
    Channel channel,
    VoidCallback listener,
  );

  Disposable listenForChannelState(
    Network network,
    Channel channel,
    ChannelState Function() currentStateExtractor,
    Future<int> Function() currentMessageCountExtractor,
    ChannelStateListener listener,
  );

  Disposable listenForChannelNames(
    Network network,
    Channel channel,
    Function(List<ChannelUser>) listener,
  );

  Disposable listenForChannelUsers(
    Network network,
    Channel channel,
    VoidCallback listener,
  );

  Disposable listenForMessages(
    Network network,
    Channel channel,
    ChannelMessageListener listener,
  );

  Disposable listenForMessagePreviews(
    Network network,
    Channel channel,
    ChannelMessagePreviewListener listener,
  );

  Disposable listenForMessagePreviewToggle(
    Network network,
    Channel channel,
    Function(ToggleMessagePreviewData) callback,
  );

  Disposable listenForChannelPreviewToggle(
    Network network,
    Channel channel,
    Function(ToggleChannelPreviewData) callback,
  );
}
