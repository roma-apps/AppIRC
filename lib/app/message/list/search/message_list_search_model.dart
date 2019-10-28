
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';

class MessageListSearchState {
  final List<ChatMessage> foundMessages;
  final String searchTerm;
  final ChatMessage selectedFoundMessage;

  get maxPossibleSelectedFoundPosition =>
      foundMessages?.isNotEmpty == true ? foundMessages.length : null;

  get selectedFoundMessagePosition {
    var index = selectedFoundMessageIndex;
    return index != -1 ? index + 1 : null;
  }

  int get selectedFoundMessageIndex =>
      foundMessages?.indexOf(selectedFoundMessage) ?? -1;

  bool get isCanMoveNext {
    var index = selectedFoundMessageIndex;
    return index >= 0 && index < foundMessages.length - 1;
  }

  bool get isCanMovePrevious => selectedFoundMessageIndex > 0;

  MessageListSearchState.name(
      {@required this.foundMessages,
        @required this.searchTerm,
        @required this.selectedFoundMessage});

  static get empty => MessageListSearchState.name(
      foundMessages: [], searchTerm: null, selectedFoundMessage: null);

  @override
  String toString() {
    return 'MessageListSearchState{foundMessages: $foundMessages,'
        ' searchTerm: $searchTerm,'
        ' selectedFoundMessageIndex: $selectedFoundMessageIndex}';
  }

  bool isMessageInSearchResults(ChatMessage message) =>
      foundMessages?.contains(message) ?? false;
}

