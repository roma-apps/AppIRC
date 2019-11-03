import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_aware/platform_aware.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter_model.dart';

MyLogger _logger = MyLogger(logTag: "span_highlighter.dart", enabled: true);

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

  Map<int, List<SpanHighlightMatch>> spanHighlightsStartToList = Map();

  wordSpanBuilders.forEach((spanBuilder) {
    Iterable<RegExpMatch> allMatches = spanBuilder.findAllMatches(text);
    builderToRegExpMatches[spanBuilder] = allMatches;
    allMatches.forEach((match) {
      var start = match.start;
      if (!spanHighlightsStartToList.containsKey(start)) {
        spanHighlightsStartToList[start] = <SpanHighlightMatch>[];
      }

      spanHighlightsStartToList[start]
          .add(SpanHighlightMatch(match.start, match.end, spanBuilder));
    });
  });

  if (spanHighlightsStartToList.length > 0) {
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

      _logger.d(() => "startIndex $startIndex "
          " matchList : ${matchList.length} "
          "maxLengthMatch $maxLengthMatch");
      if (lastSpanIndex != startIndex) {
        // add non-highlighted text between highlighted spans
        spans.add(TextSpan(text: text.substring(lastSpanIndex, startIndex)));
      }

      lastSpanIndex = maxLengthMatch.end;

      var spanHighlighter = maxLengthMatch.highlighter;
      // highlighted spans
      spans.add(spanHighlighter
          .createTextSpan(text.substring(startIndex, lastSpanIndex)));
    }

    // add last non-highlighted text part
    if (lastSpanIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastSpanIndex, text.length)));
    }

    if (isMaterial) {
      // todo: enabled text selection for Materials spans
      // Currently SelectableText ignore spans with gesture detection
      // So we disable selection when something highlighted
//      return SelectableText.rich(
//        TextSpan(
//          style: defaultTextStyle,
//          children: spans,
//        ),
//      );

      return RichText(
        text: TextSpan(
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

List<TextSpan> createSpans(BuildContext context, String text,
    TextStyle defaultTextStyle, List<SpanHighlighter> wordSpanBuilders) {
  var builderToRegExpMatches = Map<SpanHighlighter, Iterable<RegExpMatch>>();

  Map<int, List<SpanHighlightMatch>> spanHighlightsStartToList = Map();

  wordSpanBuilders.forEach((spanBuilder) {
    Iterable<RegExpMatch> allMatches = spanBuilder.findAllMatches(text);
    builderToRegExpMatches[spanBuilder] = allMatches;
    allMatches.forEach((match) {
      var start = match.start;
      if (!spanHighlightsStartToList.containsKey(start)) {
        spanHighlightsStartToList[start] = <SpanHighlightMatch>[];
      }

      spanHighlightsStartToList[start]
          .add(SpanHighlightMatch(match.start, match.end, spanBuilder));
    });
  });

  if (spanHighlightsStartToList.length > 0) {
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

      _logger.d(() => "startIndex $startIndex "
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
      spans.add(TextSpan(
          text: text.substring(lastSpanIndex, text.length),
          style: defaultTextStyle));
    }
    return spans;
  } else {
    return [TextSpan(text: text, style: defaultTextStyle)];
//    spans.add(TextSpan(text: text.substring(lastSpanIndex, text.length)));
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
