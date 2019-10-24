import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'messages_preview_model.g.dart';

class PreviewForMessage {
  int remoteMessageId;
  MessagePreview messagePreview;

  PreviewForMessage(this.remoteMessageId,this.messagePreview);

  @override
  String toString() {
    return 'PreviewForMessage{messageId: $remoteMessageId, '
        'messagePreview: $messagePreview}';
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


  MessagePreview(this.head, this.body, this.canDisplay, this.shown, this.link,
      this.thumb, this.media, this.mediaType, this.type);

  MessagePreview.name(
      {@required this.head,
      @required this.body,
      @required this.canDisplay,
      @required this.shown,
      @required this.link,
      @required this.thumb,
      @required this.media,
      @required this.mediaType,
      @required this.type});


  @override
  String toString() {
    return 'MessagePreview{head: $head, body: $body, '
        'canDisplay: $canDisplay, shown: $shown, '
        'link: $link, thumb: $thumb, '
        'media: $media, mediaType: $mediaType, type: $type}';
  }

  factory MessagePreview.fromJson(Map<String, dynamic> json) =>
      _$MessagePreviewFromJson(json);

  Map<String, dynamic> toJson() => _$MessagePreviewToJson(this);
}

enum MessagePreviewType { LINK, IMAGE, LOADING, AUDIO, VIDEO }
