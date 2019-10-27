// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_preview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagePreview _$MessagePreviewFromJson(Map<String, dynamic> json) {
  return MessagePreview(
    json['head'] as String,
    json['body'] as String,
    json['canDisplay'] as bool,
    json['shown'] as bool,
    json['link'] as String,
    json['thumb'] as String,
    json['media'] as String,
    json['mediaType'] as String,
    _$enumDecodeNullable(_$MessagePreviewTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$MessagePreviewToJson(MessagePreview instance) =>
    <String, dynamic>{
      'head': instance.head,
      'body': instance.body,
      'canDisplay': instance.canDisplay,
      'shown': instance.shown,
      'link': instance.link,
      'thumb': instance.thumb,
      'media': instance.media,
      'mediaType': instance.mediaType,
      'type': _$MessagePreviewTypeEnumMap[instance.type],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$MessagePreviewTypeEnumMap = {
  MessagePreviewType.link: 'link',
  MessagePreviewType.image: 'image',
  MessagePreviewType.loading: 'loading',
  MessagePreviewType.audio: 'audio',
  MessagePreviewType.video: 'video',
};
