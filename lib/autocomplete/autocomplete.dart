import 'package:flutter_appirc/disposable/disposable.dart';

final String splitSeparator = " ";

abstract class AutoCompleter extends Disposable {
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern);
}

String findLastWord(String pattern) {
  var lastIndexOfSeparator = pattern.lastIndexOf(splitSeparator);
  String lastWord;

  if (lastIndexOfSeparator == -1) {
    lastWord = pattern;
  } else {
    if (lastIndexOfSeparator < pattern.length - 2) {
      lastWord = pattern.substring(lastIndexOfSeparator + 1);
    }
  }
  return lastWord;
}
