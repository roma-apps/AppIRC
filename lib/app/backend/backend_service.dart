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
import 'package:flutter_appirc/lounge/lounge_response_model.dart';

typedef void NetworkListener(NetworkWithState network);
typedef void NetworkConnectionListener(NetworkPreferences networkPreferences);
typedef void NetworkStateListener(NetworkState networkState);
typedef void ChannelListener(ChannelWithState channel);
typedef void ChannelStateListener(ChannelState channelState);
typedef void ChannelMessageListener(MessagesForChannel messagesForChannel);
typedef void ChannelMessagePreviewListener(
    MessagePreviewForRemoteMessageId previewForMessage);

abstract class ChatBackendService implements IDisposable {
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

  Future<NetworkLoungeResponseBodyPart> getNetworkInfo({@required String uuid});

  Future<RequestResult<NetworkWithState>> joinNetwork({
    @required NetworkPreferences networkPreferences,
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> leaveNetwork({
    @required Network network,
    bool waitForResult = false,
  });

  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels({
    @required Network network,
    bool waitForResult = false,
  });

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers({
    @required Network network,
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> enableNetwork({
    @required Network network,
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> disableNetwork({
    @required Network network,
    bool waitForResult = false,
  });

  Future<RequestResult<Network>> editNetworkSettings({
    @required Network network,
    @required NetworkPreferences networkPreferences,
    bool waitForResult = false,
  });

  Future<RequestResult<ChannelWithState>> joinChannel({
    @required Network network,
    @required ChannelPreferences channelPreferences,
    bool waitForResult = false,
  });

  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel({
    @required Network network,
    @required Channel channel,
    @required String nick,
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> leaveChannel({
    @required Network network,
    @required Channel channel,
    bool waitForResult = false,
  });

  Future<RequestResult<ChannelUser>> requestUserInfo({
    @required Network network,
    @required Channel channel,
    @required String userNick,
    bool waitForResult = false,
  });

  Future<RequestResult<RegularMessage>> printChannelBannedUsers({
    @required Network network,
    @required Channel channel,
    bool waitForResult = false,
  });

  Future<RequestResult<List<ChannelUser>>> requestChannelUsers({
    @required Network network,
    @required Channel channel,
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> editChannelTopic({
    @required Network network,
    @required Channel channel,
    @required String newTopic,
    bool waitForResult = false,
  });

  Future<RequestResult<bool>> sendChannelOpenedEventToServer({
    @required Network network,
    @required Channel channel,
  });

  Future<RequestResult<bool>> sendDevicePushFCMTokenToServer({
    @required String newToken,
    bool waitForResult = false,
  });

  Future<RequestResult<RegularMessage>> sendChannelRawMessage({
    @required Network network,
    @required Channel channel,
    @required String rawMessage,
    bool waitForResult = false,
  });

  Future<RequestResult<ToggleMessagePreviewData>> togglePreview({
    @required Network network,
    @required Channel channel,
    @required RegularMessage message,
    @required MessagePreview preview,
  });

  Future<RequestResult<MessageListLoadMore>> loadMoreHistory({
    @required Network network,
    @required Channel channel,
    @required int lastMessageId,
  });

  Future<RequestResult<String>> uploadFile({
    @required File file,
  });

  IDisposable listenForNetworkState({
    @required Network network,
    @required NetworkState Function() currentStateExtractor,
    @required NetworkStateListener listener,
  });

  IDisposable listenForNetworkJoin({
    @required NetworkListener listener,
  });

  IDisposable listenForNetworkLeave({
    @required Network network,
    @required VoidCallback listener,
  });

  IDisposable listenForNetworkEdit({
    @required Network network,
    @required NetworkConnectionListener listener,
  });

  IDisposable listenForChannelJoin({
    @required Network network,
    @required ChannelListener listener,
  });

  IDisposable listenForChannelLeave({
    @required Network network,
    @required Channel channel,
    @required VoidCallback listener,
  });

  IDisposable listenForChannelState({
    @required Network network,
    @required Channel channel,
    @required ChannelState Function() currentStateExtractor,
    @required Future<int> Function() currentMessageCountExtractor,
    @required ChannelStateListener listener,
  });

  IDisposable listenForChannelNames({
    @required Network network,
    @required Channel channel,
    @required Function(List<ChannelUser>) listener,
  });

  IDisposable listenForChannelUsers({
    @required Network network,
    @required Channel channel,
    @required VoidCallback listener,
  });

  IDisposable listenForMessages({
    @required Network network,
    @required Channel channel,
    @required ChannelMessageListener listener,
  });

  IDisposable listenForMessagePreviews({
    @required Network network,
    @required Channel channel,
    @required ChannelMessagePreviewListener listener,
  });

  IDisposable listenForMessagePreviewToggle({
    @required Network network,
    @required Channel channel,
    @required Function(ToggleMessagePreviewData) listener,
  });

  IDisposable listenForChannelPreviewToggle({
    @required Network network,
    @required Channel channel,
    @required Function(ToggleChannelPreviewData) listener,
  });
}
