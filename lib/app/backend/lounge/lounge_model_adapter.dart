import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
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
        defaultNetwork: NetworkConnectionPreferences(
            serverPreferences: NetworkServerPreferences(
                name: loungeConfig.defaults.name,
                serverHost: loungeConfig.defaults.host,
                serverPort: loungeConfig.defaults.port.toString(),
                useTls: loungeConfig.defaults.tls,
                useOnlyTrustedCertificates:
                    loungeConfig.defaults.rejectUnauthorized),
            userPreferences: NetworkUserPreferences(
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

Future<ChatMessage> toChatMessage(Channel channel,
    MsgLoungeResponseBodyPart msgLoungeResponseBody) async {
  var regularMessageType = detectRegularMessageType(msgLoungeResponseBody.type);

  if (regularMessageType == RegularMessageType.whoIs) {
    return await toWhoIsSpecialMessage(channel, msgLoungeResponseBody);
  } else {
    var isCTCP = regularMessageType == RegularMessageType.ctcpRequest;
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

Future<SpecialMessage> toWhoIsSpecialMessage(Channel channel,
    MsgLoungeResponseBodyPart msgLoungeResponseBody) async {
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
      specialType: SpecialMessageType.whoIs,
      date: DateTime.now(),
      linksInMessage: linksInMessage);
}

// Return list instead of one message
// because lounge SpecialMessageType.CHANNELS_LIST_ITEM message
// contains several ChatSpecialMessages
Future<List<SpecialMessage>> toSpecialMessages(Channel channel,
    MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody) async {
  var messageType =
      detectSpecialMessageType(messageSpecialLoungeResponseBody.data);

  if (messageType == SpecialMessageType.text) {
    return [
      await toTextSpecialMessage(
          messageSpecialLoungeResponseBody, channel, messageType)
    ];
  } else if (messageType == SpecialMessageType.channelsListItem) {
    return await toChannelsListSpecialMessages(
        messageSpecialLoungeResponseBody, channel, messageType);
  } else {
    throw Exception("Invalid special message type $messageType");
  }
}

Future<List<SpecialMessage>> toChannelsListSpecialMessages(
    MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
    Channel channel,
    SpecialMessageType messageType) async {
  var iterable = messageSpecialLoungeResponseBody.data as Iterable;

  var specialMessages = <SpecialMessage>[];

  for (var item in iterable) {
    var loungeChannelItem =
        ChannelListItemSpecialMessageLoungeResponseBodyPart.fromJson(item);
    var channelInfoSpecialMessageBody =
        ChannelInfoSpecialMessageBody(loungeChannelItem.channel,
            loungeChannelItem.topic, loungeChannelItem.num_users);

    var linksInMessage =
        await findUrls([channelInfoSpecialMessageBody.topic]);
    specialMessages.add(SpecialMessage.name(
        data: channelInfoSpecialMessageBody,
        channelRemoteId: channel.remoteId,
        specialType: messageType,
        date: DateTime.now(),
        linksInMessage: linksInMessage));
  }

  return specialMessages;
}

Future<SpecialMessage> toTextSpecialMessage(
    MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
    Channel channel,
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
      return SpecialMessageType.text;
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
        return SpecialMessageType.channelsListItem;
      } else {
        throw Exception("Invalid special message data = $data");
      }
    } else {
      throw Exception("Invalid special message data = $data");
    }
  }
}

ChannelType detectChannelType(String typeString) {
  var type = ChannelType.unknown;
  switch (typeString) {
    case ChannelTypeLoungeConstants.lobby:
      type = ChannelType.lobby;
      break;
    case ChannelTypeLoungeConstants.special:
      type = ChannelType.special;
      break;
    case ChannelTypeLoungeConstants.query:
      type = ChannelType.query;
      break;
    case ChannelTypeLoungeConstants.channel:
      type = ChannelType.channel;
      break;
  }
  return type;
}

ChannelState toChannelState(
    ChannelLoungeResponseBodyPart loungeChannel, ChannelType type) {
  // Private and special messages are always connected, but lounge sometimes
  // don't provide connected state for them
  var isConnected =
      type == ChannelType.query || type == ChannelType.special
          ? true
          : loungeChannel.state == ChannelStateLoungeConstants.connected;
  return ChannelState.name(
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

Future<MessageListLoadMore> toChatLoadMore(Channel channel,
    MoreLoungeResponseBody moreLoungeResponseBody) async {
  var messages = <ChatMessage>[];

  for (var loungeMessage in moreLoungeResponseBody.messages) {
    messages.add(await toChatMessage(channel, loungeMessage));
  }

  return MessageListLoadMore.name(
      messages: messages,
      moreHistoryAvailable: moreLoungeResponseBody.moreHistoryAvailable);
}

RegularMessageType detectRegularMessageType(String stringType) {
  var type;
  switch (stringType) {
    case MessageTypeLoungeConstants.unhandled:
      type = RegularMessageType.unhandled;
      break;
    case MessageTypeLoungeConstants.topicSetBy:
      type = RegularMessageType.topicSetBy;
      break;
    case MessageTypeLoungeConstants.topic:
      type = RegularMessageType.topic;
      break;
    case MessageTypeLoungeConstants.message:
      type = RegularMessageType.message;
      break;
    case MessageTypeLoungeConstants.join:
      type = RegularMessageType.join;
      break;
    case MessageTypeLoungeConstants.mode:
      type = RegularMessageType.mode;
      break;
    case MessageTypeLoungeConstants.motd:
      type = RegularMessageType.mode;
      break;
    case MessageTypeLoungeConstants.whois:
      type = RegularMessageType.whoIs;
      break;
    case MessageTypeLoungeConstants.notice:
      type = RegularMessageType.notice;
      break;
    case MessageTypeLoungeConstants.error:
      type = RegularMessageType.error;
      break;
    case MessageTypeLoungeConstants.away:
      type = RegularMessageType.away;
      break;

    case MessageTypeLoungeConstants.back:
      type = RegularMessageType.back;
      break;
    case MessageTypeLoungeConstants.raw:
      type = RegularMessageType.raw;
      break;
    case MessageTypeLoungeConstants.modeChannel:
      type = RegularMessageType.modeChannel;
      break;

    case MessageTypeLoungeConstants.quit:
      type = RegularMessageType.quit;
      break;

    case MessageTypeLoungeConstants.part:
      type = RegularMessageType.part;
      break;

    case MessageTypeLoungeConstants.nick:
      type = RegularMessageType.nick;
      break;
    case MessageTypeLoungeConstants.ctcpRequest:
      type = RegularMessageType.ctcpRequest;
      break;

    default:
      type = RegularMessageType.unknown;
  }

  return type;
}

String toLoungeBoolean(bool boolValue) {
  return boolValue != null
      ? boolValue ? BooleanLoungeConstants.on : BooleanLoungeConstants.off
      : null;
}

NetworkEditLoungeJsonRequest toNetworkEditLoungeRequestBody(
    String remoteId,
    NetworkUserPreferences userPreferences,
    NetworkServerPreferences serverPreferences) {
  return NetworkEditLoungeJsonRequest.name(
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
    case MessagePreviewTypeLoungeResponse.image:
      return MessagePreviewType.image;
      break;
    case MessagePreviewTypeLoungeResponse.link:
      return MessagePreviewType.link;
      break;
    case MessagePreviewTypeLoungeResponse.loading:
      return MessagePreviewType.loading;
      break;
    case MessagePreviewTypeLoungeResponse.audio:
      return MessagePreviewType.audio;
      break;
    case MessagePreviewTypeLoungeResponse.video:
      return MessagePreviewType.video;
      break;
  }

  throw Exception("Invalid MessagePreviewType type $type");
}

Future<ChannelWithState> toChannelWithState(
    ChannelLoungeResponseBodyPart loungeChannel) async {
  var channel = Channel(
      ChannelPreferences.name(
          name: loungeChannel.name,
          // Network channels which exists on network join doesn't use passwords
          password: ""),
      detectChannelType(loungeChannel.type),
      loungeChannel.id);
  var channelState = toChannelState(loungeChannel, channel.type);

  var initMessages = <ChatMessage>[];
  if (loungeChannel.messages != null) {
    for (var loungeMessage in loungeChannel.messages) {
      initMessages.add(await toChatMessage(channel, loungeMessage));
    }
  }

  var initUsers = loungeChannel.users
      ?.map((loungeUser) => toChannelUser(loungeUser))
      ?.toList();
  var channelWithState =
      ChannelWithState(channel, channelState, initMessages, initUsers);
  return channelWithState;
}

ChannelUser toChannelUser(UserLoungeResponseBodyPart loungeUser) {
  return ChannelUser.name(nick: loungeUser.nick, mode: loungeUser.mode);
}

Future<NetworkWithState> toNetworkWithState(
    NetworkLoungeResponseBodyPart loungeNetwork) async {
  var channelsWithState = <ChannelWithState>[];

  for (var loungeChannel in loungeNetwork.channels) {
    channelsWithState.add(await toChannelWithState(loungeChannel));
  }

  var channels = channelsWithState
      .map((channelWithState) => channelWithState.channel)
      .toList();

  var nick = loungeNetwork.nick;
  NetworkConnectionPreferences connectionPreferences =
      NetworkConnectionPreferences(
          serverPreferences: NetworkServerPreferences(
              name: loungeNetwork.name,
              serverHost: loungeNetwork.host,
              serverPort: loungeNetwork.port.toString(),
              useTls: loungeNetwork.tls,
              useOnlyTrustedCertificates: loungeNetwork.rejectUnauthorized),
          userPreferences: NetworkUserPreferences(
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
