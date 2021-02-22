import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/autocomplete/autocomplete.dart';

final _nicknamePrefix = "@";

class NamesAutoCompleter extends AutoCompleter {
  ChannelBloc channelBloc;

  NamesAutoCompleter(this.channelBloc);

  @override
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    String lastWord = findLastWord(pattern);

    if (lastWord != null) {
      if (lastWord.startsWith(_nicknamePrefix)) {
        var users = await channelBloc.retrieveUsers();

        var lastWordWithoutPrefix = lastWord.substring(_nicknamePrefix.length);

        return _calculateSuggestions(
          NamesAutoCompleteRequest(
            lastWordWithoutPrefix,
            users.map((user) => user.nick).toList(),
          ),
        );
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<String>> _calculateSuggestions(
      NamesAutoCompleteRequest request) async {
    var lastWordLowerCase = request.word.toLowerCase();
    return request.usersNames
        .where((nick) {
          var nickLowerCase = nick.toLowerCase();
          return nickLowerCase.startsWith(lastWordLowerCase) &&
              lastWordLowerCase != nickLowerCase; // don't show autocomplete
          // when nick fully entered
        })
        .map((nick) => "$_nicknamePrefix$nick")
        .toList();
  }
}

class NamesAutoCompleteRequest {
  String word;
  List<String> usersNames;

  NamesAutoCompleteRequest(this.word, this.usersNames);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamesAutoCompleteRequest &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          usersNames == other.usersNames;

  @override
  int get hashCode => word.hashCode ^ usersNames.hashCode;

  @override
  String toString() {
    return 'NamesAutoCompleteRequest{word: $word, usersNames: $usersNames}';
  }
}
