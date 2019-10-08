import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';

var _logger = MyLogger(logTag: "lounge_adapter", enabled: true);

ChatInitInformation toChatInit(InitLoungeResponseBody parsed) {
  return ChatInitInformation.name(
      activeChannelRemoteId:
          parsed.active == InitLoungeResponseBody.undefinedActiveID
              ? null
              : parsed.active,
      networksWithState: parsed.networks
          ?.map((loungeNetwork) => toNetworkWithState(loungeNetwork)));
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
        fileUploadMaxSize: loungeConfig.fileUploadMaxSize,
        commands: commands);

ChatMessage toChatMessage(
        NetworkChannel channel, MsgLoungeResponseBody msgLoungeResponseBody) =>
    RegularMessage.name(
      channel.remoteId,
      command: msgLoungeResponseBody.command,
      hostMask: msgLoungeResponseBody.hostmask,
      text: msgLoungeResponseBody.text,
      regularMessageType: detectRegularMessageType(msgLoungeResponseBody.type),
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
    );

List<SpecialMessage> toSpecialMessages(NetworkChannel channel,
    MessageSpecialLoungeResponseBody messageSpecialLoungeResponseBody) {
  var messageType =
      detectSpecialMessageType(messageSpecialLoungeResponseBody.data);

  if (messageType == SpecialMessageType.TEXT) {
    var textMessage = TextSpecialMessageLoungeResponseBodyPart.fromJson(
        messageSpecialLoungeResponseBody.data);
    return [
      SpecialMessage.name(
          data: TextSpecialMessageBody(textMessage.text),
          channelRemoteId: channel.remoteId,
          specialType: messageType,
          date: DateTime.now())
    ];
  } else if (messageType == SpecialMessageType.CHANNELS_LIST_ITEM) {
    var iterable = messageSpecialLoungeResponseBody.data as Iterable;

    var specialMessages = <SpecialMessage>[];

    iterable.forEach((item) {
      var loungeChannelItem =
          ChannelListItemSpecialMessageLoungeResponseBodyPart.fromJson(item);
      var networkChannelInfoSpecialMessageBody =
          NetworkChannelInfoSpecialMessageBody(loungeChannelItem.channel,
              loungeChannelItem.topic, loungeChannelItem.num_users);

      specialMessages.add(SpecialMessage.name(
          data: networkChannelInfoSpecialMessageBody,
          channelRemoteId: channel.remoteId,
          specialType: messageType,
          date: DateTime.now()));
    });

    return specialMessages;
  } else {
    throw Exception("Invalid special message type $messageType");
  }
}

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
        ChannelLoungeResponseBody loungeChannel) =>
    NetworkChannelState.name(
        topic: loungeChannel.topic,
        editTopicPossible: loungeChannel.editTopic,
        unreadCount: loungeChannel.unread,
        connected:
            loungeChannel.state == LoungeConstants.CHANNEL_STATE_CONNECTED,
        highlighted: loungeChannel.highlight != null);

NetworkState toNetworkState(NetworkStatusLoungeResponseBody loungeNetworkStatus,
        String nick, String name) =>
    NetworkState.name(
        connected: loungeNetworkStatus.connected,
        secure: loungeNetworkStatus.secure,
        nick: nick,
        name: name);

RegularMessageType detectRegularMessageType(String stringType) {
  var type;
  switch (stringType) {
    case "unhandled":
      type = RegularMessageType.UNHANDLED;
      break;
    case "topic_set_by":
      type = RegularMessageType.TOPIC_SET_BY;
      break;
    case "topic":
      type = RegularMessageType.TOPIC;
      break;
    case "message":
      type = RegularMessageType.MESSAGE;
      break;
    case "join":
      type = RegularMessageType.JOIN;
      break;
    case "mode":
      type = RegularMessageType.MODE;
      break;
    case "motd":
      type = RegularMessageType.MODE;
      break;
    case "whois":
      type = RegularMessageType.WHO_IS;
      break;
    case "notice":
      type = RegularMessageType.NOTICE;
      break;
    case "error":
      type = RegularMessageType.ERROR;
      break;
    case "away":
      type = RegularMessageType.AWAY;
      break;

    case "back":
      type = RegularMessageType.BACK;
      break;
    case "raw":
      type = RegularMessageType.RAW;
      break;
    case "mode_channel":
      type = RegularMessageType.MODE_CHANNEL;
      break;

    case "quit":
      type = RegularMessageType.QUIT;
      break;

    case "part":
      type = RegularMessageType.PART;
      break;

    case "nick":
      type = RegularMessageType.NICK;
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
    rejectUnauthorized: serverPreferences.useOnlyTrustedCertificates != null
        ? serverPreferences.useOnlyTrustedCertificates
            ? LoungeConstants.on
            : LoungeConstants.off
        : null,
    tls: serverPreferences.useTls != null
        ? serverPreferences.useTls ? LoungeConstants.on : LoungeConstants.off
        : null,
    name: serverPreferences.name,
  );
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
    rejectUnauthorized: serverPreferences.useOnlyTrustedCertificates != null
        ? serverPreferences.useOnlyTrustedCertificates
            ? LoungeConstants.on
            : LoungeConstants.off
        : null,
    tls: serverPreferences.useTls != null
        ? serverPreferences.useTls ? LoungeConstants.on : LoungeConstants.off
        : null,
    name: serverPreferences.name,
    uuid: remoteId,
    commands: userPreferences.commands,
  );
}

WhoIsSpecialMessageBody toSpecialMessageWhoIs(
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
        type: detectMessagePreviewType(loungePreview.type));

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
  }

  throw Exception("Invalid MessagePreviewType type $type");
}

NetworkChannelWithState toNetworkChannelWithState(
    ChannelLoungeResponseBody loungeChannel) {
  var channel = NetworkChannel(
      ChatNetworkChannelPreferences.name(
          name: loungeChannel.name,
          // Network start channels always without password
          password: ""),
      detectNetworkChannelType(loungeChannel.type),
      loungeChannel.id);
  var channelState = toNetworkChannelState((loungeChannel));
  var networkChannelWithState = NetworkChannelWithState(channel, channelState);
  return networkChannelWithState;
}

NetworkWithState toNetworkWithState(NetworkLoungeResponseBody loungeNetwork) {
  var channelsWithState = <NetworkChannelWithState>[];

  for (var loungeChannel in loungeNetwork.channels) {
    channelsWithState.add(toNetworkChannelWithState(loungeChannel));
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
              useTls: loungeNetwork.tls == LoungeConstants.on ? true : false,
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

  var networkWithState =
      NetworkWithState(network, networkState, channelsWithState);
  return networkWithState;
}
