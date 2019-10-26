import 'package:flutter/widgets.dart';

abstract class IRCCommand {
  String get asRawString;
}

class JoinIRCCommand extends IRCCommand {
  final String channelName;
  final String password;
  JoinIRCCommand(this.channelName, this.password);

  JoinIRCCommand.name({@required this.channelName, this.password});

  @override
  String get asRawString => "/join $channelName $password";
}

class TopicIRCCommand extends IRCCommand {
  final String newTopic;
  TopicIRCCommand(this.newTopic);

  TopicIRCCommand.name({@required this.newTopic});

  @override
  String get asRawString => "/topic $newTopic";
}

class WhoIsIRCCommand extends IRCCommand {
  final String userNick;
  WhoIsIRCCommand(this.userNick);

  WhoIsIRCCommand.name({@required this.userNick});

  @override
  String get asRawString => "/whois $userNick";
}

class ChannelsListIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/list";
}

class QuitIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/quit";
}

class CloseIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/list";
}

class BanListIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/banlist";
}

class IgnoreListIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/ignorelist";
}

class DisconnectIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/disconnect";
}

class ConnectIRCCommand extends IRCCommand {
  @override
  String get asRawString => "/connect";
}
