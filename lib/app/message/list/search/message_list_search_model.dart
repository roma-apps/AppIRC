import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';

class MessageListSearchState {
  final List<MessageListItem> foundItems;
  final String searchTerm;
  final MessageListItem selectedFoundItem;

  get maxPossibleSelectedFoundPosition =>
      foundItems?.isNotEmpty == true ? foundItems.length : null;

  get selectedFoundMessagePosition {
    var index = selectedFoundMessageIndex;
    return index != -1 ? index + 1 : null;
  }

  int get selectedFoundMessageIndex =>
      foundItems?.indexOf(selectedFoundItem) ?? -1;

  bool get isCanMoveNext {
    var index = selectedFoundMessageIndex;
    return index >= 0 && index < foundItems.length - 1;
  }

  bool get isCanMovePrevious => selectedFoundMessageIndex > 0;

  MessageListSearchState.name(
      {@required this.foundItems,
      @required this.searchTerm,
      @required this.selectedFoundItem});

  static get empty => MessageListSearchState.name(
      foundItems: [], searchTerm: null, selectedFoundItem: null);

  @override
  String toString() {
    return 'MessageListSearchState{foundItems: $foundItems,'
        ' searchTerm: $searchTerm,'
        ' selectedFoundItem: $selectedFoundMessageIndex}';
  }

  bool isMessageInSearchResults(MessageListItem item) =>
      foundItems?.contains(item) ?? false;
}
