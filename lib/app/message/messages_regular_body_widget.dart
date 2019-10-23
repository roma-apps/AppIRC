import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/user/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

final MyLogger _logger =
    MyLogger(logTag: "messages_regular_body_widget", enabled: true);

typedef dynamic WordSpanTapCallback(String word, OffsetPair position);

dynamic handleLinkClick(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget buildRegularMessageBody(BuildContext context, String text,
    {List<String> nicknames}) {


  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var regularMessageBodyTextStyle = messagesSkin.regularMessageBodyTextStyle;
  var linkTextStyle =
      messagesSkin.modifyToLinkTextStyle(regularMessageBodyTextStyle);
  var spanBuilders = <WordSpanBuilder>[
    // TODO : rework
//    LinkWordSpanBuilder(linkTextStyle, (word, _) async {
//      var isEmail = word.contains("@");
//      if (isEmail) {
//        // email
//        var prefix = "mailto:";
//        if (!word.contains(prefix)) {
//          word = prefix + word;
//        }
//        return handleLinkClick(word);
//      } else {
//        // url
//        return handleLinkClick(word);
//      }
//    }),
  ];

  if (nicknames != null) {
    var nickNamesBloc = Provider.of<ColoredNicknamesBloc>(context);
//    spanBuilders.addAll(nicknames.map((nickname) {
//      return SimpleWordSpanBuilder(
//          nickname,
//          regularMessageBodyTextStyle.copyWith(
//              color: nickNamesBloc.getColorForNick(nickname)),
//          (word, screenPosition) {
//        var local = screenPosition.global;
//        RelativeRect position =
//            RelativeRect.fromLTRB(local.dx, local.dy, local.dx, local.dy);
//        NetworkChannelBloc channelBloc = Provider.of(context);
//        String nick = word;
//        showPopupMenuForUser(context, position, nick, channelBloc);
//      });
//    }));
  }

  return buildWordSpannedRichText(
      context, text, regularMessageBodyTextStyle, spanBuilders);
}

Widget buildWordSpannedRichText(BuildContext context, String text,
    TextStyle textStyle, List<HighlightStringSpanBuilder> wordSpanBuilders) {
  var builderToRegExpMatches = Map<WordSpanBuilder, Iterable<RegExpMatch>>();
  var totalMatch = 0;
  wordSpanBuilders.forEach((spanBuilder) {
    var allMatches = spanBuilder.findRegExp.allMatches(text);
    builderToRegExpMatches[spanBuilder] = allMatches;
    totalMatch += allMatches.length;
  });

  var spans = <TextSpan>[];

  if (totalMatch > 0) {
    int lastSpanMatchEndIndex = 0;
    RegExpMatch currentSpanMatch;
    WordSpanBuilder currentSpanBuilder;
    for (var index = 0; index < text.length; index++) {
      if (currentSpanMatch != null && index < currentSpanMatch.end) {
        continue;
      }

      if (currentSpanMatch != null && index == currentSpanMatch.end) {
        spans.add(currentSpanBuilder.createTextSpan(
            text.substring(currentSpanMatch.start, currentSpanMatch.end)));
        lastSpanMatchEndIndex = currentSpanMatch.end;
        currentSpanMatch = null;
        continue;
      }

      builderToRegExpMatches.forEach((builder, matches) {
        matches.forEach((match) {
          if (match.start == index) {
            currentSpanBuilder = builder;
            currentSpanMatch = match;

            if (lastSpanMatchEndIndex != index) {
              spans.add(
                  TextSpan(text: text.substring(lastSpanMatchEndIndex, index)));
            }
          }
        });
      });
    }
    if (currentSpanMatch != null) {
      spans.add(currentSpanBuilder.createTextSpan(
          text.substring(currentSpanMatch.start, currentSpanMatch.end)));
    } else {
      if (lastSpanMatchEndIndex < text.length) {
        spans.add(
            TextSpan(text: text.substring(lastSpanMatchEndIndex, text.length)));
      }
    }

    if (isMaterial) {
      return SelectableText.rich(
        TextSpan(
          style: textStyle,
          children: spans,
        ),
      );
    } else {
      // TODO: enable text selection for cupertino when it will be available
      return RichText(
        text: TextSpan(
          style: textStyle,
          children: spans,
        ),
      );
    }
  } else {
//      return Text(text, style: textStyle);
    if (isMaterial) {
      return SelectableText(text, style: textStyle);
    } else {
      // TODO: enable text selection for cupertino when it will be available
      return Text(text, style: textStyle);
    }
  }

//    var splitRegex = "";
//
//    builderToRegExpMatches.forEach((_, matches) {
//      matches.forEach((match) {
//        splitRegex += match.;
//      });
//    });

//    text.split("")

//    var words = text.split(wordSplitRegex);
//
//    _logger.d(() => "split '$text' to ${words.join('"')}");
//
//
//
//    var lastWordIndex = words.length - 1;
//    for (int i = 0; i < words.length; i++) {
//      var word = words[i];
//      var wordWithPostSpace;
////    if (i == lastWordIndex) {
////      wordWithPostSpace = word;
////    } else {
////      wordWithPostSpace = word + " "; // not last
////    }
//      TextSpan resultSpan;
//
//      for (var wordSpanBuilder in wordSpanBuilders) {
//        if (wordSpanBuilder.isBuilderCanHandleWord(word)) {
//          resultSpan = wordSpanBuilder.createTextSpan(wordWithPostSpace);
//          break;
//        }
//      }
//
//      spans.add(resultSpan ??= TextSpan(text: wordWithPostSpace));
//    }
}

//}

abstract class WordSpanBuilder {
  final RegExp findRegExp;
  final TextStyle highlightTextStyle;
  final WordSpanTapCallback tapCallback;

  WordSpanBuilder(this.findRegExp, this.highlightTextStyle, {this.tapCallback});

  TextSpan createTextSpan(String word) {
    TapGestureRecognizer gestureRecognizer;
    if (tapCallback != null) {
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () {
          tapCallback(word, gestureRecognizer.initialPosition);
        };
    }
    var textSpan =
        TextSpan(text: word, style: highlightTextStyle, recognizer: gestureRecognizer);

    return textSpan;
  }
}
//
//class LinkWordSpanBuilder extends WordSpanBuilder {
//
//
//  LinkWordSpanBuilder(TextStyle textStyle, WordSpanTapCallback tapCallback)
//      : super(_regex, textStyle, tapCallback: tapCallback);
//}

//class SimpleWordSpanBuilder extends WordSpanBuilder {
//  final String word;
//
//  SimpleWordSpanBuilder(
//      this.word, TextStyle textStyle, WordSpanTapCallback tapCallback)
//      : super(RegExp("\\b($word)\\b"), textStyle, tapCallback: tapCallback);
//}



class HighlightStringSpanBuilder {
  final String highlightString;
  final TextStyle highlightTextStyle;
  final WordSpanTapCallback tapCallback;

  HighlightStringSpanBuilder(this.highlightString, this.highlightTextStyle,
      this.tapCallback);

  TextSpan createTextSpan(String word) {
    TapGestureRecognizer gestureRecognizer;
    if (tapCallback != null) {
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () {
          tapCallback(word, gestureRecognizer.initialPosition);
        };
    }
    var textSpan =
    TextSpan(text: word, style: highlightTextStyle, recognizer: gestureRecognizer);

    return textSpan;
  }


}
