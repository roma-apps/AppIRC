import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'messages_preview_model.g.dart';

@JsonSerializable()
class MessagePreview {
  final String head;
  final String body;
  final bool canDisplay;
  final bool shown;
  final String link;
  final String thumb;
  final MessagePreviewType type;

  MessagePreview(this.head, this.body, this.canDisplay, this.shown, this.link,
      this.thumb, this.type);

  MessagePreview.name(
      {@required this.head,
      @required this.body,
      @required this.canDisplay,
      @required this.shown,
      @required this.link,
      @required this.thumb,
      @required this.type});

  @override
  String toString() {
    return 'MessagePreview{head: $head, body: $body, '
        'canDisplay: $canDisplay, shown: $shown,'
        ' link: $link, thumb: $thumb, type: $type}';
  }

  factory MessagePreview.fromJson(Map<String, dynamic> json) =>
      _$MessagePreviewFromJson(json);
}

enum MessagePreviewType { LINK, IMAGE, LOADING }
