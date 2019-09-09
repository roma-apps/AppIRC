import 'package:flutter/foundation.dart';

class IRCNetworkChannelMessage {
  String type;
  String author;
  String realName;
  DateTime date;
  String text;

  IRCNetworkChannelMessage(
      {@required this.type,
      @required this.author,
      @required this.realName,
      @required this.date,
      @required this.text});

  @override
  String toString() {
    return 'IRCNetworkChannelMessage{type: $type, author: $author, '
        'realName: $realName, date: $date, text: $text}';
  }
}
