import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_special_channel_info_body_model.g.dart';

@JsonSerializable()
class ChannelInfoSpecialMessageBody extends SpecialMessageBody {
  final String name;
  final String topic;
  final int usersCount;

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) {
    var contains = false;

    contains |= isContainsSearchTerm(name, searchTerm, ignoreCase: ignoreCase);
    if (!contains) {
      contains |=
          isContainsSearchTerm(topic, searchTerm, ignoreCase: ignoreCase);
    }

    return contains;
  }

  @override
  String toString() {
    return 'ChannelInfoSpecialMessageBody{name: $name, '
        'topic: $topic, usersCount: $usersCount}';
  }

  ChannelInfoSpecialMessageBody(this.name, this.topic, this.usersCount);

  ChannelInfoSpecialMessageBody.name(
      {@required this.name, @required this.topic, @required this.usersCount});

  factory ChannelInfoSpecialMessageBody.fromJson(Map<String, dynamic> json) =>
      _$ChannelInfoSpecialMessageBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChannelInfoSpecialMessageBodyToJson(this);
}
