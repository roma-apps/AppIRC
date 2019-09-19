
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';

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

NetworkChannelMessage toIRCMessage(
    MsgLoungeResponseBody msgLoungeResponseBody) =>
    NetworkChannelMessage(
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

IRCNetworkChannelType detectIRCNetworkChannelType(String typeString) {
  var type = IRCNetworkChannelType.UNKNOWN;
  switch (typeString) {
    case LoungeChannelTypeConstants.lobby:
      type = IRCNetworkChannelType.LOBBY;
      break;
    case LoungeChannelTypeConstants.special:
      type = IRCNetworkChannelType.SPECIAL;
      break;
    case LoungeChannelTypeConstants.query:
      type = IRCNetworkChannelType.QUERY;
      break;
    case LoungeChannelTypeConstants.channel:
      type = IRCNetworkChannelType.CHANNEL;
      break;
  }
  return type;
}
