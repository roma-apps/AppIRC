import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_widget.dart';
import 'package:flutter_appirc/app/message/special/body/text/message_special_text_body_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';

class TextSpecialMessageBodyWidget
    extends SpecialMessageBodyWidget<TextSpecialMessageBody> {
  TextSpecialMessageBodyWidget(
      {@required SpecialMessage message,
        @required TextSpecialMessageBody body,
        @required bool inSearchResults,
        @required MessageWidgetType messageWidgetType})
      : super(
            message: message,
            body: body,
            inSearchResults: inSearchResults,
            messageWidgetType: messageWidgetType);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(body.message),
    );
  }

  @override
  String getBodyRawText(BuildContext context) {
    return body.message;
  }
}
