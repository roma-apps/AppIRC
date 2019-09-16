import 'package:flutter/foundation.dart';

import '../../lounge/lounge_model.dart';

abstract class IRCChatMessage {
  final IRCChatMessageType chatMessageType;

  IRCChatMessage(this.chatMessageType);


}

 class IRCChatSpecialMessage extends  IRCChatMessage {
    final dynamic data;

  IRCChatSpecialMessage(this.data) : super(IRCChatMessageType.SPECIAL);
}


enum IRCChatMessageType {
  SPECIAL, REGULAR
}

IRCNetworkChannelMessageFrom toIRCFrom(MsgFromLoungeResponseBodyPart from) =>
    IRCNetworkChannelMessageFrom(mode: from.mode, id: from.id, nick: from.nick);

IRCNetworkChannelMessageWhoIs toIRCWhoIs(WhoIsLoungeResponseBodyPart whois) =>
    IRCNetworkChannelMessageWhoIs(
        account: whois.account,
        channels: whois.channels,
        hostname: whois.hostname,
        ident: whois.ident,
        idle: whois.idle,
        idleTime: whois.idleTime,
        logonTime: whois.logonTime,
        logon: whois.logon,
        nick: whois.nick,
        realName: whois.real_name,
        secure: whois.secure,
        server: whois.server,
        serverInfo: whois.serverInfo);

IRCNetworkChannelMessage toIRCMessage(
        MsgLoungeResponseBody msgLoungeResponseBody) =>
    IRCNetworkChannelMessage(
        remoteId: msgLoungeResponseBody.id,
        command: msgLoungeResponseBody.command,
        hostMask: msgLoungeResponseBody.hostmask,
        text: msgLoungeResponseBody.text,
        type: detectIRCNetworkChannelMessageType(msgLoungeResponseBody.type),
        self: msgLoungeResponseBody.self,
        highlight: msgLoungeResponseBody.highlight,
        showInActive: msgLoungeResponseBody.showInActive,
        params: msgLoungeResponseBody.params,
        previews: msgLoungeResponseBody.previews,
        users: msgLoungeResponseBody.users,
        date: DateTime.parse(msgLoungeResponseBody.time),
        from: msgLoungeResponseBody.from != null ? toIRCFrom(msgLoungeResponseBody.from) : null,
        whois: msgLoungeResponseBody.whois != null ? toIRCWhoIs(msgLoungeResponseBody.whois) : null);

class IRCNetworkChannelMessage extends IRCChatMessage {
  final int remoteId;
  final String command;
  final String hostMask;
  final String text;
  final IRCNetworkChannelMessageType type;
  final bool self;
  final bool highlight;
  final bool showInActive;
  final List<String> params;
  final List<dynamic> previews;
  final List<dynamic> users;
  final DateTime date;

  final IRCNetworkChannelMessageFrom from;
  final IRCNetworkChannelMessageWhoIs whois;

  IRCNetworkChannelMessage(
      {@required this.remoteId,
      @required this.command,
      @required this.hostMask,
      @required this.text,
      @required this.type,
      @required this.self,
      @required this.highlight,
      @required this.showInActive,
      @required this.params,
      @required this.previews,
      @required this.users,
      @required this.date,
      @required this.from,
      @required this.whois}): super(IRCChatMessageType.REGULAR);

  bool get isHaveFrom => from != null && from.nick != null;

  @override
  String toString() {
    return 'IRCNetworkChannelMessage{remoteId: $remoteId,'
        ' command: $command, hostmask: $hostMask, text: $text,'
        ' type: $type, self: $self, highlight: $highlight,'
        ' showInActive: $showInActive, params: $params,'
        ' previews: $previews, users: $users,'
        ' date: $date, from: $from, whois: $whois}';
  }

  bool get isMessageDateToday {
    var now = DateTime.now();
    var todayStart = now.subtract(Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
    return todayStart.isBefore(date);
  }
}

class IRCNetworkChannelMessageFrom {
  final int id;
  final String nick;
  final String mode;

  @override
  String toString() {
    return 'IRCNetworkChannelMessageFrom{id: $id, nick: $nick, mode: $mode}';
  }

  IRCNetworkChannelMessageFrom(
      {@required this.id, @required this.nick, @required this.mode});
}

class IRCNetworkChannelMessageWhoIs {
  final String account;
  final String channels;
  final String hostname;
  final String ident;
  final String idle;
  final int idleTime;
  final int logonTime;
  final String logon;
  final String nick;
  final String realName;
  final bool secure;
  final String server;
  final String serverInfo;

  @override
  String toString() {
    return 'IRCNetworkChannelMessageWhoIS{account: $account, '
        'channels: $channels, hostname: $hostname, '
        'ident: $ident, idle: $idle, idleTime: $idleTime, '
        'logonTime: $logonTime, logon: $logon, nick: $nick, '
        'realName: $realName, secure: $secure, '
        'server: $server, serverInfo: $serverInfo}';
  }

  IRCNetworkChannelMessageWhoIs(
      {@required this.account,
      @required this.channels,
      @required this.hostname,
      @required this.ident,
      @required this.idle,
      @required this.idleTime,
      @required this.logonTime,
      @required this.logon,
      @required this.nick,
      @required this.realName,
      @required this.secure,
      @required this.server,
      @required this.serverInfo});
}

IRCNetworkChannelMessageType detectIRCNetworkChannelMessageType(
    String stringType) {
  var type;
  switch (stringType) {
    case "unhandled":
      type = IRCNetworkChannelMessageType.UNHANDLED;
      break;
    case "topic_set_by":
      type = IRCNetworkChannelMessageType.TOPIC_SET_BY;
      break;
    case "topic":
      type = IRCNetworkChannelMessageType.TOPIC;
      break;
    case "message":
      type = IRCNetworkChannelMessageType.MESSAGE;
      break;
    case "join":
      type = IRCNetworkChannelMessageType.JOIN;
      break;
    case "mode":
      type = IRCNetworkChannelMessageType.MODE;
      break;
    case "motd":
      type = IRCNetworkChannelMessageType.MODE;
      break;
    case "whois":
      type = IRCNetworkChannelMessageType.WHO_IS;
      break;
    case "notice":
      type = IRCNetworkChannelMessageType.NOTICE;
      break;
    case "error":
      type = IRCNetworkChannelMessageType.ERROR;
      break;
    case "away":
      type = IRCNetworkChannelMessageType.AWAY;
      break;

    case "back":
      type = IRCNetworkChannelMessageType.BACK;
      break;

    case "mode_channel":
      type = IRCNetworkChannelMessageType.MODE_CHANNEL;
      break;

    case "quit":
      type = IRCNetworkChannelMessageType.QUIT;
      break;
    case "raw":
      type = IRCNetworkChannelMessageType.RAW;
      break;

    default:
      type = IRCNetworkChannelMessageType.UNKNOWN;
  }

  return type;
}

enum IRCNetworkChannelMessageType {
  TOPIC_SET_BY,
  TOPIC,
  WHO_IS,
  UNHANDLED,
  UNKNOWN,
  MESSAGE,
  JOIN,
  MODE,
  MOTD,
  NOTICE,
  ERROR,
  AWAY,
  BACK,
  RAW,
  MODE_CHANNEL,
  QUIT,
//  PART,
//  NICK,
}
