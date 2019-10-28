import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter.dart';

SpanHighlighter buildSearchSpanHighlighter(
    {@required BuildContext context, @required String searchTerm}) {
  MessageSkinBloc messagesSkinBloc = Provider.of(context);

  return SpanHighlighter.name(
      highlightString: searchTerm,
      highlightTextStyle: messagesSkinBloc.messageHighlightTextStyle,
      tapCallback: null);
}
