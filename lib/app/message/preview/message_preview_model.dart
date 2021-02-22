import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_preview_model.g.dart';

class ToggleChannelPreviewData {
  Network network;
  Channel channel;
  bool allPreviewsShown;

  ToggleChannelPreviewData({
    @required this.network,
    @required this.channel,
    @required this.allPreviewsShown,
  });

  @override
  String toString() {
    return 'ChannelTogglePreview{'
        'network: $network, '
        'channel: $channel, '
        'allPreviewsShown: $allPreviewsShown'
        '}';
  }
}

class ToggleMessagePreviewData {
  Network network;
  Channel channel;
  RegularMessage message;
  MessagePreview preview;
  bool newShownValue;

  ToggleMessagePreviewData({
    @required this.network,
    @required this.channel,
    @required this.message,
    @required this.preview,
    @required this.newShownValue,
  });

  @override
  String toString() => 'ChatTogglePreview{'
      'network: $network, '
      'channel: $channel, '
      'message: $message, '
      'preview: $preview, '
      'newShownValue: $newShownValue'
      '}';
}

class MessagePreviewForRemoteMessageId {
  int remoteMessageId;
  MessagePreview messagePreview;

  MessagePreviewForRemoteMessageId({
    @required this.remoteMessageId,
    @required this.messagePreview,
  });

  @override
  String toString() {
    return 'PreviewForMessage{'
        'messageId: $remoteMessageId, '
        'messagePreview: $messagePreview'
        '}';
  }
}

@JsonSerializable()
class MessagePreview {
  final String head;
  final String body;
  final bool canDisplay;
  bool shown;
  final String link;
  final String thumb;
  final String media;
  final String mediaType;
  final MessagePreviewType type;

  MessagePreview({
    @required this.head,
    @required this.body,
    @required this.canDisplay,
    @required this.shown,
    @required this.link,
    @required this.thumb,
    @required this.media,
    @required this.mediaType,
    @required this.type,
  });

  @override
  String toString() {
    return 'MessagePreview{'
        'head: $head, '
        'body: $body, '
        'canDisplay: $canDisplay, '
        'shown: $shown, '
        'link: $link, '
        'thumb: $thumb, '
        'media: $media, '
        'mediaType: $mediaType, '
        'type: $type'
        '}';
  }

  factory MessagePreview.fromJson(Map<String, dynamic> json) =>
      _$MessagePreviewFromJson(json);

  Map<String, dynamic> toJson() => _$MessagePreviewToJson(this);
}

enum MessagePreviewType { link, image, loading, audio, video, error }
