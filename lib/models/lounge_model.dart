import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/socketio_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

const String loungeOn = "on";
const String loungeOff = "off";

abstract class LoungeRequest extends SocketIOCommand {
  String name;

  LoungeRequest(this.name);

  @override
  String getName() => name;

  /// Actually Lounge body looks like json,
  /// but socket.io require List<dynamic> argument
  /// in this case argument is List<Map<String, dynamic>>
  /// Map<String, dynamic> is json root

  @override
  List<dynamic> getBody();
}

class LoungeJsonRequest extends LoungeRequest {
  LoungeRequestBody body;

  LoungeJsonRequest({@required String name, this.body}) : super(name);

  /// Actually Lounge body looks like json,
  /// but socket.io require List<dynamic> argument
  /// in this case argument is List<Map<String, dynamic>>
  /// Map<String, dynamic> is json root
  @override
  List<dynamic> getBody() {
    if (body != null) {
      return [body.toJson()];
    } else {
      return [];
    }
  }
}

class LoungeRawRequest extends LoungeRequest {
  List<dynamic> body;

  LoungeRawRequest({@required String name, this.body = const []})
      : super(name);

  @override
  List<dynamic> getBody() => body;
}

abstract class LoungeRequestBody {
  Map<String, dynamic> toJson();
}

abstract class LoungeResponseBody extends LoungeResponseBodyPart {}

abstract class LoungeResponseBodyPart {}

@JsonSerializable()
class InputLoungeRequestBody extends LoungeRequestBody {
  final int target;
  final String text;

  @override
  String toString() {
    return 'InputLoungeRequestBody{target: $target, text: $text}';
  }

  InputLoungeRequestBody({@required this.target, @required this.text});

  @override
  Map<String, dynamic> toJson() => _$InputLoungeRequestBodyToJson(this);
}

@JsonSerializable()
class NetworkNewLoungeRequestBody extends LoungeRequestBody {
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
    return 'NetworkNewLoungeRequestBody{host: $host, join: $join, name: $name, nick: $nick, port: $port, realname: $realname, password: $password, rejectUnauthorized: $rejectUnauthorized, tls: $tls, username: $username}';
  }

  NetworkNewLoungeRequestBody(
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

  Map<String, dynamic> toJson() => _$NetworkNewLoungeRequestBodyToJson(this);
}

@JsonSerializable()
class MessageLoungeResponseBody extends LoungeResponseBody {
  int chan;
  MsgLoungeResponseBody msg;

  @override
  String toString() {
    return 'MessageLoungeResponseBody{chan: $chan, msg: $msg}';
  }

  MessageLoungeResponseBody(this.chan, this.msg);

  factory MessageLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MessageLoungeResponseBodyFromJson(json);
}


@JsonSerializable()
class JoinLoungeResponseBody extends LoungeResponseBody {
  ChannelLoungeResponseBody chan;
  int index;
  String network;


  JoinLoungeResponseBody(this.chan, this.index, this.network);

  @override
  String toString() {
    return 'JoinLoungeResponseBody{chan: $chan, index: $index, network: $network}';
  }

  factory JoinLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$JoinLoungeResponseBodyFromJson(json);
}


@JsonSerializable()
class NetworkStatusLoungeResponseBody extends LoungeResponseBody {
  bool connected;
  String network;
  bool secure;


  NetworkStatusLoungeResponseBody(this.connected, this.network, this.secure);


  @override
  String toString() {
    return 'NetworkStatusLoungeResponseBody{connected: $connected, network: $network, secure: $secure}';
  }

  factory NetworkStatusLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkStatusLoungeResponseBodyFromJson(json);
}



@JsonSerializable()
class NetworkOptionsLoungeResponseBody extends LoungeResponseBody {

  String network;
  Map<String, dynamic> serverOptions;


  NetworkOptionsLoungeResponseBody(this.network, this.serverOptions);


  @override
  String toString() {
    return 'NetworkOptionsLoungeResponseBody{network: $network, serverOptions: $serverOptions}';
  }

  factory NetworkOptionsLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkOptionsLoungeResponseBodyFromJson(json);
}


@JsonSerializable()
class ChannelStateLoungeResponseBody extends LoungeResponseBody {

  int chan;
  int state;


  ChannelStateLoungeResponseBody(this.chan, this.state);


  @override
  String toString() {
    return 'ChannelStateLoungeResponseBody{chan: $chan, state: $state}';
  }

  factory ChannelStateLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ChannelStateLoungeResponseBodyFromJson(json);
}





@JsonSerializable()
class UsersLoungeResponseBody extends LoungeResponseBody {
  int chan;
  dynamic msg;


  UsersLoungeResponseBody(this.chan, this.msg);

  factory UsersLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$UsersLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class MsgLoungeResponseBody extends LoungeResponseBodyPart {
  MsgFromLoungeResponseBody from;
  String type;
  String time;
  String text;
  bool self;
  bool highlight;
  bool showInActive;
  List<dynamic> users;
  List<dynamic> previews;
  int id;

  MsgLoungeResponseBody(
      this.from,
      this.type,
      this.time,
      this.text,
      this.self,
      this.highlight,
      this.showInActive,
      this.users,
      this.previews,
      this.id);

  @override
  String toString() {
    return 'MsgLoungeResponseBody{from: $from, type: $type, time: $time, text: $text, self: $self, highlight: $highlight, showInActive: $showInActive, users: $users, previews: $previews, id: $id}';
  }

  factory MsgLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class MsgFromLoungeResponseBody extends LoungeResponseBodyPart {
  dynamic mode;
  String nick;

  MsgFromLoungeResponseBody(this.mode, this.nick);

  @override
  String toString() {
    return 'MsgFromLoungeResponseBody{mode: $mode, nick: $nick}';
  }

  factory MsgFromLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgFromLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class ConfigurationLoungeResponseBody extends LoungeResponseBody {
  String defaultTheme;
  Map<String, dynamic> defaults;
  bool displayNetwork;
  bool fileUpload;
  bool ldapEnabled;
  bool lockNetwork;
  bool prefetch;
  bool public;
  bool useHexIp;
  int fileUploadMaxSize;
  String gitCommit;
  String version;
  List<dynamic> themes;


  ConfigurationLoungeResponseBody(this.defaultTheme, this.defaults,
      this.displayNetwork, this.fileUpload, this.ldapEnabled, this.lockNetwork,
      this.prefetch, this.public, this.useHexIp, this.fileUploadMaxSize,
      this.gitCommit, this.version, this.themes);

  factory ConfigurationLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class InitLoungeResponseBody extends LoungeResponseBody {
  int active;
  String applicationServerKey;
  String token;
  List<NetworkLoungeResponseBody> networks;


  InitLoungeResponseBody(this.active, this.applicationServerKey, this.token,
      this.networks);

  factory InitLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$InitLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class NamesLoungeResponseBody extends LoungeResponseBody {
  int id;
  List<UserLoungeResponseBodyPart> users;


  NamesLoungeResponseBody(this.id, this.users);

  factory NamesLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NamesLoungeResponseBodyFromJson(json);
}


@JsonSerializable()
class TopicLoungeResponseBody extends LoungeResponseBody {
  int chan;
  String topic;


  @override
  String toString() {
    return 'TopicLoungeResponseBody{chan: $chan, topic: $topic}';
  }

  TopicLoungeResponseBody(this.chan, this.topic);

  factory TopicLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$TopicLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class UserLoungeResponseBodyPart extends LoungeResponseBodyPart {
  int lastMessage;
  String mode;
  String nick;


  UserLoungeResponseBodyPart(this.lastMessage, this.mode, this.nick);

  factory UserLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$UserLoungeResponseBodyPartFromJson(json);
}

@JsonSerializable()
class NetworksLoungeResponseBody extends LoungeResponseBody {

  List<NetworkLoungeResponseBody> networks;

  @override
  String toString() {
    return 'NetworksLoungeResponseBody{networks: $networks}';
  }

  NetworksLoungeResponseBody(this.networks);

  factory NetworksLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworksLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class NetworkLoungeResponseBody extends LoungeResponseBodyPart {
  String uuid;
  String name;
  String host;
  int port;
  String lts;
  bool userDisconnected;
  bool rejectUnauthorized;
  String nick;
  String username;
  String realname;
  List<dynamic> commands;
  List<ChannelLoungeResponseBody> channels;
  Map<String, dynamic> serverOptions;
  Map<String, dynamic> status;

  @override
  String toString() {
    return 'NetworkLoungeResponseBody{uuid: $uuid, name: $name, host: $host, port: $port, lts: $lts, userDisconnected: $userDisconnected, rejectUnauthorized: $rejectUnauthorized, nick: $nick, username: $username, realname: $realname, commands: $commands, channels: $channels, serverOptions: $serverOptions, status: $status}';
  }

  NetworkLoungeResponseBody(
      this.uuid,
      this.name,
      this.host,
      this.port,
      this.lts,
      this.userDisconnected,
      this.rejectUnauthorized,
      this.nick,
      this.username,
      this.realname,
      this.commands,
      this.channels,
      this.serverOptions,
      this.status);

  factory NetworkLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class ChannelLoungeResponseBody extends LoungeResponseBodyPart {
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
    return 'ChannelLoungeResponseBody{name: $name, type: $type, id: $id, messages: $messages, moreHistoryAvailable: $moreHistoryAvailable, key: $key, topic: $topic, state: $state, firstUnread: $firstUnread, unread: $unread, highlight: $highlight, users: $users}';
  }

  ChannelLoungeResponseBody(
      this.name,
      this.type,
      this.id,
      this.messages,
      this.moreHistoryAvailable,
      this.key,
      this.topic,
      this.state,
      this.firstUnread,
      this.unread,
      this.highlight,
      this.users);

  factory ChannelLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ChannelLoungeResponseBodyFromJson(json);
}
