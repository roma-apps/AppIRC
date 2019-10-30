import 'package:flutter/gestures.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter.dart';

typedef dynamic WordSpanTapCallback(String word, OffsetPair position);

class SpanHighlightMatch {
  final int start;
  final int end;

  int get length => end - start;
  final SpanHighlighter highlighter;

  SpanHighlightMatch(this.start, this.end, this.highlighter);

  @override
  String toString() {
    return 'SpanHighlightMatch{start: $start, end: $end,'
        ' highlighter: $highlighter}';
  }
}
