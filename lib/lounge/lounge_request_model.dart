import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_request_model.g.dart';

class RequestLoungeEventNames {
  static const String networkNew = "network:new";
  static const String networkEdit = "network:edit";
  static const String names = "names";
  static const String input = "input";
  static const String open = "open";
  static const String auth = "auth";
  static const String uploadAuth = "upload:auth";

  static const String more = "more";
  static const String msgPreviewToggle = "msg:preview:toggle";
  static const String signOut = "sign-out";
  static const String networkGet = "network:get";
  static const String pushFCMToken = "push:fcmToken";
  static const String pushRegister = "push:register";
  static const String pushUnregister = "push:unregister";
}

abstract class LoungeRequest {
  String get eventName;

  LoungeRequest();
}

abstract class LoungeEmptyRequest extends LoungeRequest {}

class UploadAuthLoungeEmptyRequest extends LoungeEmptyRequest {
  @override
  String get eventName => RequestLoungeEventNames.uploadAuth;
}

class SignOutLoungeEmptyRequest extends LoungeEmptyRequest {
  @override
  String get eventName => RequestLoungeEventNames.signOut;
}

abstract class LoungeJsonRequest extends LoungeRequest {
  Map<String, dynamic> toJson();
}

abstract class LoungeRawRequest<T> extends LoungeRequest {
  final T body;
  LoungeRawRequest(this.body) : super();

  LoungeRawRequest.name({@required this.body});

  String get bodyAsString => body.toString();
}

class ChannelOpenedLoungeRawRequest extends LoungeRawRequest<int> {
  ChannelOpenedLoungeRawRequest(int body) : super(body);

  ChannelOpenedLoungeRawRequest.name({@required int channelRemoteId})
      : super(channelRemoteId);

  @override
  String get eventName => RequestLoungeEventNames.open;
}

class PushFCMTokenLoungeRawRequest extends LoungeRawRequest<String> {
  PushFCMTokenLoungeRawRequest(String body) : super(body);

  PushFCMTokenLoungeRawRequest.name({@required String deviceFCMToken})
      : super(deviceFCMToken);

  @override
  String get eventName => RequestLoungeEventNames.pushFCMToken;
}

@JsonSerializable()
class InputLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.input;

  final int target;
  final String text;

  InputLoungeJsonRequest(this.target, this.text);

  InputLoungeJsonRequest.name({@required this.target, @required this.text});

  factory InputLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$InputLoungeJsonRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InputLoungeJsonRequestToJson(this);

  @override
  String toString() {
    return 'InputLoungeJsonRequest{target: $target, content: $text}';
  }
}

@JsonSerializable()
class MoreLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.more;

  final int target;
  final int lastId;

  MoreLoungeJsonRequest(this.target, this.lastId);

  MoreLoungeJsonRequest.name({@required this.target, @required this.lastId});

  @override
  Map<String, dynamic> toJson() => _$MoreLoungeJsonRequestToJson(this);

  factory MoreLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$MoreLoungeJsonRequestFromJson(json);

  @override
  String toString() {
    return 'MoreLoungeJsonRequest{target: $target, lastId: $lastId}';
  }
}

@JsonSerializable()
class MsgPreviewToggleLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.msgPreviewToggle;

  final int target;
  final int msgId;
  final String link;
  final bool shown;

  MsgPreviewToggleLoungeJsonRequest(
      this.target, this.msgId, this.link, this.shown);

  MsgPreviewToggleLoungeJsonRequest.name(
      {@required this.target,
      @required this.msgId,
      @required this.link,
      @required this.shown});

  @override
  String toString() {
    return 'MsgPreviewToggleLoungeJsonRequest{target: $target, '
        'msgId: $msgId, link: $link, shown: $shown}';
  }

  @override
  Map<String, dynamic> toJson() =>
      _$MsgPreviewToggleLoungeJsonRequestToJson(this);

  factory MsgPreviewToggleLoungeJsonRequest.fromJson(
          Map<dynamic, dynamic> json) =>
      _$MsgPreviewToggleLoungeJsonRequestFromJson(json);
}

@JsonSerializable()
class PushFCMTokenLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.pushFCMToken;

  final String token;

  PushFCMTokenLoungeJsonRequest(this.token);

  PushFCMTokenLoungeJsonRequest.name({@required this.token});

  @override
  Map<String, dynamic> toJson() => _$PushFCMTokenLoungeJsonRequestToJson(this);

  factory PushFCMTokenLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$PushFCMTokenLoungeJsonRequestFromJson(json);

  @override
  String toString() {
    return 'PushFCMTokenLoungeJsonRequest{token: $token}';
  }
}

@JsonSerializable()
class NamesLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.names;

  final int target;

  @override
  String toString() {
    return 'NamesLoungeJsonRequest{target: $target}';
  }

  NamesLoungeJsonRequest(this.target);

  NamesLoungeJsonRequest.name({@required this.target});

  @override
  Map<String, dynamic> toJson() => _$NamesLoungeJsonRequestToJson(this);

  factory NamesLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$NamesLoungeJsonRequestFromJson(json);
}

@JsonSerializable()
class AuthLoungeJsonRequestBody extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.auth;

  final String user;
  final String password;

  @override
  String toString() {
    return 'AuthLoungeJsonRequestBody{user: $user, password: $password}';
  }

  AuthLoungeJsonRequestBody(this.user, this.password);

  AuthLoungeJsonRequestBody.name(
      {@required this.user, @required this.password});

  @override
  Map<String, dynamic> toJson() => _$AuthLoungeJsonRequestBodyToJson(this);

  factory AuthLoungeJsonRequestBody.fromJson(Map<dynamic, dynamic> json) =>
      _$AuthLoungeJsonRequestBodyFromJson(json);
}

@JsonSerializable()
class NetworkEditLoungeJsonRequest extends NetworkLoungeJsonRequest {
  final String uuid;

  @override
  String get eventName => RequestLoungeEventNames.networkEdit;

  NetworkEditLoungeJsonRequest.name(
      {@required this.uuid,
      @required String host,
      @required String name,
      @required String nick,
      @required String port,
      @required String realname,
      @required String password,
      @required String rejectUnauthorized,
      @required String tls,
      @required String username,
      @required String commands})
      : super.name(
          host: host,
          name: name,
          nick: nick,
          port: port,
          realname: realname,
          password: password,
          rejectUnauthorized: rejectUnauthorized,
          tls: tls,
          username: username,
          commands: commands,
        );

  NetworkEditLoungeJsonRequest(
      this.uuid,
      String host,
      String name,
      String nick,
      String port,
      String realname,
      String password,
      String rejectUnauthorized,
      String tls,
      String username,
      String commands)
      : super(host, name, nick, port, realname, password, rejectUnauthorized,
            tls, username, commands);

  Map<String, dynamic> toJson() => _$NetworkEditLoungeJsonRequestToJson(this);

  factory NetworkEditLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$NetworkEditLoungeJsonRequestFromJson(json);
}

@JsonSerializable()
class NetworkNewLoungeJsonRequest extends NetworkLoungeJsonRequest {
  final String join;

  @override
  String get eventName => RequestLoungeEventNames.networkNew;

  NetworkNewLoungeJsonRequest.name(
      {@required this.join,
      @required String host,
      @required String name,
      @required String nick,
      @required String port,
      @required String realname,
      @required String password,
      @required String rejectUnauthorized,
      @required String tls,
      @required String username,
      @required String commands})
      : super.name(
          host: host,
          name: name,
          nick: nick,
          port: port,
          realname: realname,
          password: password,
          rejectUnauthorized: rejectUnauthorized,
          tls: tls,
          username: username,
          commands: commands,
        );

  NetworkNewLoungeJsonRequest(
      this.join,
      String host,
      String name,
      String nick,
      String port,
      String realname,
      String password,
      String rejectUnauthorized,
      String tls,
      String username,
      String commands)
      : super(host, name, nick, port, realname, password, rejectUnauthorized,
            tls, username, commands);

  Map<String, dynamic> toJson() => _$NetworkNewLoungeJsonRequestToJson(this);

  factory NetworkNewLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$NetworkNewLoungeJsonRequestFromJson(json);
}

abstract class NetworkLoungeJsonRequest extends LoungeJsonRequest {
  final String host;
  final String name;
  final String nick;
  final String port;
  final String realname;
  final String password;
  final String rejectUnauthorized;
  final String tls;
  final String username;
  final String commands;

  bool get isTls => _toBoolean(tls);

  bool get isRejectUnauthorized => _toBoolean(rejectUnauthorized);

  String get uri => "$host:$port";

  NetworkLoungeJsonRequest(
      this.host,
      this.name,
      this.nick,
      this.port,
      this.realname,
      this.password,
      this.rejectUnauthorized,
      this.tls,
      this.username,
      this.commands);

  NetworkLoungeJsonRequest.name(
      {@required this.host,
      @required this.commands,
      @required this.name,
      @required this.nick,
      @required this.port,
      @required this.realname,
      @required this.rejectUnauthorized,
      @required this.tls,
      @required this.username,
      @required this.password});
}

bool _toBoolean(String loungeBoolean) =>
    loungeBoolean == BooleanLoungeConstants.on;
