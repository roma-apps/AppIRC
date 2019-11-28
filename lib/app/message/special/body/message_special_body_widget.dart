import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';

abstract class SpecialMessageBodyWidget<T extends SpecialMessageBody>
    extends StatelessWidget {
  final SpecialMessage message;
  final T body;
  final bool inSearchResults;
  final MessageWidgetType messageWidgetType;

  SpecialMessageBodyWidget(
      {@required this.message,
      @required this.body,
      @required this.inSearchResults,
      @required this.messageWidgetType
      });

  String getBodyRawText(BuildContext context);
}


