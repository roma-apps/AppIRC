import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:intl/intl.dart';

var regularDateFormatter = DateFormat().add_yMd().add_Hm();

class SpecialMessage extends ChatMessage {
  final SpecialMessageBody data;
  final SpecialMessageType specialType;

  SpecialMessage({
    @required int channelLocalId,
    @required int channelRemoteId,
    @required this.data,
    @required this.specialType,
    @required int messageLocalId,
    @required DateTime date,
    @required List<String> linksInMessage,
  }) : super(
          channelLocalId: channelLocalId,
          channelRemoteId: channelRemoteId,
          chatMessageType: ChatMessageType.special,
          date: date,
          linksInMessage: linksInMessage,
          messageLocalId: messageLocalId,
        );

  @override
  SpecialMessage copyWith({
    int messageLocalId,
    int channelLocalId,
    int channelRemoteId,
    DateTime date,
    List<String> linksInMessage,
    SpecialMessageBody data,
    SpecialMessageType specialType,
  }) {
    return SpecialMessage(
      messageLocalId: messageLocalId ?? this.messageLocalId,
      channelLocalId: channelLocalId ?? this.channelLocalId,
      channelRemoteId: channelRemoteId ?? this.channelRemoteId,
      date: date ?? this.date,
      linksInMessage: linksInMessage ?? this.linksInMessage,
      data: data ?? this.data,
      specialType: specialType ?? this.specialType,
    );
  }

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
