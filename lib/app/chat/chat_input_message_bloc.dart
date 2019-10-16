import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _splitSeparator = " ";

var _logger = MyLogger(logTag: "ChatInputMessageBloc", enabled: true);

class ChatInputMessageBloc extends Providable {
  final ChatConfig chatConfig;
  final NetworkChannelBloc channelBloc;

  var messageController = TextEditingController();

  List<AutoCompleteProvider> autoCompleteProviders;

  ChatInputMessageBloc(this.chatConfig, this.channelBloc) {
    if (channelBloc.channel.isCanHaveSeveralUsers) {
      autoCompleteProviders = [
        CommandsAutoCompleteProvider(chatConfig.commands),
        NamesAutoCompleteProvider(channelBloc)
      ];
    } else {
      autoCompleteProviders = [
        CommandsAutoCompleteProvider(chatConfig.commands),
      ];
    }
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
    messageController.text = "";
  }

  void onAutoCompleteSelected(String selectedSuggestion) {
    var currentMessage = messageController.text;
    var lastWord = _findLastWord(currentMessage);

    var replaceText = "$selectedSuggestion ";
    var newMessage = currentMessage.replaceAll(lastWord, replaceText);

    messageController.text = newMessage;
    messageController.selection =
        TextSelection.fromPosition(TextPosition(offset: newMessage.length));

    _logger.d(() =>
        "after onAutoCompleteSelected $currentMessage replaceText = $replaceText newMessage = $newMessage");
  }

  void appendText(String remoteURL) {
    messageController.text += remoteURL;
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

    return commands
        .where((command) => command.startsWith(pattern) && command != pattern)
        .toList();
  }
}

class NamesAutoCompleteProvider extends AutoCompleteProvider {
  NetworkChannelBloc channelBloc;

  NamesAutoCompleteProvider(this.channelBloc);

  @override
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    String lastWord = _findLastWord(pattern);

    // TODO: rework filter
    if (lastWord != null && lastWord.length > 2) {
      var users = await channelBloc.getUsers();
      var lastWordLowerCase = lastWord.toLowerCase();
      return users.map((user) => user.nick).where((nick) {
        var nickLowerCase = nick.toLowerCase();
        return nickLowerCase.startsWith(lastWordLowerCase) &&
            lastWordLowerCase != nickLowerCase;
      }).toList();
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
    if (lastIndexOfSeparator < pattern.length - 2) {
      lastWord = pattern.substring(lastIndexOfSeparator + 1);
    }
  }
  return lastWord;
}
