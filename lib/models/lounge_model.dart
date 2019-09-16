import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:flutter_appirc/models/socketio_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

const String loungeOn = "on";
const String loungeOff = "off";

abstract class IRCCommand {
  final String commandName;

  IRCCommand(this.commandName);

  String toTextCommand();
}

class JoinIRCCommand extends IRCCommand {
  final String channelName;
  final String channelPassword;

  JoinIRCCommand({@required this.channelName, this.channelPassword = ""})
      : super("/join");

  @override
  String toTextCommand() => "$commandName $channelName $channelPassword";
}

class CloseIRCCommand extends IRCCommand {
  final String channelName;

  CloseIRCCommand({@required this.channelName})
      : super("/close");

  @override
  String toTextCommand() => "$commandName $channelName";
}

class LoungeResultForRequest<T extends LoungeRequest,
    K extends LoungeResponseBody> {
  final T request;
  final K result;

  LoungeResultForRequest(this.request, this.result);
}

@JsonSerializable()
class LoungePreferences extends JsonPreferences {
  String host;

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

class LoungeJsonRequest<T extends LoungeRequestBody> extends LoungeRequest {
  final T body;

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
class ChanLoungeResponseBody extends LoungeResponseBody {
  int chan;


  ChanLoungeResponseBody(this.chan);


  @override
  String toString() {
    return 'ChanLoungeResponseBody{chan: $chan}';
  }

  factory ChanLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ChanLoungeResponseBodyFromJson(json);
}

abstract class InputLoungeRequestBody<T> extends LoungeRequestBody {
  final int target;
  final T content;

  InputLoungeRequestBody({@required this.target, @required this.content});

  String contentAsTextCommand();

  @override
  Map<String, dynamic> toJson() =>
      {"target": target, "text": contentAsTextCommand()};
}

class MessageInputLoungeRequestBody extends InputLoungeRequestBody<String> {
  MessageInputLoungeRequestBody({@required int target, @required String body})
      : super(target: target, content: body);

  @override
  String contentAsTextCommand() => content;
}

class CommandInputLoungeRequestBody<T extends IRCCommand>
    extends InputLoungeRequestBody<T> {
  CommandInputLoungeRequestBody({@required int target, @required T body})
      : super(target: target, content: body);

  @override
  String contentAsTextCommand() => content.toTextCommand();
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

  bool get isTls => tls == loungeOn;

  bool get isRejectUnauthorized => rejectUnauthorized == loungeOn;

  String get uri => "$host:$port";

  @override
  String toString() {
    return 'NetworkNewLoungeRequestBody{host: $host, join: $join, name: $name,'
        ' nick: $nick, port: $port, realname: $realname, password: $password,'
        ' rejectUnauthorized: $rejectUnauthorized, tls: $tls,'
        ' username: $username}';
  }

  NetworkNewLoungeRequestBody(
      {@required this.host,
      @required this.join,
      @required this.name,
      @required this.nick,
      @required this.port,
      @required this.realname,
      @required this.rejectUnauthorized,
      @required this.tls,
      @required this.username,
      @required this.password});

  Map<String, dynamic> toJson() => _$NetworkNewLoungeRequestBodyToJson(this);
}

@JsonSerializable()
class MessageLoungeResponseBody extends LoungeResponseBody {
  final int chan;
  final int highlight;
  final int unread;
  final MsgLoungeResponseBody msg;

  MessageLoungeResponseBody(this.chan, this.highlight, this.unread, this.msg);

  @override
  String toString() {
    return 'MessageLoungeResponseBody{chan: $chan, '
        'highlight: $highlight, unread: $unread, msg: $msg}';
  }

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
  final ServerOptionsLoungeResponseBodyPart serverOptions;

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
class ServerOptionsLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final List<String> CHANTYPES;
  final String NETWORK;
  final List<String> PREFIX;

  @override
  String toString() {
    return 'ServerOptionsLoungeResponseBodyPart{CHANTYPES: $CHANTYPES,'
        ' NETWORK: $NETWORK, PREFIX: $PREFIX}';
  }

  ServerOptionsLoungeResponseBodyPart(
      this.CHANTYPES, this.NETWORK, this.PREFIX);

  factory ServerOptionsLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$ServerOptionsLoungeResponseBodyPartFromJson(json);
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
  final int unread;
  final int highlight;
  final dynamic msg;

  UsersLoungeResponseBody(this.chan, this.unread, this.msg, this.highlight);

  factory UsersLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$UsersLoungeResponseBodyFromJson(json);

  @override
  String toString() {
    return 'UsersLoungeResponseBody{chan: $chan, unread: $unread, highlight: $highlight, msg: $msg}';
  }
}

@JsonSerializable()
class NickLoungeResponseBody extends LoungeResponseBody {
  final String network;
  final String nick;

  NickLoungeResponseBody(this.network, this.nick);

  factory NickLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NickLoungeResponseBodyFromJson(json);

  @override
  String toString() {
    return 'NickLoungeResponseBody{network: $network, nick: $nick}';
  }
}

@JsonSerializable()
class MsgLoungeResponseBody extends LoungeResponseBodyPart {
  final MsgFromLoungeResponseBodyPart from;
  final String command;
  final String type;
  final String time;
  final String text;
  final String hostmask;
  final bool self;
  final bool highlight;
  final bool showInActive;
  final List<dynamic> users;
  final List<dynamic> previews;
  final List<String> params;
  final int id;
  final WhoIsLoungeResponseBodyPart whois;

  MsgLoungeResponseBody(
      this.from,
      this.command,
      this.type,
      this.time,
      this.text,
      this.hostmask,
      this.self,
      this.highlight,
      this.showInActive,
      this.users,
      this.previews,
      this.params,
      this.id,
      this.whois);

  @override
  String toString() {
    return 'MsgLoungeResponseBody{from: $from, command: $command,'
        ' type: $type, time: $time, text: $text,'
        ' hostmask: $hostmask, self: $self,'
        ' highlight: $highlight, showInActive: $showInActive,'
        ' users: $users, previews: $previews, '
        'params: $params, id: $id, whois: $whois}';
  }

  factory MsgLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class WhoIsLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final String account;
  final String channels;
  final String hostname;
  final String ident;
  final String idle;
  final int idleTime;
  final int logonTime;
  final String logon;
  final String nick;
  final String real_name;
  final bool secure;
  final String server;
  final String serverInfo;

  @override
  String toString() {
    return 'WhoIsLoungeResponseBodyPart{account: $account, '
        'channels: $channels, hostname: $hostname, '
        'ident: $ident, idle: $idle, idleTime: $idleTime, '
        'logonTime: $logonTime, logon: $logon, nick: $nick, '
        'realName: $real_name, secure: $secure, '
        'server: $server, serverInfo: $serverInfo}';
  }

  WhoIsLoungeResponseBodyPart(
      {@required this.account,
      @required this.channels,
      @required this.hostname,
      @required this.ident,
      @required this.idle,
      @required this.idleTime,
      @required this.logonTime,
      @required this.logon,
      @required this.nick,
      @required this.real_name,
      @required this.secure,
      @required this.server,
      @required this.serverInfo});

  factory WhoIsLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$WhoIsLoungeResponseBodyPartFromJson(json);
}

@JsonSerializable()
class MsgFromLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final int id;
  final String mode;
  final String nick;

  MsgFromLoungeResponseBodyPart(this.id, this.mode, this.nick);

  @override
  String toString() {
    return 'MsgFromLoungeResponseBodyPart{id: $id, mode: $mode, nick: $nick}';
  }

  factory MsgFromLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$MsgFromLoungeResponseBodyPartFromJson(json);
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
  final bool isCollapsed;
  final bool isJoinChannelShown;
  final String nick;
  final String username;
  final String realname;
  final List<dynamic> commands;
  final List<ChannelLoungeResponseBody> channels;
  final ServerOptionsLoungeResponseBodyPart serverOptions;
  final NetworkStatusLoungeResponseBody status;

  NetworkLoungeResponseBody(
      this.uuid,
      this.name,
      this.host,
      this.port,
      this.lts,
      this.userDisconnected,
      this.rejectUnauthorized,
      this.isCollapsed,
      this.isJoinChannelShown,
      this.nick,
      this.username,
      this.realname,
      this.commands,
      this.channels,
      this.serverOptions,
      this.status);

  @override
  String toString() {
    return 'NetworkLoungeResponseBody{uuid: $uuid, name: $name,'
        ' host: $host, port: $port, lts: $lts,'
        ' userDisconnected: $userDisconnected,'
        ' rejectUnauthorized: $rejectUnauthorized,'
        ' isCollapsed: $isCollapsed, '
        'isJoinChannelShown: $isJoinChannelShown,'
        ' nick: $nick, username: $username, realname: $realname, '
        'commands: $commands, channels: $channels,'
        ' serverOptions: $serverOptions, status: $status}';
  }

  factory NetworkLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkLoungeResponseBodyFromJson(json);
}

@JsonSerializable()
class ChannelLoungeResponseBody extends LoungeResponseBodyPart {
  final String name;
  final String type;
  final String key;
  final String pendingMessage;
  final List<MsgLoungeResponseBody> messages;
  final String inputHistory;
  final int inputHistoryPosition;
  final int id;
  final bool moreHistoryAvailable;
  final bool historyLoading;
  final bool editTopic;
  final bool scrolledToBottom;
  final String topic;
  final int state;
  final int firstUnread;
  final int unread;
  final int highlight;
  final List<dynamic> users;

  @override
  String toString() {
    return 'ChannelLoungeResponseBody{name: $name, type: $type, key: $key,'
        ' pendingMessage: $pendingMessage, messages: $messages, '
        'inputHistory: $inputHistory, inputHistoryPosition: $inputHistoryPosition, '
        'id: $id, moreHistoryAvailable: $moreHistoryAvailable, '
        'historyLoading: $historyLoading, editTopic: $editTopic, '
        'scrolledToBottom: $scrolledToBottom, topic: $topic, '
        'state: $state, firstUnread: $firstUnread, '
        'unread: $unread, highlight: $highlight, users: $users}';
  }

  ChannelLoungeResponseBody(
      this.name,
      this.type,
      this.key,
      this.pendingMessage,
      this.messages,
      this.inputHistory,
      this.inputHistoryPosition,
      this.id,
      this.moreHistoryAvailable,
      this.historyLoading,
      this.editTopic,
      this.scrolledToBottom,
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

class RequestWithResultTimeoutLoungeException implements LoungeException {
  LoungeRequest request;

  RequestWithResultTimeoutLoungeException(this.request);
}

abstract class ConnectionLoungeException implements LoungeException {}

class AlreadyConnectedLoungeException implements ConnectionLoungeException {}

class ConnectionTimeoutLoungeException implements ConnectionLoungeException {}

class ConnectionErrorLoungeException implements ConnectionLoungeException {
  final dynamic data;

  ConnectionErrorLoungeException(this.data);
}
