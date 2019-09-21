import 'dart:convert';

import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';

var _logger = MyLogger(logTag: "lounge_adapter", enabled: true);

ChatConfig toChatConfig(
        ConfigurationLoungeResponseBody loungeConfig, List<String> commands) =>
    ChatConfig.name(
        defaultNetwork: IRCNetworkConnectionPreferences(
            serverPreferences: IRCNetworkServerPreferences(
                name: loungeConfig.defaults.name,
                serverHost: loungeConfig.defaults.host,
                serverPort: loungeConfig.defaults.port.toString(),
                useTls: loungeConfig.defaults.tls,
                useOnlyTrustedCertificates:
                    loungeConfig.defaults.rejectUnathorized),
            userPreferences: IRCNetworkUserPreferences(
                nickname: loungeConfig.defaults.nick,
                realName: loungeConfig.defaults.realname,
                username: loungeConfig.defaults.username)),
        defaultChannels: loungeConfig.defaults.join,
        displayNetwork: loungeConfig.displayNetwork,
        fileUpload: loungeConfig.fileUpload,
        ldapEnabled: loungeConfig.ldapEnabled,
        lockNetwork: loungeConfig.lockNetwork,
        prefetch: loungeConfig.prefetch,
        public: loungeConfig.public,
        useHexIp: loungeConfig.useHexIp,
        fileUploadMaxSize: loungeConfig.fileUploadMaxSize,
        commands: commands,
        defaultPassword: loungeConfig.defaults.password);

WhoIsLoungeResponseBodyPart toIRCWhoIs(WhoIsLoungeResponseBodyPart whoIs) =>
    WhoIsLoungeResponseBodyPart(
        account: whoIs.account,
        channels: whoIs.channels,
        hostname: whoIs.hostname,
        ident: whoIs.ident,
        idle: whoIs.idle,
        idleTime: whoIs.idleTime,
        logonTime: whoIs.logonTime,
        logon: whoIs.logon,
        nick: whoIs.nick,
        real_name: whoIs.real_name,
        secure: whoIs.secure,
        server: whoIs.server,
        serverInfo: whoIs.serverInfo);

ChatMessage toChatMessage(
        NetworkChannel channel, MsgLoungeResponseBody msgLoungeResponseBody) =>
    RegularMessage.name(
        command: msgLoungeResponseBody.command,
        hostMask: msgLoungeResponseBody.hostmask,
        text: msgLoungeResponseBody.text,
        regularMessageTypeId: regularMessageTypeTypeToId(
            detectRegularMessageType(msgLoungeResponseBody.type)),
        self: msgLoungeResponseBody.self != null ? msgLoungeResponseBody.self ?  1 : 0 : null,
        highlight: msgLoungeResponseBody.highlight != null ? msgLoungeResponseBody.highlight ?  1 : 0 : null,
        paramsJsonEncoded: json.encode(msgLoungeResponseBody.params),
        previewsJsonEncoded: json.encode(msgLoungeResponseBody.previews),
        dateMicrosecondsSinceEpoch:
            DateTime.parse(msgLoungeResponseBody.time).millisecondsSinceEpoch,
        fromNick: msgLoungeResponseBody.from != null
            ? msgLoungeResponseBody.from.nick
            : null,
        fromRemoteId: msgLoungeResponseBody.from != null
            ? msgLoungeResponseBody.from.id
            : null,
        fromMode: msgLoungeResponseBody.from != null
            ? msgLoungeResponseBody.from.mode
            : null,
        channelRemoteId: channel.remoteId);

List<SpecialMessage> toSpecialMessages(NetworkChannel channel,
    MessageSpecialLoungeResponseBody messageSpecialLoungeResponseBody) {
  var messageType =
      detectSpecialMessageType(messageSpecialLoungeResponseBody.data);


  if (messageType == SpecialMessageType.TEXT) {
    var textMessage = TextSpecialMessageLoungeResponseBodyPart.fromJson(
        messageSpecialLoungeResponseBody.data);
    var jsonEncoded = json.encode(TextSpecialMessageBody(textMessage.text));
    return [
      SpecialMessage.name(
          dataJsonEncoded: jsonEncoded,
          channelRemoteId: channel.remoteId,
          specialTypeId: specialMessageTypeTypeToId(messageType))
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

      var jsonEncoded = json.encode(networkChannelInfoSpecialMessageBody);
      specialMessages.add(SpecialMessage.name(
          dataJsonEncoded: jsonEncoded,
          channelRemoteId: channel.remoteId,
          specialTypeId: specialMessageTypeTypeToId(messageType)));
    });

    return specialMessages;
  } else {
    throw Exception("Invalid special message type $messageType");
  }
}

SpecialMessageType detectSpecialMessageType(data) {
  var map = data as Map;
  var iterable = data as Iterable;
  if (map != null) {
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
    if (iterable != null) {
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

NetworkState toNetworkState(
        NetworkStatusLoungeResponseBody loungeNetworkStatus) =>
    NetworkState.name(
        connected: loungeNetworkStatus.connected,
        secure: loungeNetworkStatus.secure);

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

    case "mode_channel":
      type = RegularMessageType.MODE_CHANNEL;
      break;

    case "quit":
      type = RegularMessageType.QUIT;
      break;
    case "raw":
      type = RegularMessageType.RAW;
      break;

    default:
      type = RegularMessageType.UNKNOWN;
  }

  return type;
}
