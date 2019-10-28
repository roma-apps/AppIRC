import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/platform_aware/platform_aware.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter_model.dart';

class SpanHighlighter {
  final String highlightString;
  final TextStyle highlightTextStyle;
  final WordSpanTapCallback tapCallback;

  RegExp regExp;

  SpanHighlighter.name(
      {@required this.highlightString,
      @required this.highlightTextStyle,
      @required this.tapCallback}) {
    regExp = RegExp("$highlightString", caseSensitive: false);
  }

  TextSpan createTextSpan(String word) {
    TapGestureRecognizer gestureRecognizer;
    if (tapCallback != null) {
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () {
          tapCallback(word, gestureRecognizer.initialPosition);
        };
    }
    var textSpan = TextSpan(
        text: word, style: highlightTextStyle, recognizer: gestureRecognizer);

    return textSpan;
  }

  Iterable<RegExpMatch> findAllMatches(String text) {
    return regExp.allMatches(text);
  }
}

Widget buildWordSpannedRichText(BuildContext context, String text,
    TextStyle defaultTextStyle, List<SpanHighlighter> wordSpanBuilders) {
  var builderToRegExpMatches = Map<SpanHighlighter, Iterable<RegExpMatch>>();
  var totalMatch = 0;
  wordSpanBuilders.forEach((spanBuilder) {
    Iterable<RegExpMatch> allMatches = spanBuilder.findAllMatches(text);
    builderToRegExpMatches[spanBuilder] = allMatches;
    totalMatch += allMatches.length;
  });

  var spans = <TextSpan>[];

  if (totalMatch > 0) {
    int lastSpanMatchEndIndex = 0;
    RegExpMatch currentSpanMatch;
    SpanHighlighter currentSpanBuilder;
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
          style: defaultTextStyle,
          children: spans,
        ),
      );
    } else {
      // TODO: enable text selection for cupertino when it will be available
      return RichText(
        text: TextSpan(
          style: defaultTextStyle,
          children: spans,
        ),
      );
    }
  } else {
//      return Text(text, style: textStyle);
    if (isMaterial) {
      return SelectableText(text, style: defaultTextStyle);
    } else {
      // TODO: enable text selection for cupertino when it will be available
      return Text(text, style: defaultTextStyle);
    }
  }
}

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
    var textSpan = TextSpan(
        text: word, style: highlightTextStyle, recognizer: gestureRecognizer);

    return textSpan;
  }
}
