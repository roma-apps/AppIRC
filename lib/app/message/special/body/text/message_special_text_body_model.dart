import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:flutter_appirc/url/url_finder.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_special_text_body_model.g.dart';

@JsonSerializable()
class TextSpecialMessageBody extends SpecialMessageBody {
  final String message;

  @override
  bool isContainsText(
    String searchTerm, {
    @required bool ignoreCase,
  }) =>
      isContainsSearchTerm(
        message,
        searchTerm,
        ignoreCase: ignoreCase,
      );

  @override
  String toString() {
    return 'LoadingSpecialMessageBody{message: $message}';
  }

  TextSpecialMessageBody({
    @required this.message,
  });

  factory TextSpecialMessageBody.fromJson(Map<String, dynamic> json) =>
      _$TextSpecialMessageBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextSpecialMessageBodyToJson(this);

  @override
  Future<List<String>> extractLinks() => findUrls(
        [
          message,
        ],
      );
}
