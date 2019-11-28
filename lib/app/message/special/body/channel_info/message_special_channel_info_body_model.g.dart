// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_special_channel_info_body_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelInfoSpecialMessageBody _$ChannelInfoSpecialMessageBodyFromJson(
    Map<String, dynamic> json) {
  return ChannelInfoSpecialMessageBody(
    json['name'] as String,
    json['topic'] as String,
    json['usersCount'] as int,
  );
}

Map<String, dynamic> _$ChannelInfoSpecialMessageBodyToJson(
        ChannelInfoSpecialMessageBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'topic': instance.topic,
      'usersCount': instance.usersCount,
    };
