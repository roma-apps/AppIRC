import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';
import 'package:flutter_appirc/url/url_launcher.dart';

final String _mailToPrefix = "mailto:";

Future<bool> _openEmail(String word) {
  var contains = word.contains(
    _mailToPrefix,
  );
  if (!contains) {
    word = _mailToPrefix + word;
  }
  return _openURL(word);
}

bool _isEmail(String word) => word.contains("@");

SpanBuilder buildLinkHighlighter({
  @required BuildContext context,
  @required String link,
}) {
  return SpanBuilder(
    highlightString: link,
    highlightTextStyle: IAppIrcUiTextTheme.of(context)
        .mediumPrimary
        .copyWith(fontFamily: messagesFontFamily),
    tapCallback: (word, screenPosition) {
      var isEmail = _isEmail(word);
      if (isEmail) {
        // email
        _openEmail(word);
      } else {
        // url
        _openURL(word);
      }
    },
  );
}

Future<bool> _openURL(String word) => handleLinkClick(word);
