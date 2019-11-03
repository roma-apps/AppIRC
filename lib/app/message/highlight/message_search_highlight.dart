import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';

SpanBuilder buildSearchSpanHighlighter(
    {@required BuildContext context, @required String searchTerm}) {
  MessageSkinBloc messagesSkinBloc = Provider.of(context);

  return SpanBuilder.name(
      highlightString: searchTerm,
      highlightTextStyle: messagesSkinBloc.messageHighlightTextStyle,
      tapCallback: null);
}
