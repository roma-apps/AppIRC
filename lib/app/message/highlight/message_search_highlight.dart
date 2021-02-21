import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';

SpanBuilder buildSearchSpanHighlighter({
  @required BuildContext context,
  @required String searchTerm,
}) {
  var appIrcUiTextTheme = IAppIrcUiTextTheme.of(context);
  return SpanBuilder.name(
    highlightString: searchTerm,
    highlightTextStyle: appIrcUiTextTheme.mediumBoldDarkGrey,
    tapCallback: null,
  );
}
