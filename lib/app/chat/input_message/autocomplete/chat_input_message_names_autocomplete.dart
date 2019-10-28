
import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/autocomplete/autocomplete.dart';

class NamesAutoCompleter extends AutoCompleter {
  static final int minimumCharsCountForAutoComplete = 2;


  ChannelBloc channelBloc;

  NamesAutoCompleter(this.channelBloc);

  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    String lastWord = findLastWord(pattern);

    if (lastWord != null &&
        lastWord.length > minimumCharsCountForAutoComplete) {
      var users = await channelBloc.retrieveUsers();
      return compute(
          _calculateSuggestions,
          NamesAutoCompleteRequest(
              lastWord, users.map((user) => user.nick).toList()));
    } else {
      return [];
    }
  }

  Future<List<String>> _calculateSuggestions(
      NamesAutoCompleteRequest request) async {
    var lastWordLowerCase = request.word.toLowerCase();
    return request.usersNames.where((nick) {
      var nickLowerCase = nick.toLowerCase();
      return nickLowerCase.startsWith(lastWordLowerCase) &&
          lastWordLowerCase != nickLowerCase; // don't show autocomplete
      // when nick fully entered
    }).toList();
  }

  @override
  void dispose() {

  }
}

class NamesAutoCompleteRequest {
  String word;
  List<String> usersNames;

  NamesAutoCompleteRequest(this.word, this.usersNames);
}