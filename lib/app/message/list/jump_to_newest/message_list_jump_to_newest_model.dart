import 'package:flutter/widgets.dart';

class MessagesListJumpToNewestState {
  bool isLastMessageShown;
  int newMessagesCount;

  MessagesListJumpToNewestState({
    @required this.isLastMessageShown,
    @required this.newMessagesCount,
  });

  @override
  String toString() {
    return 'MessagesListJumpToNewestState{'
        'isLastMessageShown: $isLastMessageShown, '
        'newMessagesCount: $newMessagesCount'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesListJumpToNewestState &&
          runtimeType == other.runtimeType &&
          isLastMessageShown == other.isLastMessageShown &&
          newMessagesCount == other.newMessagesCount;

  @override
  int get hashCode => isLastMessageShown.hashCode ^ newMessagesCount.hashCode;
}
