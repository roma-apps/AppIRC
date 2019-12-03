import 'package:flutter/widgets.dart';

class MessagesListJumpToNewestState {
  bool isLastMessageShown;
  int newMessagesCount;

  MessagesListJumpToNewestState.name(
      {@required this.isLastMessageShown, @required this.newMessagesCount});

  @override
  String toString() {
    return 'MessagesListJumpToNewestState{isLastMessageShown: $isLastMessageShown,'
        ' newMessagesCount: $newMessagesCount}';
  }
}
