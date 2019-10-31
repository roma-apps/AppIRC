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
        return false;
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
        return false;
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
    return AppLocalizations.of(context)
        .tr(key + ".zero", args: [count.toString()]);
  } else if (count == 1) {
    return AppLocalizations.of(context)
        .tr(key + ".one", args: [count.toString()]);
  } else {
    return AppLocalizations.of(context)
        .tr(key + ".other", args: [count.toString()]);
  }
}
