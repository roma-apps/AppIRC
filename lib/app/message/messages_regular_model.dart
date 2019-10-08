import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';


class RegularMessage extends ChatMessage {

  final int messageRemoteId;
  final String command;

  final String hostMask;

  final String text;


  final List<String> params;

  final RegularMessageType regularMessageType;

  final bool self;

  final bool highlight;

  final int fromRemoteId;

  final String fromNick;

  final String fromMode;

  final String newNick;

   List<MessagePreview> previews;

  RegularMessage(
      int channelRemoteId,
      this.messageRemoteId,
      this.command,
      this.hostMask,
      this.text,
      this.params,
      this.regularMessageType,
      this.self,
      this.highlight,
      this.previews,
      DateTime date,
      this.newNick,
      this.fromRemoteId,
      this.fromNick,
      this.fromMode)
      : super(ChatMessageType.REGULAR, channelRemoteId, date);

  RegularMessage.name(
 int channelRemoteId,
      {@required this.command,
      @required this.hostMask,
      @required this.messageRemoteId,
      @required this.text,
      @required this.params,
      @required this.regularMessageType,
      @required this.self,
      @required this.highlight,
      @required this.previews,
      @required DateTime date,
      @required this.fromRemoteId,
      @required this.fromNick,
      @required this.newNick,
      @required this.fromMode})
      : super(ChatMessageType.REGULAR, channelRemoteId, date);

  bool get isHaveFromNick => fromNick != null;



  @override
  String toString() {
    return 'RegularMessage{command: $command, hostMask: $hostMask,'
        ' text: $text, params: $params,'
        ' regularMessageType: $regularMessageType,'
        ' self: $self, highlight: $highlight,'
        ' previews: $previews, date: $date,'
        ' fromRemoteId: $fromRemoteId,'
        ' fromNick: $fromNick,'
        ' fromMode: $fromMode, newNick: $newNick}';
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
  CTCP_REQUEST,

}
