import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/input_message/autocomplete/chat_input_message_commands_autocomplete.dart';
import 'package:flutter_appirc/app/chat/input_message/autocomplete/chat_input_message_names_autocomplete.dart';
import 'package:flutter_appirc/autocomplete/autocomplete.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/logger/logger.dart';

var _logger = MyLogger(logTag: "chat_input_message_bloc.dart", enabled: true);

class ChatInputMessageBloc extends DisposableOwner {
  final ChatConfig chatConfig;
  final ChannelBloc channelBloc;

  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  List<AutoCompleter> autoCompleters;

  ChatInputMessageBloc(this.chatConfig, this.channelBloc) {
    if (channelBloc.channel.isCanHaveSeveralUsers) {
      autoCompleters = [
        CommandsAutoCompleter(chatConfig.commands),
        NamesAutoCompleter(channelBloc)
      ];
    } else {
      autoCompleters = [
        CommandsAutoCompleter(chatConfig.commands),
      ];
    }
  }

  @override
  Future dispose() async {
    await super.dispose();
    await autoCompleters.forEach((autoCompleter) => autoCompleter.dispose(),);
  }

  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    List<String> suggestions = [];

    if (pattern != null && pattern.isNotEmpty) {
      for (var provider in autoCompleters) {
        suggestions
            .addAll(await provider.calculateAutoCompleteSuggestions(pattern));
      }
    }

    _logger.d(() => "Suggestions for $pattern is $suggestions");
    return suggestions;
  }

  void sendMessage() {
    channelBloc.sendChannelRawMessage(messageController.text);
    messageController.text = "";
  }

  void onAutoCompleteSelected(String selectedSuggestion) {
    var currentMessage = messageController.text;
    var lastWord = findLastWord(currentMessage);

    var replaceText = "$selectedSuggestion ";
    var newMessage = currentMessage.replaceAll(lastWord, replaceText);

    messageController.text = newMessage;
    messageController.selection =
        TextSelection.fromPosition(TextPosition(offset: newMessage.length));

    _logger.d(() =>
    "after onAutoCompleteSelected $currentMessage "
        "replaceText = $replaceText newMessage = $newMessage");
  }

  void appendText(String remoteURL) {
    messageController.text += remoteURL;
  }
}
