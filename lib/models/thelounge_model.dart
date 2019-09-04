import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/socketio_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thelounge_model.g.dart';

const String theLoungeOn = "on";
const String theLoungeOff = "off";

class TheLoungeRequest extends SocketIOCommand {
  String name;
  TheLoungeRequestBody body;

  TheLoungeRequest(this.name, this.body);

  @override
  String getName() => name;

  /// Actually TheLounge body looks like json,
  /// but socket.io require List<dynamic> argument
  /// in this case argument is List<Map<String, dynamic>>
  /// Map<String, dynamic> is json root
  @override
  List<dynamic> getBody() => [body.toJson()];
}

abstract class TheLoungeRequestBody {
  Map<String, dynamic> toJson();
}

abstract class TheLoungeResponseBody extends TheLoungeResponseBodyPart {}

abstract class TheLoungeResponseBodyPart {

}

@JsonSerializable()
class InputTheLoungeRequestBody extends TheLoungeRequestBody {
  final int target;
  final String text;


  @override
  String toString() {
    return 'InputTheLoungeRequestBody{target: $target, text: $text}';
  }

  InputTheLoungeRequestBody({@required this.target, @required this.text});

  @override
  Map<String, dynamic> toJson() => _$InputTheLoungeRequestBodyToJson(this);
}

@JsonSerializable()
class NetworkNewTheLoungeRequestBody extends TheLoungeRequestBody {
  final String host;
  final String join;
  final String name;
  final String nick;
  final String port;
  final String realname;
  final String password;
  final String rejectUnauthorized;
  final String tls;
  final String username;


  @override
  String toString() {
    return 'NetworkNewTheLoungeRequestBody{host: $host, join: $join, name: $name, nick: $nick, port: $port, realname: $realname, password: $password, rejectUnauthorized: $rejectUnauthorized, tls: $tls, username: $username}';
  }

  NetworkNewTheLoungeRequestBody(
      {this.host,
      this.join,
      this.name,
      this.nick,
      this.port,
      this.realname,
      this.rejectUnauthorized,
      this.tls,
      this.username,
      this.password});

  Map<String, dynamic> toJson() => _$NetworkNewTheLoungeRequestBodyToJson(this);
}

@JsonSerializable()
class MessageTheLoungeResponseBody extends TheLoungeResponseBody {
  int chan;
  MsgTheLoungeResponseBody msg;


  @override
  String toString() {
    return 'MessageTheLoungeResponseBody{chan: $chan, msg: $msg}';
  }

  MessageTheLoungeResponseBody(this.chan, this.msg);

  factory MessageTheLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MessageTheLoungeResponseBodyFromJson(json);
}


@JsonSerializable()
class MsgTheLoungeResponseBody extends TheLoungeResponseBodyPart {
  MsgFromTheLoungeResponseBody from;
  String type;
  String time;
  String text;
  bool self;
  bool highlight;
  bool showInActive;
  List<dynamic> users;
  List<dynamic> previews;
  int id;


  MsgTheLoungeResponseBody(this.from, this.type, this.time, this.text,
      this.self, this.highlight, this.showInActive, this.users, this.previews,
      this.id);

  @override
  String toString() {
    return 'MsgTheLoungeResponseBody{from: $from, type: $type, time: $time, text: $text, self: $self, highlight: $highlight, showInActive: $showInActive, users: $users, previews: $previews, id: $id}';
  }

  factory MsgTheLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgTheLoungeResponseBodyFromJson(json);

}

@JsonSerializable()
class MsgFromTheLoungeResponseBody extends TheLoungeResponseBodyPart {
  dynamic mode;
  String nick;


  MsgFromTheLoungeResponseBody(this.mode, this.nick);

  @override
  String toString() {
    return 'MsgFromTheLoungeResponseBody{mode: $mode, nick: $nick}';
  }

  factory MsgFromTheLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgFromTheLoungeResponseBodyFromJson(json);


}

@JsonSerializable()
class NetworksTheLoungeResponseBody extends TheLoungeResponseBody {
  List<NetworkTheLoungeResponseBody> networks;


  @override
  String toString() {
    return 'NetworksTheLoungeResponseBody{networks: $networks}';
  }

  NetworksTheLoungeResponseBody(this.networks);

  factory NetworksTheLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworksTheLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class NetworkTheLoungeResponseBody extends TheLoungeResponseBodyPart {
  String uuid;
  String name;
  String host;
  String port;
  String lts;
  String userDisconnected;
  String rejectUnauthorized;
  String nick;
  String username;
  String realname;
  List<dynamic> commands;
  List<ChannelTheLoungeResponseBody> channels;
  Map<String, dynamic> serverOptions;
  Map<String, dynamic> status;


  @override
  String toString() {
    return 'NetworkTheLoungeResponseBody{uuid: $uuid, name: $name, host: $host, port: $port, lts: $lts, userDisconnected: $userDisconnected, rejectUnauthorized: $rejectUnauthorized, nick: $nick, username: $username, realname: $realname, commands: $commands, channels: $channels, serverOptions: $serverOptions, status: $status}';
  }

  NetworkTheLoungeResponseBody(this.uuid, this.name, this.host, this.port,
      this.lts, this.userDisconnected, this.rejectUnauthorized, this.nick,
      this.username, this.realname, this.commands, this.channels,
      this.serverOptions, this.status);

  factory NetworkTheLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkTheLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class ChannelTheLoungeResponseBody extends TheLoungeResponseBodyPart {
  String name;
  String type;
  int id;
  List<dynamic> messages;
  bool moreHistoryAvailable;
  String key;
  String topic;
  int state;
  int firstUnread;
  int unread;
  int highlight;
  List<dynamic> users;


  @override
  String toString() {
    return 'ChannelTheLoungeResponseBody{name: $name, type: $type, id: $id, messages: $messages, moreHistoryAvailable: $moreHistoryAvailable, key: $key, topic: $topic, state: $state, firstUnread: $firstUnread, unread: $unread, highlight: $highlight, users: $users}';
  }

  ChannelTheLoungeResponseBody(this.name, this.type, this.id,
      this.messages, this.moreHistoryAvailable, this.key, this.topic,
      this.state, this.firstUnread, this.unread, this.highlight, this.users);

  factory ChannelTheLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ChannelTheLoungeResponseBodyFromJson(json);
}
