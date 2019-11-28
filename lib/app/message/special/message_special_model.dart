import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:intl/intl.dart';

var regularDateFormatter = new DateFormat().add_yMd().add_Hm();

class SpecialMessage extends ChatMessage {
  final SpecialMessageBody data;
  final SpecialMessageType specialType;

  SpecialMessage(int channelLocalId, int channelRemoteId, this.specialType,
      this.data, DateTime date, List<String> linksInText)
      : super(ChatMessageType.special, channelRemoteId, date, linksInText);

  SpecialMessage.name(
      {@required int channelRemoteId,
      @required this.data,
      @required this.specialType,
      int messageLocalId,
      @required DateTime date,
      @required List<String> linksInMessage})
      : super(
          ChatMessageType.special,
          channelRemoteId,
          date,
          linksInMessage,
          messageLocalId: messageLocalId,
        );

  @override
  Future<List<String>>  extractLinks() => data.extractLinks();

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) =>
      data.isContainsText(searchTerm, ignoreCase: ignoreCase);

  @override
  String toString() {
    return 'SpecialMessage{data: $data,'
        ' specialType: $specialType'
        ' messageLocalId: $messageLocalId,'
        ' channelRemoteId: $channelRemoteId,'
        ' channelLocalId: $channelLocalId,'
        '}';
  }
}

enum SpecialMessageType { whoIs, channelsListItem, text }
