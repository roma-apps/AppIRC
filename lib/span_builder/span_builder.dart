import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/span_builder/span_builder_model.dart';
import 'package:logging/logging.dart';

var _logger = Logger("span_builder.dart");

class SpanBuilder {
  final String highlightString;
  final TextStyle highlightTextStyle;
  final SpanTapCallback tapCallback;

  final RegExp regExp;

  SpanBuilder({
    @required this.highlightString,
    @required this.highlightTextStyle,
    @required this.tapCallback,
  }) : regExp = RegExp("$highlightString", caseSensitive: false);

  TextSpan createTextSpan(String word) {
    TapGestureRecognizer gestureRecognizer;
    if (tapCallback != null) {
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () {
          tapCallback(
            word,
            gestureRecognizer.initialPosition,
          );
        };
    }
    var textSpan = TextSpan(
      text: word,
      style: highlightTextStyle,
      recognizer: gestureRecognizer,
    );

    return textSpan;
  }

  Iterable<RegExpMatch> findAllMatches(String text) {
    return regExp.allMatches(text);
  }
}

List<TextSpan> createSpans({
  @required BuildContext context,
  @required String text,
  @required TextStyle defaultTextStyle,
  @required List<SpanBuilder> spanBuilders,
}) {
  var builderToRegExpMatches = <SpanBuilder, Iterable<RegExpMatch>>{};

  Map<int, List<SpanMatch>> spanHighlightsStartToList = {};

  spanBuilders.forEach(
    (spanBuilder) {
      Iterable<RegExpMatch> allMatches = spanBuilder.findAllMatches(text);
      builderToRegExpMatches[spanBuilder] = allMatches;
      allMatches.forEach(
        (match) {
          var start = match.start;
          if (!spanHighlightsStartToList.containsKey(start)) {
            spanHighlightsStartToList[start] = <SpanMatch>[];
          }

          spanHighlightsStartToList[start]
              .add(SpanMatch(match.start, match.end, spanBuilder));
        },
      );
    },
  );

  if (spanHighlightsStartToList.isNotEmpty) {
    var spans = <TextSpan>[];

    var sortedIndexes = spanHighlightsStartToList.keys.toList();
    sortedIndexes.sort();

    var lastSpanIndex = 0;

    for (var i = 0; i < sortedIndexes.length; i++) {
      var startIndex = sortedIndexes[i];

      if (startIndex < lastSpanIndex) {
        continue;
        //skin spans inside other spans
      }

      var matchList = spanHighlightsStartToList[startIndex];

      matchList.sort((a, b) => max(a.length, b.length));
      // find biggest span for current start index
      var maxLengthMatch = matchList.first;

      _logger.fine(() => "startIndex $startIndex "
          " matchList : ${matchList.length} "
          "maxLengthMatch $maxLengthMatch");
      if (lastSpanIndex != startIndex) {
        // add non-highlighted text between highlighted spans
        spans.add(TextSpan(
            text: text.substring(lastSpanIndex, startIndex),
            style: defaultTextStyle));
      }

      lastSpanIndex = maxLengthMatch.end;

      var spanHighlighter = maxLengthMatch.highlighter;
      // highlighted spans
      spans.add(spanHighlighter
          .createTextSpan(text.substring(startIndex, lastSpanIndex)));
    }

    // add last non-highlighted text part
    if (lastSpanIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastSpanIndex, text.length),
          style: defaultTextStyle,
        ),
      );
    }
    return spans;
  } else {
    return [
      TextSpan(
        text: text,
        style: defaultTextStyle,
      ),
    ];
  }
}

abstract class WordSpanBuilder {
  final RegExp findRegExp;
  final TextStyle highlightTextStyle;
  final SpanTapCallback tapCallback;

  WordSpanBuilder(
    this.findRegExp,
    this.highlightTextStyle, {
    this.tapCallback,
  });

  TextSpan createTextSpan(String word) {
    TapGestureRecognizer gestureRecognizer;
    if (tapCallback != null) {
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () {
          tapCallback(word, gestureRecognizer.initialPosition);
        };
    }
    var textSpan = TextSpan(
      text: word,
      style: highlightTextStyle,
      recognizer: gestureRecognizer,
    );

    return textSpan;
  }
}
