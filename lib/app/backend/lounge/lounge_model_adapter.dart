import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/preview/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/special/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/url/url_finder.dart';

var _logger = MyLogger(logTag: "lounge_model_adapter.dart", enabled: true);

Future<ChatInitInformation> toChatInitInformation(
    InitLoungeResponseBody parsed) async {
  var loungeNetworks = parsed.networks;
  var networksWithState = <NetworkWithState>[];
  for (var loungeNetwork in loungeNetworks) {
    networksWithState.add(await toNetworkWithState(loungeNetwork));
  }
  int activeChannelRemoteId = parsed.active;
  var isUndefinedActiveId =
      activeChannelRemoteId == InitLoungeResponseBody.undefinedActiveID;
  if (isUndefinedActiveId) {
    activeChannelRemoteId = null;
  }
  return ChatInitInformation.name(
      activeChannelRemoteId: activeChannelRemoteId,
      networksWithState: networksWithState);
}

ChatConfig toChatConfig(
        ConfigurationLoungeResponseBody loungeConfig, List<String> commands) =>
    ChatConfig.name(
        defaultNetwork: ChatNetworkConnectionPreferences(
            serverPreferences: ChatNetworkServerPreferences(
                name: loungeConfig.defaults.name,
                serverHost: loungeConfig.defaults.host,
                serverPort: loungeConfig.defaults.port.toString(),
                useTls: loungeConfig.defaults.tls,
                useOnlyTrustedCertificates:
                    loungeConfig.defaults.rejectUnauthorized),
            userPreferences: ChatNetworkUserPreferences(
                nickname: loungeConfig.defaults.nick,
                realName: loungeConfig.defaults.realname,
                username: loungeConfig.defaults.username,
                password: loungeConfig.defaults.password,
                commands: null)),
        defaultChannels: loungeConfig.defaults.join,
        fileUpload: loungeConfig.fileUpload,
        displayNetwork: loungeConfig.displayNetwork,
        lockNetwork: loungeConfig.lockNetwork,
        ldapEnabled: loungeConfig.ldapEnabled,
        prefetch: loungeConfig.prefetch,
        public: loungeConfig.public,
        useHexIp: loungeConfig.useHexIp,
        fileUploadMaxSizeInBytes: loungeConfig.fileUploadMaxFileSize,
        commands: commands);

Future<ChatMessage> toChatMessage(
    NetworkChannel channel, MsgLoungeResponseBody msgLoungeResponseBody) async {
  var regularMessageType = detectRegularMessageType(msgLoungeResponseBody.type);

  if (regularMessageType == RegularMessageType.WHO_IS) {
    return await toWhoIsSpecialMessage(channel, msgLoungeResponseBody);
  } else {
    var isCTCP = regularMessageType == RegularMessageType.CTCP_REQUEST;
    var text =
        isCTCP ? msgLoungeResponseBody.ctcpMessage : msgLoungeResponseBody.text;

    var linksInMessage = await findUrls([text, msgLoungeResponseBody.command]);

    return RegularMessage.name(
      channel.remoteId,
      command: msgLoungeResponseBody.command,
      hostMask: msgLoungeResponseBody.hostmask,
      text: text,
      regularMessageType: regularMessageType,
      self: msgLoungeResponseBody.self,
      highlight: msgLoungeResponseBody.highlight,
      params: msgLoungeResponseBody.params,
      previews: msgLoungeResponseBody.previews != null
          ? msgLoungeResponseBody.previews
              .map((loungePreview) => toMessagePreview(loungePreview))
              .toList()
          : null,
      date: DateTime.parse(msgLoungeResponseBody.time),
      fromNick: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.nick
          : null,
      fromRemoteId: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.id
          : null,
      fromMode: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.mode
          : null,
      newNick: msgLoungeResponseBody.new_nick,
      messageRemoteId: msgLoungeResponseBody.id,
      nicknames: msgLoungeResponseBody.users != null
          ? msgLoungeResponseBody.users
          : null,
      linksInText: linksInMessage,
    );
  }
}

Future<SpecialMessage> toWhoIsSpecialMessage(
    NetworkChannel channel, MsgLoungeResponseBody msgLoungeResponseBody) async {
  var whoIsSpecialBody = toWhoIsSpecialMessageBody(msgLoungeResponseBody.whois);

  var linksInMessage = await findUrls([
    whoIsSpecialBody.actualHostname,
    whoIsSpecialBody.realName,
    whoIsSpecialBody.account,
    whoIsSpecialBody.server,
    whoIsSpecialBody.serverInfo
  ]);

  return SpecialMessage.name(
      channelRemoteId: channel.remoteId,
      data: whoIsSpecialBody,
      specialType: SpecialMessageType.WHO_IS,
      date: DateTime.now(),
      linksInMessage: linksInMessage);
}

// Return list instead of one message
// because lounge SpecialMessageType.CHANNELS_LIST_ITEM message
// contains several ChatSpecialMessages
Future<List<SpecialMessage>> toSpecialMessages(NetworkChannel channel,
    MessageSpecialLoungeResponseBody messageSpecialLoungeResponseBody) async {
  var messageType =
      detectSpecialMessageType(messageSpecialLoungeResponseBody.data);

  if (messageType == SpecialMessageType.TEXT) {
    return [
      await toTextSpecialMessage(
          messageSpecialLoungeResponseBody, channel, messageType)
    ];
  } else if (messageType == SpecialMessageType.CHANNELS_LIST_ITEM) {
    return await toChannelsListSpecialMessages(
        messageSpecialLoungeResponseBody, channel, messageType);
  } else {
    throw Exception("Invalid special message type $messageType");
  }
}

Future<List<SpecialMessage>> toChannelsListSpecialMessages(
    MessageSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
    NetworkChannel channel,
    SpecialMessageType messageType) async {
  var iterable = messageSpecialLoungeResponseBody.data as Iterable;

  var specialMessages = <SpecialMessage>[];

  for (var item in iterable) {
    var loungeChannelItem =
        ChannelListItemSpecialMessageLoungeResponseBodyPart.fromJson(item);
    var networkChannelInfoSpecialMessageBody =
        NetworkChannelInfoSpecialMessageBody(loungeChannelItem.channel,
            loungeChannelItem.topic, loungeChannelItem.num_users);

    var linksInMessage =
        await findUrls([networkChannelInfoSpecialMessageBody.topic]);
    specialMessages.add(SpecialMessage.name(
        data: networkChannelInfoSpecialMessageBody,
        channelRemoteId: channel.remoteId,
        specialType: messageType,
        date: DateTime.now(),
        linksInMessage: linksInMessage));
  }

  return specialMessages;
}

Future<SpecialMessage> toTextSpecialMessage(
    MessageSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
    NetworkChannel channel,
    SpecialMessageType messageType) async {
  var textMessage = TextSpecialMessageLoungeResponseBodyPart.fromJson(
      messageSpecialLoungeResponseBody.data);

  var linksInMessage = await findUrls([textMessage.text]);

  return SpecialMessage.name(
      data: TextSpecialMessageBody(textMessage.text),
      channelRemoteId: channel.remoteId,
      specialType: messageType,
      date: DateTime.now(),
      linksInMessage: linksInMessage);
}

// Lounge don't provide type field in response
// Detect type by data schema
SpecialMessageType detectSpecialMessageType(data) {
  var isMap = data is Map;
  var isIterable = data is Iterable;

  if (isMap) {
    var map = data as Map;
    TextSpecialMessageLoungeResponseBodyPart textMessage;
    try {
      textMessage = TextSpecialMessageLoungeResponseBodyPart.fromJson(map);
    } on Exception catch (e) {
      _logger.e(() => "error during detecting text special message $e");
    }

    if (textMessage != null && textMessage.text != null) {
      return SpecialMessageType.TEXT;
    } else {
      throw Exception("Invalid special message data = $data");
    }
  } else {
    if (isIterable) {
      var iterable = data as Iterable;
      var first = iterable.first;

      ChannelListItemSpecialMessageLoungeResponseBodyPart channelListItem;
      try {
        channelListItem =
            ChannelListItemSpecialMessageLoungeResponseBodyPart.fromJson(first);
      } on Exception catch (e) {
        _logger.e(() => "error during detecting text special message $e");
      }

      if (channelListItem != null && channelListItem.channel != null) {
        return SpecialMessageType.CHANNELS_LIST_ITEM;
      } else {
        throw Exception("Invalid special message data = $data");
      }
    } else {
      throw Exception("Invalid special message data = $data");
    }
  }
}

NetworkChannelType detectNetworkChannelType(String typeString) {
  var type = NetworkChannelType.UNKNOWN;
  switch (typeString) {
    case LoungeChannelTypeConstants.lobby:
      type = NetworkChannelType.LOBBY;
      break;
    case LoungeChannelTypeConstants.special:
      type = NetworkChannelType.SPECIAL;
      break;
    case LoungeChannelTypeConstants.query:
      type = NetworkChannelType.QUERY;
      break;
    case LoungeChannelTypeConstants.channel:
      type = NetworkChannelType.CHANNEL;
      break;
  }
  return type;
}

NetworkChannelState toNetworkChannelState(
    ChannelLoungeResponseBody loungeChannel, NetworkChannelType type) {
  // Private and special messages are always connected, but lounge sometimes
  // don't provide connected state for them
  var isConnected =
      type == NetworkChannelType.QUERY || type == NetworkChannelType.SPECIAL
          ? true
          : loungeChannel.state == LoungeConstants.CHANNEL_STATE_CONNECTED;
  return NetworkChannelState.name(
      topic: loungeChannel.topic,
      firstUnreadRemoteMessageId: loungeChannel.firstUnread,
      editTopicPossible: loungeChannel.editTopic,
      unreadCount: loungeChannel.unread,
      connected: isConnected,
      highlighted: loungeChannel.highlight != null,
      moreHistoryAvailable: loungeChannel.moreHistoryAvailable);
}

NetworkState toNetworkState(NetworkStatusLoungeResponseBody loungeNetworkStatus,
        String nick, String name) =>
    NetworkState.name(
        connected: loungeNetworkStatus.connected,
        secure: loungeNetworkStatus.secure,
        nick: nick,
        name: name);

Future<ChatLoadMoreData> toChatLoadMore(NetworkChannel channel,
    MoreLoungeResponseBody moreLoungeResponseBody) async {
  var messages = <ChatMessage>[];

  for (var loungeMessage in moreLoungeResponseBody.messages) {
    messages.add(await toChatMessage(channel, loungeMessage));
  }

  return ChatLoadMoreData.name(
      messages: messages,
      moreHistoryAvailable: moreLoungeResponseBody.moreHistoryAvailable);
}

RegularMessageType detectRegularMessageType(String stringType) {
  var type;
  switch (stringType) {
    case LoungeMessageTypeConstants.unhandled:
      type = RegularMessageType.UNHANDLED;
      break;
    case LoungeMessageTypeConstants.topicSetBy:
      type = RegularMessageType.TOPIC_SET_BY;
      break;
    case LoungeMessageTypeConstants.topic:
      type = RegularMessageType.TOPIC;
      break;
    case LoungeMessageTypeConstants.message:
      type = RegularMessageType.MESSAGE;
      break;
    case LoungeMessageTypeConstants.join:
      type = RegularMessageType.JOIN;
      break;
    case LoungeMessageTypeConstants.mode:
      type = RegularMessageType.MODE;
      break;
    case LoungeMessageTypeConstants.motd:
      type = RegularMessageType.MODE;
      break;
    case LoungeMessageTypeConstants.whois:
      type = RegularMessageType.WHO_IS;
      break;
    case LoungeMessageTypeConstants.notice:
      type = RegularMessageType.NOTICE;
      break;
    case LoungeMessageTypeConstants.error:
      type = RegularMessageType.ERROR;
      break;
    case LoungeMessageTypeConstants.away:
      type = RegularMessageType.AWAY;
      break;

    case LoungeMessageTypeConstants.back:
      type = RegularMessageType.BACK;
      break;
    case LoungeMessageTypeConstants.raw:
      type = RegularMessageType.RAW;
      break;
    case LoungeMessageTypeConstants.modeChannel:
      type = RegularMessageType.MODE_CHANNEL;
      break;

    case LoungeMessageTypeConstants.quit:
      type = RegularMessageType.QUIT;
      break;

    case LoungeMessageTypeConstants.part:
      type = RegularMessageType.PART;
      break;

    case LoungeMessageTypeConstants.nick:
      type = RegularMessageType.NICK;
      break;
    case LoungeMessageTypeConstants.ctcpRequest:
      type = RegularMessageType.CTCP_REQUEST;
      break;

    default:
      type = RegularMessageType.UNKNOWN;
  }

  return type;
}

NetworkNewLoungeRequestBody toNetworkNewLoungeRequestBody(
    ChatNetworkUserPreferences userPreferences,
    String join,
    ChatNetworkServerPreferences serverPreferences) {
  return NetworkNewLoungeRequestBody(
    username: userPreferences.username,
    nick: userPreferences.nickname,
    join: join,
    realname: userPreferences.realName,
    password: userPreferences.password,
    host: serverPreferences.serverHost,
    port: serverPreferences.serverPort,
    rejectUnauthorized:
        toLoungeBoolean(serverPreferences.useOnlyTrustedCertificates),
    tls: toLoungeBoolean(serverPreferences.useTls),
    name: serverPreferences.name,
  );
}

String toLoungeBoolean(bool boolValue) {
  return boolValue != null
      ? boolValue ? LoungeConstants.on : LoungeConstants.off
      : null;
}

NetworkEditLoungeRequestBody toNetworkEditLoungeRequestBody(
    String remoteId,
    ChatNetworkUserPreferences userPreferences,
    ChatNetworkServerPreferences serverPreferences) {
  return NetworkEditLoungeRequestBody(
    username: userPreferences.username,
    nick: userPreferences.nickname,
    realname: userPreferences.realName,
    password: userPreferences.password,
    host: serverPreferences.serverHost,
    port: serverPreferences.serverPort,
    rejectUnauthorized:
    toLoungeBoolean(serverPreferences.useOnlyTrustedCertificates),
    tls: toLoungeBoolean(serverPreferences.useTls),
    name: serverPreferences.name,
    uuid: remoteId,
    commands: userPreferences.commands,
  );
}

WhoIsSpecialMessageBody toWhoIsSpecialMessageBody(
        WhoIsLoungeResponseBodyPart loungeWhoIs) =>
    WhoIsSpecialMessageBody.name(
        account: loungeWhoIs.account,
        channels: loungeWhoIs.channels,
        hostname: loungeWhoIs.hostname,
        ident: loungeWhoIs.ident,
        idle: loungeWhoIs.idle,
        idleTime: DateTime.fromMillisecondsSinceEpoch(loungeWhoIs.idleTime),
        logonTime: DateTime.fromMillisecondsSinceEpoch(loungeWhoIs.logonTime),
        logon: loungeWhoIs.logon,
        nick: loungeWhoIs.nick,
        realName: loungeWhoIs.real_name,
        secure: loungeWhoIs.secure,
        server: loungeWhoIs.server,
        serverInfo: loungeWhoIs.server_info,
        actualHostname: loungeWhoIs.actual_hostname,
        actualIp: loungeWhoIs.actual_ip);

MessagePreview toMessagePreview(
        MsgPreviewLoungeResponseBodyPart loungePreview) =>
    MessagePreview.name(
        head: loungePreview.head,
        body: loungePreview.body,
        canDisplay: loungePreview.canDisplay,
        shown: loungePreview.shown,
        link: loungePreview.link,
        thumb: loungePreview.thumb,
        type: detectMessagePreviewType(loungePreview.type),
        media: loungePreview.media,
        mediaType: loungePreview.mediaType);

MessagePreviewType detectMessagePreviewType(String type) {
  switch (type) {
    case LoungeResponseMessagePreviewType.image:
      return MessagePreviewType.IMAGE;
      break;
    case LoungeResponseMessagePreviewType.link:
      return MessagePreviewType.LINK;
      break;
    case LoungeResponseMessagePreviewType.loading:
      return MessagePreviewType.LOADING;
      break;
    case LoungeResponseMessagePreviewType.audio:
      return MessagePreviewType.AUDIO;
      break;
    case LoungeResponseMessagePreviewType.video:
      return MessagePreviewType.VIDEO;
      break;
  }

  throw Exception("Invalid MessagePreviewType type $type");
}

Future<NetworkChannelWithState> toNetworkChannelWithState(
    ChannelLoungeResponseBody loungeChannel) async {
  var channel = NetworkChannel(
      ChatNetworkChannelPreferences.name(
          name: loungeChannel.name,
          // Network channels which exists on network join doesn't use passwords
          password: ""),
      detectNetworkChannelType(loungeChannel.type),
      loungeChannel.id);
  var channelState = toNetworkChannelState(loungeChannel, channel.type);

  var initMessages = <ChatMessage>[];
  if (loungeChannel.messages != null) {
    for (var loungeMessage in loungeChannel.messages) {
      initMessages.add(await toChatMessage(channel, loungeMessage));
    }
  }

  var initUsers = loungeChannel.users
      ?.map((loungeUser) => toNetworkChannelUser(loungeUser))
      ?.toList();
  var networkChannelWithState =
      NetworkChannelWithState(channel, channelState, initMessages, initUsers);
  return networkChannelWithState;
}

NetworkChannelUser toNetworkChannelUser(UserLoungeResponseBodyPart loungeUser) {
  return NetworkChannelUser.name(nick: loungeUser.nick, mode: loungeUser.mode);
}

Future<NetworkWithState> toNetworkWithState(
    NetworkLoungeResponseBody loungeNetwork) async {
  var channelsWithState = <NetworkChannelWithState>[];

  for (var loungeChannel in loungeNetwork.channels) {
    channelsWithState.add(await toNetworkChannelWithState(loungeChannel));
  }

  var channels = channelsWithState
      .map((channelWithState) => channelWithState.channel)
      .toList();

  var nick = loungeNetwork.nick;
  ChatNetworkConnectionPreferences connectionPreferences =
      ChatNetworkConnectionPreferences(
          serverPreferences: ChatNetworkServerPreferences(
              name: loungeNetwork.name,
              serverHost: loungeNetwork.host,
              serverPort: loungeNetwork.port.toString(),
              useTls: loungeNetwork.tls,
              useOnlyTrustedCertificates: loungeNetwork.rejectUnauthorized),
          userPreferences: ChatNetworkUserPreferences(
              nickname: nick,
              password: null,
              commands: null,
              realName: loungeNetwork.realname,
              username: loungeNetwork.username));
  var network = Network(connectionPreferences, loungeNetwork.uuid, channels);

  var loungeNetworkStatus = loungeNetwork.status;

  var networkState = toNetworkState(loungeNetworkStatus, nick, network.name);

  // TODO: open ticket for lounge
  // Strange field, it should be inside networkStatus.
  // Sometimes network status connected == false but network actually connected
  networkState.connected = !loungeNetwork.userDisconnected;

  var networkWithState =
      NetworkWithState(network, networkState, channelsWithState);
  return networkWithState;
}
