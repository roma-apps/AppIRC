import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';
import 'package:flutter_appirc/url/url_launcher.dart';

final String _mailToPrefix = "mailto:";

_openEmail(String word) {
  // email
  if (!word.contains(_mailToPrefix)) {
    word = _mailToPrefix + word;
  }
  _openURL(word);
}

bool _isEmail(String word) => word.contains("@");

SpanBuilder buildLinkHighlighter(
    {@required BuildContext context, @required String link}) {
  MessageSkinBloc messagesSkinBloc = Provider.of(context);
  return SpanBuilder.name(
      highlightString: link,
      highlightTextStyle: messagesSkinBloc.linkTextStyle,
      tapCallback: (word, screenPosition) {
        var isEmail = _isEmail(word);
        if (isEmail) {
          // email
          _openEmail(word);
        } else {
          // url
          _openURL(word);
        }
      });
}

void _openURL(String word) => handleLinkClick(word);
