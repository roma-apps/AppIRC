import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';

bool isPossibleToCondenseMessage(ChatMessage message) {
  if (message is RegularMessage) {
    switch (message.regularMessageType) {
      case RegularMessageType.topicSetBy:
        return false;
        break;
      case RegularMessageType.topic:
        return false;
        break;
      case RegularMessageType.whoIs:
        return false;
        break;
      case RegularMessageType.unhandled:
        return false;
        break;
      case RegularMessageType.unknown:
        return false;
        break;
      case RegularMessageType.message:
        return false;
        break;
      case RegularMessageType.join:
        return true;
        break;
      case RegularMessageType.mode:
        return true;
        break;
      case RegularMessageType.motd:
        return false;
        break;
      case RegularMessageType.notice:
        return false;
        break;
      case RegularMessageType.error:
        return false;
        break;
      case RegularMessageType.away:
        return true;
        break;
      case RegularMessageType.back:
        return true;
        break;
      case RegularMessageType.raw:
        return false;
        break;
      case RegularMessageType.modeChannel:
        return true;
        break;
      case RegularMessageType.quit:
        return true;
        break;
      case RegularMessageType.part:
        return true;
        break;
      case RegularMessageType.nick:
        return true;
        break;
      case RegularMessageType.ctcpRequest:
        return false;
        break;
      case RegularMessageType.chghost:
        return true;
        break;
      case RegularMessageType.kick:
        return true;
        break;
      case RegularMessageType.action:
        return false;
        break;
      case RegularMessageType.invite:
        return false;
        break;
      case RegularMessageType.ctcp:
        return false;
        break;
    }
    return false;
  } else {
    return false;
  }
}

String getCondensedStringForRegularMessageTypeAndCount(
    BuildContext context, RegularMessageType type, int count) {
  switch (type) {
    case RegularMessageType.join:
      return S.of(context).chat_message_regular_condensed_join(count);
      break;
    case RegularMessageType.mode:
      return S.of(context).chat_message_regular_condensed_mode(count);
      break;
    case RegularMessageType.modeChannel:
      return S.of(context).chat_message_regular_condensed_mode_channel(count);
      break;
    case RegularMessageType.away:
      return S.of(context).chat_message_regular_condensed_away(count);
      break;
    case RegularMessageType.back:
      return S.of(context).chat_message_regular_condensed_back(count);
      break;
    case RegularMessageType.quit:
      return S.of(context).chat_message_regular_condensed_quit(count);
      break;
    case RegularMessageType.part:
      return S.of(context).chat_message_regular_condensed_part(count);
      break;
    case RegularMessageType.nick:
      return S.of(context).chat_message_regular_condensed_nick(count);
      break;
    case RegularMessageType.chghost:
      return S.of(context).chat_message_regular_condensed_chghost(count);
      break;
    case RegularMessageType.kick:
      return S.of(context).chat_message_regular_condensed_kick(count);
      break;
    default:
      break;
  }
  throw "Not supported message type $type";
}
