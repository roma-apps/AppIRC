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
  static const String uploadAuth = "upload:auth";

  static const String more = "more";
  static const String msgPreviewToggle = "msg:preview:toggle";
  static const String signOut = "sign-out";
  static const String networkGet = "network:get";
  static const String pushFCMToken = "push:fcmToken";
  static const String pushRegister = "push:register";
  static const String pushUnregister = "push:unregister";

  static const String authPerform = "auth:perform";

  static const String signUp = "sign-up";
}

abstract class LoungeRequest {
  String get eventName;

  const LoungeRequest();
}

abstract class LoungeEmptyRequest extends LoungeRequest {
  const LoungeEmptyRequest();
}

class UploadAuthLoungeEmptyRequest extends LoungeEmptyRequest {
  @override
  String get eventName => RequestLoungeEventNames.uploadAuth;

  const UploadAuthLoungeEmptyRequest();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadAuthLoungeEmptyRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'UploadAuthLoungeEmptyRequest{}';
  }
}

class SignOutLoungeEmptyRequest extends LoungeEmptyRequest {
  @override
  String get eventName => RequestLoungeEventNames.signOut;

  const SignOutLoungeEmptyRequest();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignOutLoungeEmptyRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'SignOutLoungeEmptyRequest{}';
  }
}

abstract class LoungeJsonRequest extends LoungeRequest {
  Map<String, dynamic> toJson();

  const LoungeJsonRequest();
}

abstract class LoungeRawRequest<T> extends LoungeRequest {
  final T body;

  const LoungeRawRequest({@required this.body});
}

class ChannelOpenedLoungeRawRequest extends LoungeRawRequest<int> {
  const ChannelOpenedLoungeRawRequest({
    @required int channelRemoteId,
  }) : super(
          body: channelRemoteId,
        );

  @override
  String get eventName => RequestLoungeEventNames.open;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelOpenedLoungeRawRequest &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'ChannelOpenedLoungeRawRequest{}';
  }
}

// not available in original lounge code
@JsonSerializable()
class PushFCMTokenLoungeJsonRequest extends LoungeJsonRequest {
  @JsonKey(name: "token")
  final String fcmToken;

  PushFCMTokenLoungeJsonRequest({
    @required this.fcmToken,
  }) : super();

  @override
  String get eventName => RequestLoungeEventNames.pushFCMToken;

  factory PushFCMTokenLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$PushFCMTokenLoungeJsonRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PushFCMTokenLoungeJsonRequestToJson(this);

  @override
  String toString() {
    return 'PushFCMTokenLoungeJsonRequest{'
        'fcmToken: $fcmToken'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushFCMTokenLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          fcmToken == other.fcmToken;

  @override
  int get hashCode => fcmToken.hashCode;
}

@JsonSerializable()
class InputLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.input;

  @JsonKey(name: "target")
  final int targetChannelRemoteId;
  final String text;

  const InputLoungeJsonRequest({
    @required this.targetChannelRemoteId,
    @required this.text,
  });

  factory InputLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$InputLoungeJsonRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InputLoungeJsonRequestToJson(this);

  @override
  String toString() {
    return 'InputLoungeJsonRequest{'
        'target: $targetChannelRemoteId, '
        'content: $text'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          targetChannelRemoteId == other.targetChannelRemoteId &&
          text == other.text;

  @override
  int get hashCode => targetChannelRemoteId.hashCode ^ text.hashCode;
}

@JsonSerializable()
class MoreLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.more;

  @JsonKey(name: "target")
  final int targetChannelRemoteId;
  @JsonKey(name: "lastId")
  final int lastMessageRemoteId;

  const MoreLoungeJsonRequest({
    @required this.targetChannelRemoteId,
    @required this.lastMessageRemoteId,
  });

  @override
  Map<String, dynamic> toJson() => _$MoreLoungeJsonRequestToJson(this);

  factory MoreLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$MoreLoungeJsonRequestFromJson(json);

  @override
  String toString() => 'MoreLoungeJsonRequest{'
      'targetChannelRemoteId: $targetChannelRemoteId, '
      'lastMessageRemoteId: $lastMessageRemoteId'
      '}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoreLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          targetChannelRemoteId == other.targetChannelRemoteId &&
          lastMessageRemoteId == other.lastMessageRemoteId;

  @override
  int get hashCode =>
      targetChannelRemoteId.hashCode ^ lastMessageRemoteId.hashCode;
}

@JsonSerializable(includeIfNull: false)
class MsgPreviewToggleLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.msgPreviewToggle;

  @JsonKey(name: "target")
  final int targetChannelRemoteId;
  @JsonKey(name: "msgId")
  final int messageRemoteId;
  final String link;
  final bool shown;

  const MsgPreviewToggleLoungeJsonRequest({
    @required this.targetChannelRemoteId,
    @required this.messageRemoteId,
    @required this.link,
    @required this.shown,
  });

  @override
  String toString() {
    return 'MsgPreviewToggleLoungeJsonRequest{'
        'targetChannelRemoteId: $targetChannelRemoteId, '
        'messageRemoteId: $messageRemoteId, '
        'link: $link, '
        'shown: $shown'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsgPreviewToggleLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          targetChannelRemoteId == other.targetChannelRemoteId &&
          messageRemoteId == other.messageRemoteId &&
          link == other.link &&
          shown == other.shown;

  @override
  int get hashCode =>
      targetChannelRemoteId.hashCode ^
      messageRemoteId.hashCode ^
      link.hashCode ^
      shown.hashCode;

  @override
  Map<String, dynamic> toJson() =>
      _$MsgPreviewToggleLoungeJsonRequestToJson(this);

  factory MsgPreviewToggleLoungeJsonRequest.fromJson(
          Map<dynamic, dynamic> json) =>
      _$MsgPreviewToggleLoungeJsonRequestFromJson(json);
}

@JsonSerializable()
class NamesLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.names;

  @JsonKey(name: "target")
  final int targetChannelRemoteId;

  const NamesLoungeJsonRequest({
    @required this.targetChannelRemoteId,
  });

  @override
  Map<String, dynamic> toJson() => _$NamesLoungeJsonRequestToJson(this);

  factory NamesLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$NamesLoungeJsonRequestFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamesLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          targetChannelRemoteId == other.targetChannelRemoteId;

  @override
  int get hashCode => targetChannelRemoteId.hashCode;

  @override
  String toString() {
    return 'NamesLoungeJsonRequest{'
        'targetChannelRemoteId: $targetChannelRemoteId'
        '}';
  }
}

// not available in original lounge code
@JsonSerializable()
class SignUpLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.signUp;
  final String user;
  final String password;

  const SignUpLoungeJsonRequest({
    @required this.user,
    @required this.password,
  });

  @override
  Map<String, dynamic> toJson() => _$SignUpLoungeJsonRequestToJson(this);

  factory SignUpLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$SignUpLoungeJsonRequestFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignUpLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          password == other.password;

  @override
  int get hashCode => user.hashCode ^ password.hashCode;

  @override
  String toString() {
    return 'RegistrationLoungeJsonRequest{'
        'user: $user, '
        'password: $password'
        '}';
  }
}

@JsonSerializable(includeIfNull: false)
class AuthPerformLoungeJsonRequest extends LoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.authPerform;

  final String user;
  final String password;
  final String token;
  @JsonKey(name: "lastMessage")
  final int lastMessageRemoteId;
  @JsonKey(name: "openChannel")
  final int openChannelRemoteId;
  final bool hasConfig;

  const AuthPerformLoungeJsonRequest({
    @required this.user,
    @required this.password,
    @required this.token,
    @required this.lastMessageRemoteId,
    @required this.openChannelRemoteId,
    @required this.hasConfig,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthPerformLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          password == other.password &&
          token == other.token &&
          lastMessageRemoteId == other.lastMessageRemoteId &&
          openChannelRemoteId == other.openChannelRemoteId &&
          hasConfig == other.hasConfig;

  @override
  int get hashCode =>
      user.hashCode ^
      password.hashCode ^
      token.hashCode ^
      lastMessageRemoteId.hashCode ^
      openChannelRemoteId.hashCode ^
      hasConfig.hashCode;

  @override
  String toString() {
    return 'AuthPerformLoungeJsonRequestBody{'
        'user: $user, '
        'password: $password, '
        'token: $token, '
        'lastMessageRemoteId: $lastMessageRemoteId, '
        'openChannelRemoteId: $openChannelRemoteId, '
        'hasConfig: $hasConfig'
        '}';
  }

  @override
  Map<String, dynamic> toJson() =>
      _$AuthPerformLoungeJsonRequestToJson(this);

  factory AuthPerformLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$AuthPerformLoungeJsonRequestFromJson(json);
}

@JsonSerializable(includeIfNull: false)
class NetworkEditLoungeJsonRequest extends NetworkLoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.networkEdit;

  final String uuid;

  const NetworkEditLoungeJsonRequest({
    @required this.uuid,
    @required String host,
    @required String name,
    @required String nick,
    @required String port,
    @required String realname,
    @required String password,
    @required String rejectUnauthorized,
    @required String tls,
    @required String username,
    @required String commands,
  }) : super(
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

  @override
  String toString() {
    return 'NetworkEditLoungeJsonRequest{'
        'uuid: $uuid, '
        'host: $host, '
        'name: $name, '
        'nick: $nick, '
        'port: $port, '
        'realname: $realname, '
        'password: $password, '
        'rejectUnauthorized: $rejectUnauthorized, '
        'tls: $tls, '
        'username: $username, '
        'commands: $commands'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkEditLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          host == other.host &&
          name == other.name &&
          nick == other.nick &&
          port == other.port &&
          realname == other.realname &&
          password == other.password &&
          rejectUnauthorized == other.rejectUnauthorized &&
          tls == other.tls &&
          username == other.username &&
          commands == other.commands;

  @override
  int get hashCode =>
      uuid.hashCode ^
      host.hashCode ^
      name.hashCode ^
      nick.hashCode ^
      port.hashCode ^
      realname.hashCode ^
      password.hashCode ^
      rejectUnauthorized.hashCode ^
      tls.hashCode ^
      username.hashCode ^
      commands.hashCode;

  @override
  Map<String, dynamic> toJson() => _$NetworkEditLoungeJsonRequestToJson(this);

  factory NetworkEditLoungeJsonRequest.fromJson(Map<dynamic, dynamic> json) =>
      _$NetworkEditLoungeJsonRequestFromJson(json);
}

@JsonSerializable()
class NetworkNewLoungeJsonRequest extends NetworkLoungeJsonRequest {
  @override
  String get eventName => RequestLoungeEventNames.networkNew;

  final String join;

  const NetworkNewLoungeJsonRequest({
    @required this.join,
    @required String host,
    @required String name,
    @required String nick,
    @required String port,
    @required String realname,
    @required String password,
    @required String rejectUnauthorized,
    @required String tls,
    @required String username,
    @required String commands,
  }) : super(
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

  @override
  String toString() {
    return 'NetworkNewLoungeJsonRequest{'
        'join: $join, '
        'host: $host, '
        'name: $name, '
        'nick: $nick, '
        'port: $port, '
        'realname: $realname, '
        'password: $password, '
        'rejectUnauthorized: $rejectUnauthorized, '
        'tls: $tls, '
        'username: $username, '
        'commands: $commands'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkNewLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          join == other.join &&
          host == other.host &&
          name == other.name &&
          nick == other.nick &&
          port == other.port &&
          realname == other.realname &&
          password == other.password &&
          rejectUnauthorized == other.rejectUnauthorized &&
          tls == other.tls &&
          username == other.username &&
          commands == other.commands;

  @override
  int get hashCode =>
      join.hashCode ^
      host.hashCode ^
      name.hashCode ^
      nick.hashCode ^
      port.hashCode ^
      realname.hashCode ^
      password.hashCode ^
      rejectUnauthorized.hashCode ^
      tls.hashCode ^
      username.hashCode ^
      commands.hashCode;

  @override
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

  const NetworkLoungeJsonRequest({
    @required this.host,
    @required this.commands,
    @required this.name,
    @required this.nick,
    @required this.port,
    @required this.realname,
    @required this.rejectUnauthorized,
    @required this.tls,
    @required this.username,
    @required this.password,
  });
}

bool _toBoolean(String loungeBoolean) =>
    loungeBoolean == BooleanLoungeConstants.on;
