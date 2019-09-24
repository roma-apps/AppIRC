import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';


class RegularMessage extends ChatMessage {
  final String command;

  final String hostMask;

  final String text;


  final List<String> params;

  final RegularMessageType regularMessageType;

  final bool self;

  final bool highlight;

  final dynamic previews;

  final DateTime date;

  final int fromRemoteId;

  final String fromNick;

  final String fromMode;

  RegularMessage(
      int channelRemoteId,
      this.command,
      this.hostMask,
      this.text,
      this.params,
      this.regularMessageType,
      this.self,
      this.highlight,
      this.previews,
      this.date,
      this.fromRemoteId,
      this.fromNick,
      this.fromMode)
      : super(ChatMessageType.REGULAR, channelRemoteId);

  RegularMessage.name(
 int channelRemoteId,
      {@required this.command,
      @required this.hostMask,
      @required this.text,
      @required this.params,
      @required this.regularMessageType,
      @required this.self,
      @required this.highlight,
      @required this.previews,
      @required this.date,
      @required this.fromRemoteId,
      @required this.fromNick,
      @required this.fromMode})
      : super(ChatMessageType.REGULAR, channelRemoteId);

  bool get isHaveFromNick => fromNick != null;

  bool get isMessageDateToday {
    var now = DateTime.now();
    var todayStart = now.subtract(
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
    return todayStart.isBefore(date);
  }
}

enum RegularMessageType {
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
  PART,
  NICK,
}
