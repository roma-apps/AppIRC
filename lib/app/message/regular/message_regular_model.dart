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

  // todo: should be final
  List<MessagePreview> previews;

  final List<String> nicknames;

  RegularMessage({
    @required int channelRemoteId,
    @required int channelLocalId,
    @required DateTime date,
    @required List<String> linksInMessage,
    @required int messageLocalId,
    @required this.command,
    @required this.hostMask,
    @required this.messageRemoteId,
    @required this.text,
    @required this.params,
    @required this.regularMessageType,
    @required this.self,
    @required this.highlight,
    @required this.previews,
    @required this.fromRemoteId,
    @required this.fromNick,
    @required this.newNick,
    @required this.nicknames,
    @required this.fromMode,
  }) : super(
          chatMessageType: ChatMessageType.regular,
          channelRemoteId: channelRemoteId,
          channelLocalId: channelLocalId,
          date: date,
          linksInMessage: linksInMessage,
          messageLocalId: messageLocalId,
        );

  @override
  RegularMessage copyWith({
    int messageLocalId,
    int channelLocalId,
    int channelRemoteId,
    DateTime date,
    List<String> linksInMessage,
    int messageRemoteId,
    String command,
    String hostMask,
    String text,
    List<String> params,
    RegularMessageType regularMessageType,
    bool self,
    bool highlight,
    int fromRemoteId,
    String fromNick,
    String fromMode,
    String newNick,
    List<MessagePreview> previews,
    List<String> nicknames,
  }) {
    return RegularMessage(
      messageLocalId: messageLocalId ?? this.messageLocalId,
      channelLocalId: channelLocalId ?? this.channelLocalId,
      channelRemoteId: channelRemoteId ?? this.channelRemoteId,
      date: date ?? this.date,
      linksInMessage: linksInMessage ?? this.linksInMessage,
      messageRemoteId: messageRemoteId ?? this.messageRemoteId,
      command: command ?? this.command,
      hostMask: hostMask ?? this.hostMask,
      text: text ?? this.text,
      params: params ?? this.params,
      regularMessageType: regularMessageType ?? this.regularMessageType,
      self: self ?? this.self,
      highlight: highlight ?? this.highlight,
      fromRemoteId: fromRemoteId ?? this.fromRemoteId,
      fromNick: fromNick ?? this.fromNick,
      fromMode: fromMode ?? this.fromMode,
      newNick: newNick ?? this.newNick,
      previews: previews ?? this.previews,
      nicknames: nicknames ?? this.nicknames,
    );
  }

  bool get isHaveFromNick => fromNick != null;

  @override
  String toString() {
    return 'RegularMessage{'
        'command: $command, hostMask: $hostMask,'
        ' text: $text, params: $params,'
        ' regularMessageType: $regularMessageType,'
        ' self: $self, highlight: $highlight,'
        ' previews: $previews, date: $date,'
        ' fromRemoteId: $fromRemoteId,'
        ' fromNick: $fromNick,'
        ' nicknames: $nicknames,'
        ' linksInText: $linksInMessage,'
        ' messageLocalId: $messageLocalId,'
        ' messageRemoteId: $messageRemoteId,'
        ' channelRemoteId: $channelRemoteId,'
        ' channelLocalId: $channelLocalId,'
        ' fromMode: $fromMode, newNick: $newNick'
        '}';
  }

  @override
  bool isContainsText(
    String searchTerm, {
    @required bool ignoreCase,
  }) {
    var contains = false;

    contains |= isContainsSearchTerm(
      fromNick,
      searchTerm,
      ignoreCase: ignoreCase,
    );
    if (!contains) {
      contains |= isContainsSearchTerm(
        text,
        searchTerm,
        ignoreCase: ignoreCase,
      );
    }

    return contains;
  }

  @override
  Future<List<String>> extractLinks() async {
    return await findUrls(
      [
        text,
      ],
    );
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
  monospaceBlock,
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
