import 'package:flutter/gestures.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';

typedef dynamic SpanTapCallback(String span, OffsetPair position);

class SpanMatch {
  final int start;
  final int end;
  final SpanBuilder highlighter;

  int get length => end - start;

  SpanMatch(
    this.start,
    this.end,
    this.highlighter,
  );

  @override
  String toString() {
    return 'SpanHighlightMatch{'
        'start: $start, end: $end,'
        ' highlighter: $highlighter'
        '}';
  }
}
