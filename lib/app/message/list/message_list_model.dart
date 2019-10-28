import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';

class MessageListVisibleBounds {
  ChatMessage min;
  ChatMessage max;

  MessageListVisibleBounds({@required this.min, @required this.max});

  @override
  String toString() {
    return 'VisibleMessagesBounds{min: $min, max: $max}';
  }
}

abstract class MoreHistoryOwner {
  bool get moreHistoryAvailable;

  Stream<bool> get moreHistoryAvailableStream;
}
