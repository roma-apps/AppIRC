import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:flutter_appirc/models/socketio_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

const String loungeOn = "on";
const String loungeOff = "off";

@JsonSerializable()
class LoungePreferences extends Preferences {
  final String host;

  LoungePreferences({@required this.host});

  @override
  String toString() {
    return 'LoungeConnectionPreferences{host: $host}';
  }

  @override
  Map<String, dynamic> toJson() => _$LoungePreferencesToJson(this);

  factory LoungePreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungePreferencesFromJson(json);
}

abstract class LoungeRequest extends SocketIOCommand {
  final String name;

  LoungeRequest(this.name);

  @override
  String getName() => name;

  @override
  List<dynamic> getBody();
}

class LoungeJsonRequest extends LoungeRequest {
  final LoungeRequestBody body;

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

  @override
  String toString() {
    return 'LoungeJsonRequest{name: $name, body: $body}';
  }
}

class LoungeRawRequest extends LoungeRequest {
  final List<dynamic> body;

  LoungeRawRequest({@required String name, this.body = const []}) : super(name);

  @override
  List<dynamic> getBody() => body;

  @override
  String toString() {
    return 'LoungeRawRequest{name: $name, body: $body}';
  }
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
class NamesLoungeRequestBody extends LoungeRequestBody {
  final int target;

  @override
  String toString() {
    return 'NamesLoungeRequestBody{target: $target}';
  }

  NamesLoungeRequestBody({@required this.target});

  @override
  Map<String, dynamic> toJson() => _$NamesLoungeRequestBodyToJson(this);
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
    return 'NetworkNewLoungeRequestBody{host: $host, join: $join, name: $name,'
        ' nick: $nick, port: $port, realname: $realname, password: $password,'
        ' rejectUnauthorized: $rejectUnauthorized, tls: $tls,'
        ' username: $username}';
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
  final int chan;
  final MsgLoungeResponseBody msg;

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
  final ChannelLoungeResponseBody chan;
  final int index;
  final String network;

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
  final bool connected;
  final String network;
  final bool secure;

  NetworkStatusLoungeResponseBody(this.connected, this.network, this.secure);

  @override
  String toString() {
    return 'NetworkStatusLoungeResponseBody{connected: $connected,'
        ' network: $network, secure: $secure}';
  }

  factory NetworkStatusLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkStatusLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class NetworkOptionsLoungeResponseBody extends LoungeResponseBody {
  final String network;
  final Map<String, dynamic> serverOptions;

  NetworkOptionsLoungeResponseBody(this.network, this.serverOptions);

  @override
  String toString() {
    return 'NetworkOptionsLoungeResponseBody{network: $network,'
        ' serverOptions: $serverOptions}';
  }

  factory NetworkOptionsLoungeResponseBody.fromJson(
          Map<String, dynamic> json) =>
      _$NetworkOptionsLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class ChannelStateLoungeResponseBody extends LoungeResponseBody {
  final int chan;
  final int state;

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
  final int chan;
  final dynamic msg;

  UsersLoungeResponseBody(this.chan, this.msg);

  factory UsersLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$UsersLoungeResponseBodyFromJson(json);

  @override
  String toString() {
    return 'UsersLoungeResponseBody{chan: $chan, msg: $msg}';
  }
}

@JsonSerializable()
class MsgLoungeResponseBody extends LoungeResponseBodyPart {
  final MsgFromLoungeResponseBody from;
  final String type;
  final String time;
  final String text;
  final bool self;
  final bool highlight;
  final bool showInActive;
  final List<dynamic> users;
  final List<dynamic> previews;
  final int id;

  MsgLoungeResponseBody(this.from, this.type, this.time, this.text, this.self,
      this.highlight, this.showInActive, this.users, this.previews, this.id);

  @override
  String toString() {
    return 'MsgLoungeResponseBody{from: $from, type: $type, time: $time,'
        ' text: $text, self: $self, highlight: $highlight,'
        ' showInActive: $showInActive, users: $users,'
        ' previews: $previews, id: $id}';
  }

  factory MsgLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class MsgFromLoungeResponseBody extends LoungeResponseBodyPart {
  final dynamic mode;
  final String nick;

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
  final String defaultTheme;
  final Map<String, dynamic> defaults;
  final bool displayNetwork;
  final bool fileUpload;
  final bool ldapEnabled;
  final bool lockNetwork;
  final bool prefetch;
  final bool public;
  final bool useHexIp;
  final int fileUploadMaxSize;
  final String gitCommit;
  final String version;
  final List<dynamic> themes;

  ConfigurationLoungeResponseBody(
      this.defaultTheme,
      this.defaults,
      this.displayNetwork,
      this.fileUpload,
      this.ldapEnabled,
      this.lockNetwork,
      this.prefetch,
      this.public,
      this.useHexIp,
      this.fileUploadMaxSize,
      this.gitCommit,
      this.version,
      this.themes);

  factory ConfigurationLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationLoungeResponseBodyFromJson(json);

  @override
  String toString() {
    return 'ConfigurationLoungeResponseBody{defaultTheme: $defaultTheme,'
        ' defaults: $defaults, displayNetwork: $displayNetwork,'
        ' fileUpload: $fileUpload, ldapEnabled: $ldapEnabled,'
        ' lockNetwork: $lockNetwork, prefetch: $prefetch,'
        ' public: $public, useHexIp: $useHexIp,'
        ' fileUploadMaxSize: $fileUploadMaxSize,'
        ' gitCommit: $gitCommit, version: $version, themes: $themes}';
  }
}

@JsonSerializable()
class InitLoungeResponseBody extends LoungeResponseBody {
  final int active;
  final String applicationServerKey;
  final String token;
  final List<NetworkLoungeResponseBody> networks;

  InitLoungeResponseBody(
      this.active, this.applicationServerKey, this.token, this.networks);

  factory InitLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$InitLoungeResponseBodyFromJson(json);

  @override
  String toString() {
    return 'InitLoungeResponseBody{active: $active,'
        ' applicationServerKey: $applicationServerKey,'
        ' token: $token, networks: $networks}';
  }
}

@JsonSerializable()
class NamesLoungeResponseBody extends LoungeResponseBody {
  final int id;
  final List<UserLoungeResponseBodyPart> users;

  NamesLoungeResponseBody(this.id, this.users);

  factory NamesLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NamesLoungeResponseBodyFromJson(json);

  @override
  String toString() {
    return 'NamesLoungeResponseBody{id: $id, users: $users}';
  }
}

@JsonSerializable()
class TopicLoungeResponseBody extends LoungeResponseBody {
  final int chan;
  final String topic;

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
  final int lastMessage;
  final String mode;
  final String nick;

  UserLoungeResponseBodyPart(this.lastMessage, this.mode, this.nick);

  factory UserLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$UserLoungeResponseBodyPartFromJson(json);

  @override
  String toString() {
    return 'UserLoungeResponseBodyPart{lastMessage: $lastMessage,'
        ' mode: $mode, nick: $nick}';
  }
}

@JsonSerializable()
class NetworksLoungeResponseBody extends LoungeResponseBody {
  final List<NetworkLoungeResponseBody> networks;

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
  final String uuid;
  final String name;
  final String host;
  final int port;
  final String lts;
  final bool userDisconnected;
  final bool rejectUnauthorized;
  final String nick;
  final String username;
  final String realname;
  final List<dynamic> commands;
  final List<ChannelLoungeResponseBody> channels;
  final Map<String, dynamic> serverOptions;
  final Map<String, dynamic> status;

  @override
  String toString() {
    return 'NetworkLoungeResponseBody{uuid: $uuid, name: $name, host: $host,'
        ' port: $port, lts: $lts,'
        ' userDisconnected: $userDisconnected,'
        ' rejectUnauthorized: $rejectUnauthorized,'
        ' nick: $nick, username: $username,'
        ' realname: $realname, commands: $commands,'
        ' channels: $channels, serverOptions: $serverOptions, status: $status}';
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
  final String name;
  final String type;
  final int id;
  final List<dynamic> messages;
  final bool moreHistoryAvailable;
  final String key;
  final String topic;
  final int state;
  final int firstUnread;
  final int unread;
  final int highlight;
  final List<dynamic> users;

  @override
  String toString() {
    return 'ChannelLoungeResponseBody{name: $name, type: $type,'
        ' id: $id, messages: $messages,'
        ' moreHistoryAvailable: $moreHistoryAvailable, key: $key,'
        ' topic: $topic, state: $state, firstUnread: $firstUnread,'
        ' unread: $unread, highlight: $highlight, users: $users}';
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

abstract class LoungeException implements Exception {}

abstract class ConnectionLoungeException implements LoungeException {}

class AlreadyConnectedLoungeException implements ConnectionLoungeException {}

class ConnectionTimeoutLoungeException implements ConnectionLoungeException {}

class ConnectionErrorLoungeException implements ConnectionLoungeException {
  final dynamic data;

  ConnectionErrorLoungeException(this.data);
}
