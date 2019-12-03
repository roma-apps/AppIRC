import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/url/url_finder.dart';

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

  List<String> nicknames;

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
      List<String> linksInText,
      this.newNick,
      this.nicknames,
      this.fromRemoteId,
      this.fromNick,
      this.fromMode)
      : super(ChatMessageType.regular, channelRemoteId, date, linksInText);

  RegularMessage.name(int channelRemoteId,
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
      @required List<String> linksInText,
      @required this.fromRemoteId,
      @required this.fromNick,
      @required this.newNick,
      @required this.nicknames,
      int messageLocalId,
      @required this.fromMode})
      : super(ChatMessageType.regular, channelRemoteId, date, linksInText,
            messageLocalId: messageLocalId);

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
        ' nicknames: $nicknames,'
        ' linksInText: $linksInText,'
        ' messageLocalId: $messageLocalId,'
        ' messageRemoteId: $messageRemoteId,'
        ' channelRemoteId: $channelRemoteId,'
        ' channelLocalId: $channelLocalId,'
        ' fromMode: $fromMode, newNick: $newNick}';
  }

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) {
    var contains = false;

    contains |=
        isContainsSearchTerm(fromNick, searchTerm, ignoreCase: ignoreCase);
    if (!contains) {
      contains |=
          isContainsSearchTerm(text, searchTerm, ignoreCase: ignoreCase);
    }

    return contains;
  }

  @override
  Future<List<String>> extractLinks() async {
    return await findUrls([
      text
    ]);
  }

}

enum RegularMessageType {
  topicSetBy,
  topic,
  whoIs,
  unhandled,
  unknown,
  message,
  join,
  mode,
  motd,
  notice,
  error,
  away,
  back,
  raw,
  modeChannel,
  quit,
  part,
  nick,
  ctcpRequest,
  action,
  invite,
  ctcp,
  chghost,
  kick,
}
