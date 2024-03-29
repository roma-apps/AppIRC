import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/body/channel_info/message_special_channel_info_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/text/message_special_text_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/whois/message_special_who_is_body_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:logging/logging.dart';

var _logger = Logger("lounge_model_adapter.dart");

ChatInitInformation toChatInitInformation(
  InitLoungeResponseBody initLoungeResponseBody,
) {
  var loungeNetworks = initLoungeResponseBody.networks;
  var networksWithState = <NetworkWithState>[];
  var channelsWithState = <ChannelWithState>[];
  for (var loungeNetwork in loungeNetworks) {
    networksWithState.add(
      toNetworkWithState(
        loungeNetwork,
      ),
    );

    for (var loungeChannel in loungeNetwork.channels) {
      channelsWithState.add(
        toChannelWithState(
          loungeChannel,
        ),
      );
    }
  }
  int activeChannelRemoteId = initLoungeResponseBody.active;
  var isUndefinedActiveId =
      activeChannelRemoteId == InitLoungeResponseBody.undefinedActiveID;
  if (isUndefinedActiveId) {
    activeChannelRemoteId = null;
  }
  return ChatInitInformation(
    activeChannelRemoteId: activeChannelRemoteId,
    networksWithState: networksWithState,
    channelsWithState: channelsWithState,
    authToken: initLoungeResponseBody.token,
  );
}

ChatConfig toChatConfig({
  @required ConfigurationLoungeResponseBody loungeConfig,
  @required List<String> commands,
}) {
  var networkServerPreferences = NetworkServerPreferences(
          name: loungeConfig.defaults.name,
          serverHost: loungeConfig.defaults.host,
          serverPort: loungeConfig.defaults.port.toString(),
          useTls: loungeConfig.defaults.tls,
          useOnlyTrustedCertificates: loungeConfig.defaults.rejectUnauthorized,
        );
  var networkUserPreferences = NetworkUserPreferences(
          nickname: loungeConfig.defaults.nick,
          realName: loungeConfig.defaults.realname,
          username: loungeConfig.defaults.username,
          password: loungeConfig.defaults.password,
          commands: null,
        );
  var networkConnectionPreferences = NetworkConnectionPreferences(
        serverPreferences: networkServerPreferences,
        userPreferences: networkUserPreferences,
      );
  return ChatConfig(
      defaultNetwork: networkConnectionPreferences,
      defaultChannels: loungeConfig.defaults.join,
      fileUpload: loungeConfig.fileUpload,
      displayNetwork: loungeConfig.displayNetwork,
      lockNetwork: loungeConfig.lockNetwork,
      ldapEnabled: loungeConfig.ldapEnabled,
      prefetch: loungeConfig.prefetch,
      public: loungeConfig.public,
      useHexIp: loungeConfig.useHexIp,
      fileUploadMaxSizeInBytes: loungeConfig.fileUploadMaxFileSize,
      commands: commands,
    );
}

ChatMessage toChatMessage(
  Channel channel,
  MsgLoungeResponseBodyPart msgLoungeResponseBody,
) {
  var regularMessageType = detectRegularMessageType(msgLoungeResponseBody.type);

  if (regularMessageType == RegularMessageType.whoIs) {
    return toWhoIsSpecialMessage(
      channel: channel,
      msgLoungeResponseBody: msgLoungeResponseBody,
    );
  } else {
    var isCtcp = regularMessageType == RegularMessageType.ctcpRequest ||
        regularMessageType == RegularMessageType.ctcp;

    var text;
    if (isCtcp) {
      text = msgLoungeResponseBody.ctcpMessage;
    } else {
      // todo: add special fields to RegularChatMessage
      if (regularMessageType == RegularMessageType.chghost) {
        text =
            "${msgLoungeResponseBody.newIdent}@${msgLoungeResponseBody.newHost}";
      } else {
        if (regularMessageType == RegularMessageType.kick) {
          text = "${msgLoungeResponseBody?.target?.nick}: "
              "${msgLoungeResponseBody.text}";
        } else {
          text = msgLoungeResponseBody.text;
        }
      }
    }

    var date = DateTime.parse(msgLoungeResponseBody.time);

    date = DateTime.fromMicrosecondsSinceEpoch(date.microsecondsSinceEpoch);
    return RegularMessage(
      channelRemoteId: channel.remoteId,
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
      date: date,
      fromNick: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.nick
          : null,
      fromRemoteId: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.id
          : null,
      fromMode: msgLoungeResponseBody.from != null
          ? msgLoungeResponseBody.from.mode
          : null,
      newNick: msgLoungeResponseBody.newNick,
      messageRemoteId: msgLoungeResponseBody.id,
      nicknames: msgLoungeResponseBody.users,
      linksInMessage: null,
      channelLocalId: null,
      messageLocalId: null,
    );
  }
}

SpecialMessage toWhoIsSpecialMessage({
  @required Channel channel,
  @required MsgLoungeResponseBodyPart msgLoungeResponseBody,
}) {
  var whoIsSpecialBody = toWhoIsSpecialMessageBody(msgLoungeResponseBody.whois);

  return SpecialMessage(
    channelRemoteId: channel.remoteId,
    data: whoIsSpecialBody,
    specialType: SpecialMessageType.whoIs,
    date: DateTime.now(),
    linksInMessage: null,
    channelLocalId: null,
    messageLocalId: null,
  );
}

// Return list instead of one message
// because lounge SpecialMessageType.CHANNELS_LIST_ITEM message
// contains several ChatSpecialMessages
Future<List<SpecialMessage>> toSpecialMessages({
  @required Channel channel,
  @required MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
}) async {
  var messageType =
      detectSpecialMessageType(messageSpecialLoungeResponseBody.data);

  if (messageType == SpecialMessageType.text) {
    return [
      await toTextSpecialMessage(
        messageSpecialLoungeResponseBody: messageSpecialLoungeResponseBody,
        channel: channel,
        messageType: messageType,
      )
    ];
  } else if (messageType == SpecialMessageType.channelsListItem) {
    return await toChannelsListSpecialMessages(
      messageSpecialLoungeResponseBody: messageSpecialLoungeResponseBody,
      channel: channel,
      messageType: messageType,
    );
  } else {
    throw Exception("Invalid special message type $messageType");
  }
}

Future<List<SpecialMessage>> toChannelsListSpecialMessages({
  @required MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
  @required Channel channel,
  @required SpecialMessageType messageType,
}) async {
  var iterable = messageSpecialLoungeResponseBody.data as Iterable;

  var specialMessages = <SpecialMessage>[];

  for (var item in iterable) {
    var loungeChannelItem =
        ChannelListItemSpecialMessageLoungeResponseBodyPart.fromJson(item);
    var channelInfoSpecialMessageBody = ChannelInfoSpecialMessageBody(
      name: loungeChannelItem.channel,
      topic: loungeChannelItem.topic,
      usersCount: loungeChannelItem.numUsers,
    );

    specialMessages.add(
      SpecialMessage(
        data: channelInfoSpecialMessageBody,
        channelRemoteId: channel.remoteId,
        specialType: messageType,
        date: DateTime.now(),
        linksInMessage: null,
        channelLocalId: null,
        messageLocalId: null,
      ),
    );
  }

  _logger.fine(() => "toChannelsListSpecialMessages ${specialMessages.length}");

  return specialMessages;
}

Future<SpecialMessage> toTextSpecialMessage({
  @required MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody,
  @required Channel channel,
  @required SpecialMessageType messageType,
}) async {
  var textMessage = TextSpecialMessageLoungeResponseBodyPart.fromJson(
    messageSpecialLoungeResponseBody.data,
  );

  return SpecialMessage(
    data: TextSpecialMessageBody(
      message: textMessage.text,
    ),
    channelRemoteId: channel.remoteId,
    specialType: messageType,
    date: DateTime.now(),
    linksInMessage: null,
    channelLocalId: null,
    messageLocalId: null,
  );
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
    } on Exception catch (error, stackTrace) {
      _logger.shout(
        () => "error during detecting text special message",
        error,
        stackTrace,
      );
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
      } on Exception catch (error, stackTrace) {
        _logger.shout(
          () => "error during detecting text special message",
          error,
          stackTrace,
        );
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

ChannelState toChannelState({
  @required ChannelLoungeResponseBodyPart loungeChannel,
  @required ChannelType type,
}) {
  // Private and special messages are always connected, but lounge sometimes
  // don't provide connected state for them
  var isConnected = type == ChannelType.query || type == ChannelType.special
      ? true
      : loungeChannel.state == ChannelStateLoungeConstants.connected;
  var moreHistoryAvailable = loungeChannel.moreHistoryAvailable;
  // very strange lounge behaviour
  // sometimes lounge send moreHistoryAvailable and sometimes totalMessages
  // todo: report to lounge
  if (moreHistoryAvailable == null &&
      loungeChannel.totalMessages != null &&
      loungeChannel.messages != null) {
    moreHistoryAvailable =
        loungeChannel.totalMessages > loungeChannel.messages.length;
  }
  return ChannelState(
    topic: loungeChannel.topic,
    firstUnreadRemoteMessageId: loungeChannel.firstUnread,
    editTopicPossible: loungeChannel.editTopic,
    unreadCount: loungeChannel.unread,
    connected: isConnected,
    highlighted: loungeChannel.highlight != null,
    moreHistoryAvailable: moreHistoryAvailable,
  );
}

NetworkState toNetworkState({
  @required NetworkStatusLoungeResponseBody loungeNetworkStatus,
  @required String nick,
  @required String name,
}) =>
    NetworkState(
      connected: loungeNetworkStatus.connected,
      secure: loungeNetworkStatus.secure,
      nick: nick,
      name: name,
    );

Future<MessageListLoadMore> toChatLoadMore({
  @required Channel channel,
  @required MoreLoungeResponseBody moreLoungeResponseBody,
}) async {
  var messages = <ChatMessage>[];

  for (var loungeMessage in moreLoungeResponseBody.messages) {
    messages.add(
      await toChatMessage(
        channel,
        loungeMessage,
      ),
    );
  }

  return MessageListLoadMore(
    messages: messages,
    totalMessages: moreLoungeResponseBody.totalMessages,
  );
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
    case MessageTypeLoungeConstants.monospaceBlock:
      type = RegularMessageType.monospaceBlock;
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
    case MessageTypeLoungeConstants.action:
      type = RegularMessageType.action;
      break;
    case MessageTypeLoungeConstants.invite:
      type = RegularMessageType.invite;
      break;
    case MessageTypeLoungeConstants.ctcp:
      type = RegularMessageType.ctcp;
      break;
    case MessageTypeLoungeConstants.chghost:
      type = RegularMessageType.chghost;
      break;
    case MessageTypeLoungeConstants.kick:
      type = RegularMessageType.kick;
      break;

    default:
      type = RegularMessageType.unknown;
  }

  return type;
}

String toLoungeBoolean(bool boolValue) {
  return boolValue != null
      ? boolValue
          ? BooleanLoungeConstants.on
          : BooleanLoungeConstants.off
      : null;
}

NetworkEditLoungeJsonRequest toNetworkEditLoungeRequestBody({
  @required String remoteId,
  @required NetworkUserPreferences userPreferences,
  @required NetworkServerPreferences serverPreferences,
}) {
  return NetworkEditLoungeJsonRequest(
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
  WhoIsLoungeResponseBodyPart loungeWhoIs,
) =>
    WhoIsSpecialMessageBody(
      account: loungeWhoIs.account,
      channels: loungeWhoIs.channels,
      hostname: loungeWhoIs.hostname,
      ident: loungeWhoIs.ident,
      idle: loungeWhoIs.idle,
      idleTime: DateTime.fromMillisecondsSinceEpoch(loungeWhoIs.idleTime),
      logonTime: DateTime.fromMillisecondsSinceEpoch(loungeWhoIs.logonTime),
      logon: loungeWhoIs.logon,
      nick: loungeWhoIs.nick,
      realName: loungeWhoIs.realName,
      secure: loungeWhoIs.secure,
      server: loungeWhoIs.server,
      serverInfo: loungeWhoIs.serverInfo,
      actualHostname: loungeWhoIs.actualHostname,
      actualIp: loungeWhoIs.actualIp,
    );

MessagePreview toMessagePreview(
  MsgPreviewLoungeResponseBodyPart loungePreview,
) {
  var thumb = loungePreview.thumb;

  // Sometimes lounge server prefetch remote image and fails
  // it should return full path to image in own server
  // however it returns relative path on the server
  // in this case we replace prefetched image with remote image
  // todo: hack for bug in lounge
  if (thumb?.startsWith("storage") == true) {
    thumb = loungePreview.link;
  }
  return MessagePreview(
    head: loungePreview.head,
    body: loungePreview.body,
    canDisplay: loungePreview.canDisplay,
    shown: loungePreview.shown,
    link: loungePreview.link,
    thumb: thumb,
    type: detectMessagePreviewType(loungePreview.type),
    media: loungePreview.media,
    mediaType: loungePreview.mediaType,
  );
}

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
    case MessagePreviewTypeLoungeResponse.error:
      return MessagePreviewType.error;
      break;
  }

  throw Exception("Invalid MessagePreviewType type $type");
}

ChannelWithState toChannelWithState(
  ChannelLoungeResponseBodyPart loungeChannel,
) {
  var channel = Channel(
    ChannelPreferences(
      name: loungeChannel.name,
      // Network channels which exists on network join doesn't use passwords
      password: "",
    ),
    detectChannelType(loungeChannel.type),
    loungeChannel.id,
  );
  var channelState = toChannelState(
    loungeChannel: loungeChannel,
    type: channel.type,
  );

  var initMessages = <ChatMessage>[];
  if (loungeChannel.messages != null) {
    for (var loungeMessage in loungeChannel.messages) {
      initMessages.add(
        toChatMessage(
          channel,
          loungeMessage,
        ),
      );
    }
  }

  var initUsers = loungeChannel.users
      ?.map((loungeUser) => toChannelUser(loungeUser))
      ?.toList();
  var channelWithState = ChannelWithState(
    channel,
    channelState,
    initMessages,
    initUsers,
  );
  return channelWithState;
}

ChannelUser toChannelUser(UserLoungeResponseBodyPart loungeUser) => ChannelUser(
      nick: loungeUser.nick,
      mode: loungeUser.mode,
      hostMask: null,
      connectedTo: null,
      idleSince: null,
      secureConnection: null,
      realName: null,
      connectedAt: null,
      channels: null,
    );

NetworkWithState toNetworkWithState(
  NetworkLoungeResponseBodyPart loungeNetwork,
) {
  var channelsWithState = <ChannelWithState>[];

  for (var loungeChannel in loungeNetwork.channels) {
    channelsWithState.add(
      toChannelWithState(
        loungeChannel,
      ),
    );
  }

  var channels = channelsWithState
      .map(
        (channelWithState) => channelWithState.channel,
      )
      .toList();

  var nick = loungeNetwork.nick;
  NetworkConnectionPreferences connectionPreferences =
      NetworkConnectionPreferences(
    serverPreferences: NetworkServerPreferences(
      name: loungeNetwork.name,
      serverHost: loungeNetwork.host,
      serverPort: loungeNetwork.port.toString(),
      useTls: loungeNetwork.tls,
      useOnlyTrustedCertificates: loungeNetwork.rejectUnauthorized,
    ),
    userPreferences: NetworkUserPreferences(
      nickname: nick,
      password: null,
      commands: null,
      realName: loungeNetwork.realname,
      username: loungeNetwork.username,
    ),
  );
  var network = Network(
    connectionPreferences: connectionPreferences,
    remoteId: loungeNetwork.uuid,
    channels: channels,
  );

  var loungeNetworkStatus = loungeNetwork.status;

  var networkState = toNetworkState(
    loungeNetworkStatus: loungeNetworkStatus,
    nick: nick,
    name: network.name,
  );

  // TODO: open ticket for lounge
  // Strange field, it should be inside networkStatus.
  // Sometimes network status connected == false but network actually connected
  networkState = networkState.copyWith(
    connected: !loungeNetwork.userDisconnected,
  );

  var networkWithState = NetworkWithState(
    network: network,
    state: networkState,
    channelsWithState: channelsWithState,
  );
  return networkWithState;
}

ChatRegistrationResult toChatRegistrationResult(
  SignedUpLoungeResponseBody registrationResponseBody,
) {
  if (registrationResponseBody.success) {
    return ChatRegistrationResult.success();
  } else {
    return ChatRegistrationResult.fail(
      toChatRegistrationErrorType(
        registrationResponseBody.errorType,
      ),
    );
  }
}

RegistrationErrorType toChatRegistrationErrorType(String errorType) {
  switch (errorType) {
    case SignedUpLoungeResponseBody.errorTypeInvalid:
      return RegistrationErrorType.invalid;
      break;
    case SignedUpLoungeResponseBody.errorTypeAlreadyExist:
      return RegistrationErrorType.alreadyExist;
      break;
    default:
      return RegistrationErrorType.unknown;
      break;
  }
}
