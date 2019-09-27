import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _splitSeparator = " ";

var _logger = MyLogger(logTag: "ChatInputMessageBloc", enabled: true);

class ChatInputMessageBloc extends Providable {
  final NetworkChannelBloc channelBloc;
  final List<String> commands;
  final messageController = TextEditingController();

  String get message => messageController.text;

  List<AutoCompleteProvider> autoCompleteProviders;

  ChatInputMessageBloc(this.commands, this.channelBloc) {
    autoCompleteProviders = [
      CommandsAutoCompleteProvider(commands),
      NamesAutoCompleteProvider(channelBloc)
    ];

    addDisposable(textEditingController: messageController);
  }

  @override
  void dispose() {
    super.dispose();
    autoCompleteProviders.forEach((provider) => provider.dispose());
  }

  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    List<String> suggestions = [];

    if (pattern != null && pattern.isNotEmpty) {
      for (var provider in autoCompleteProviders) {
        suggestions
            .addAll(await provider.calculateAutoCompleteSuggestions(pattern));
      }
    }

    _logger.d(() => "Suggestions for $pattern is $suggestions");
    return suggestions;
  }

  void sendMessage() {
    channelBloc.sendNetworkChannelRawMessage(messageController.text);
  }

  void onAutoCompleteSelected(String selectedSuggestion) {
    var lastWord = _findLastWord(message);

    messageController.text = message.replaceAll(lastWord, selectedSuggestion);

    _logger.d(() =>
        "after onAutoCompleteSelected $message suggestion = $selectedSuggestion");
  }
}

abstract class AutoCompleteProvider extends Providable {
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern);
}

class CommandsAutoCompleteProvider extends AutoCompleteProvider {
  final List<String> commands;

  CommandsAutoCompleteProvider(this.commands);

  @override
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    var indexOf = pattern.indexOf(_splitSeparator);

    if (indexOf >= 0) {
      // contains spaces
      return [];
    }

    return commands.where((command) => command.startsWith(pattern)).toList();
  }
}

class NamesAutoCompleteProvider extends AutoCompleteProvider {
  NetworkChannelBloc channelBloc;

  NamesAutoCompleteProvider(this.channelBloc) {
    addDisposable(
        timer: Timer.periodic(Duration(seconds: 60), (_) {
      // TODO: rework user updating
      channelBloc.getNetworkChannelUsers();
    }));
  }

  @override
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    String lastWord = _findLastWord(pattern);

    // TODO: rework filter
    if (lastWord != null && lastWord.length > 2) {
      var users = channelBloc.users;
      lastWord = lastWord.toLowerCase();
      return users
          .map((user) => user.nick)
          .where((nick) => nick.toLowerCase().startsWith(pattern))
          .toList();
    } else {
      return [];
    }
  }
}

String _findLastWord(String pattern) {
  var lastIndexOfSeparator = pattern.lastIndexOf(_splitSeparator);
  String lastWord;

  if (lastIndexOfSeparator == -1) {
    lastWord = pattern;
  } else {
    if (lastIndexOfSeparator < pattern.length - 1) {
      lastWord = pattern.substring(lastIndexOfSeparator);
    }
  }
  return lastWord;
}
