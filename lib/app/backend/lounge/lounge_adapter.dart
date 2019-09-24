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
        defaultNetwork: ChatNetworkConnectionPreferences(
            serverPreferences: ChatNetworkServerPreferences(
                name: loungeConfig.defaults.name,
                serverHost: loungeConfig.defaults.host,
                serverPort: loungeConfig.defaults.port.toString(),
                useTls: loungeConfig.defaults.tls,
                useOnlyTrustedCertificates:
                    loungeConfig.defaults.rejectUnathorized),
            userPreferences: ChatNetworkUserPreferences(
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
      channel.remoteId,
      command: msgLoungeResponseBody.command,
      hostMask: msgLoungeResponseBody.hostmask,
      text: msgLoungeResponseBody.text,
      regularMessageType: detectRegularMessageType(msgLoungeResponseBody.type),
      self: msgLoungeResponseBody.self,
      highlight: msgLoungeResponseBody.highlight,
      params: msgLoungeResponseBody.params,
      previews: msgLoungeResponseBody.previews,
      date: DateTime.parse(msgLoungeResponseBody.time),
      fromNick: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.nick
          : null,
      fromRemoteId: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.id
          : null,
      fromMode: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.mode
          : null, newNick: msgLoungeResponseBody.new_nick,
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
          specialType: messageType)
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
          specialType: messageType));
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
