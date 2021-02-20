import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:intl/intl.dart';

var regularDateFormatter = DateFormat().add_yMd().add_Hm();

class SpecialMessage extends ChatMessage {
  final SpecialMessageBody data;
  final SpecialMessageType specialType;

  SpecialMessage({
    @required int channelRemoteId,
    @required this.data,
    @required this.specialType,
    int messageLocalId,
    @required DateTime date,
    @required List<String> linksInMessage,
  }) : super(
          ChatMessageType.special,
          channelRemoteId,
          date,
          linksInMessage,
          messageLocalId: messageLocalId,
        );

  @override
  Future<List<String>> extractLinks() => data.extractLinks();

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SpecialMessage &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          specialType == other.specialType;

  @override
  int get hashCode => super.hashCode ^ data.hashCode ^ specialType.hashCode;
}

enum SpecialMessageType { whoIs, channelsListItem, text }
