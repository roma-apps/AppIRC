import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

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

const _localizationIdPrefix = "chat.message.regular.condensed";
String getCondensedStringForRegularMessageTypeAndCount(
    BuildContext context, RegularMessageType type, int count) {
  switch (type) {
    case RegularMessageType.join:
      return _plural(context, _localizationIdPrefix + ".join", count);
      break;
    case RegularMessageType.mode:
      return _plural(context, _localizationIdPrefix + ".mode", count);
      break;
    case RegularMessageType.modeChannel:
      return _plural(context, _localizationIdPrefix + ".mode_channel", count);
      break;
    case RegularMessageType.away:
      return _plural(context, _localizationIdPrefix + ".away", count);
      break;
    case RegularMessageType.back:
      return _plural(context, _localizationIdPrefix + ".back", count);
      break;
    case RegularMessageType.quit:
      return _plural(context, _localizationIdPrefix + ".quit", count);
      break;
    case RegularMessageType.part:
      return _plural(context, _localizationIdPrefix + ".part", count);
      break;
    case RegularMessageType.nick:
      return _plural(context, _localizationIdPrefix + ".nick", count);
      break;
    case RegularMessageType.chghost:
      return _plural(context, _localizationIdPrefix + ".chghost", count);
      break;
    case RegularMessageType.kick:
      return _plural(context, _localizationIdPrefix + ".kick", count);
      break;
    default:
      break;
  }
  throw "Not supported message type $type";
}

String _plural(BuildContext context, String key, int count) {
  if (count == 0) {
    return tr(key + ".zero", args: [count.toString()]);
  } else if (count == 1) {
    return tr(key + ".one", args: [count.toString()]);
  } else {
    return tr(key + ".other", args: [count.toString()]);
  }
}
