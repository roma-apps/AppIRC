import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_response_model.g.dart';

class LoungeResponseEventNames {
  static const String network = "network";
  static const String nick = "nick";
  static const String msg = "msg";
  static const String msgSpecial = "msg:special";
  static const String msgPreview = "msg:preview";
  static const String configuration = "configuration";

  static const String commands = "commands";
  static const String topic = "topic";
  static const String names = "names";
  static const String users = "users";
  static const String join = "join";
  static const String part = "part";
  static const String quit = "quit";
  static const String networkStatus = "network:status";
  static const String networkOptions = "network:options";
  static const String channelState = "channel:state";
  static const String init = "init";
  static const String uploadAuth = "upload:auth";

  static const String settingNew = "setting:new";
  static const String settingAll = "setting:all";
  static const String sessionsList = "sessions:list";
  static const String open = "open";
  static const String networkInfo = "network:info";
  static const String changelog = "changelog";
  static const String signOut = "sign-out";
  static const String changePassword = "change-password";
  static const String syncSort = "sync_sort";
  static const String more = "more";
  static const String msgPreviewToggle = "msg:preview:toggle";

  static const String signedUp = "signed-up";

  static const String authSuccess = "auth:success";
  static const String authFailed = "auth:failed";
  static const String authStart = "auth:start";

  static const String pushIsSubscribed = "push:issubscribed";

  static const String signUpAvailable = "sign-up:available";
}

class MessagePreviewTypeLoungeResponse {
  static const String link = "link";
  static const String loading = "loading";
  static const String image = "image";
  static const String audio = "audio";
  static const String video = "video";
  static const String error = "error";
}

abstract class LoungeResponseBody extends LoungeResponseBodyPart {
  const LoungeResponseBody();
}

abstract class LoungeResponseBodyPart {
  const LoungeResponseBodyPart();
}

class SignUpAvailableLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.signUpAvailable;

  final bool signUpAvailable;

  SignUpAvailableLoungeResponseBody.fromRaw(dynamic raw)
      : signUpAvailable = raw?.toString()?.toLowerCase() == 'true';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignUpAvailableLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          signUpAvailable == other.signUpAvailable;

  @override
  int get hashCode => signUpAvailable.hashCode;

  @override
  String toString() {
    return 'PushIsSubscribedResponseBody{'
        'signUpAvailable: $signUpAvailable'
        '}';
  }
}

class AuthStartLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.authStart;

  final String serverHash;

  AuthStartLoungeResponseBody.fromRaw(dynamic raw)
      : serverHash = raw?.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStartLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          serverHash == other.serverHash;

  @override
  int get hashCode => serverHash.hashCode;

  @override
  String toString() {
    return 'AuthStartLoungeResponseBody{'
        'serverHash: $serverHash'
        '}';
  }
}

class PushIsSubscribedLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.pushIsSubscribed;

  final bool isSubscribed;

  PushIsSubscribedLoungeResponseBody.fromRaw(dynamic raw)
      : isSubscribed = raw?.toString()?.toLowerCase() == 'true';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushIsSubscribedLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          isSubscribed == other.isSubscribed;

  @override
  int get hashCode => isSubscribed.hashCode;

  @override
  String toString() {
    return 'PushIsSubscribedResponseBody{'
        'isSubscribed: $isSubscribed'
        '}';
  }
}

class SignOutLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.signOut;

  final String sessionToken;

  SignOutLoungeResponseBody.fromRaw(dynamic raw)
      : sessionToken = raw?.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignOutLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          sessionToken == other.sessionToken;

  @override
  int get hashCode => sessionToken.hashCode;

  @override
  String toString() {
    return 'SignOutLoungeResponseBody{sessionToken: $sessionToken}';
  }
}

class UploadAuthLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.uploadAuth;

  final String uploadAuthToken;

  UploadAuthLoungeResponseBody.fromRaw(dynamic raw)
      : uploadAuthToken = raw?.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadAuthLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          uploadAuthToken == other.uploadAuthToken;

  @override
  int get hashCode => uploadAuthToken.hashCode;

  @override
  String toString() {
    return 'UploadAuthLoungeResponseBody{uploadAuthToken: $uploadAuthToken}';
  }
}

class CommandsLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.commands;

  final List<String> commands;

  CommandsLoungeResponseBody.fromRaw(dynamic raw) : commands = parse(raw);

  static List<String> parse(dynamic raw) {
    var iterable = (raw as Iterable);

    var commands = <String>[];

    iterable.forEach((obj) {
      commands.add(obj.toString());
    });

    return commands;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandsLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          commands == other.commands;

  @override
  int get hashCode => commands.hashCode;

  @override
  String toString() {
    return 'CommandsLoungeResponseBody{commands: $commands}';
  }
}

@JsonSerializable()
class MessagePreviewToggleLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.msgPreview;

  final int target;
  final int msgId;
  final String link;
  final bool shown;

  const MessagePreviewToggleLoungeResponseBody({
    @required this.target,
    @required this.msgId,
    @required this.link,
    @required this.shown,
  });

  @override
  String toString() {
    return 'MessagePreviewToggleLoungeResponseBody{'
        'target: $target, '
        'msgId: $msgId, '
        'link: $link, '
        'shown: $shown'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagePreviewToggleLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          target == other.target &&
          msgId == other.msgId &&
          link == other.link &&
          shown == other.shown;

  @override
  int get hashCode =>
      target.hashCode ^ msgId.hashCode ^ link.hashCode ^ shown.hashCode;

  factory MessagePreviewToggleLoungeResponseBody.fromJson(
          Map<String, dynamic> json) =>
      _$MessagePreviewToggleLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MessagePreviewToggleLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class MoreLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.more;

  final int chan;
  final List<MsgLoungeResponseBodyPart> messages;
  final int totalMessages;

  const MoreLoungeResponseBody({
    @required this.chan,
    @required this.messages,
    @required this.totalMessages,
  });

  @override
  String toString() {
    return 'MoreLoungeResponseBody{'
        'chan: $chan,'
        'totalMessages: $totalMessages '
        'messages: $messages, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoreLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          messages == other.messages &&
          totalMessages == other.totalMessages;

  @override
  int get hashCode =>
      chan.hashCode ^ messages.hashCode ^ totalMessages.hashCode;

  factory MoreLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MoreLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$MoreLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class ChangelogLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.changelog;

  final dynamic current;
  final dynamic latest;
  final dynamic packages;

  const ChangelogLoungeResponseBody({
    @required this.current,
    @required this.latest,
    @required this.packages,
  });

  @override
  String toString() {
    return 'ChangelogLoungeResponseBody{'
        'current: $current, '
        'latest: $latest, '
        'packages: $packages'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangelogLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          latest == other.latest &&
          packages == other.packages;

  @override
  int get hashCode => current.hashCode ^ latest.hashCode ^ packages.hashCode;

  factory ChangelogLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ChangelogLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ChangelogLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class SyncSortLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.syncSort;
  final List<int> order;
  final String type;
  final String target;

  const SyncSortLoungeResponseBody({
    @required this.order,
    @required this.type,
    @required this.target,
  });

  @override
  String toString() {
    return 'SyncSortLoungeResponseBody{'
        'order: $order, '
        'type: $type, '
        'target: $target'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncSortLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          type == other.type &&
          target == other.target;

  @override
  int get hashCode => order.hashCode ^ type.hashCode ^ target.hashCode;

  factory SyncSortLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$SyncSortLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$SyncSortLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class SettingsNewLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.settingNew;
  final String name;
  final dynamic value;

  const SettingsNewLoungeResponseBody({
    @required this.name,
    @required this.value,
  });

  @override
  String toString() {
    return 'SettingsNewLoungeResponseBody{'
        'name: $name, '
        'value: $value'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsNewLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  factory SettingsNewLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$SettingsNewLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsNewLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class SettingsAllLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.settingAll;
  final bool advanced;
  final bool autocomplete;
  final String awayMessage;
  final bool coloredNicks;
  final String highlightExceptions;
  final String highlights;
  final bool links;
  final bool media;
  final bool motd;
  final String nickPostfix;
  final bool notifyAllMessages;
  final bool showSeconds;
  final String statusMessages;
  final String theme;
  final bool uploadCanvas;
  final bool use12hClock;
  final String userStyles;

  const SettingsAllLoungeResponseBody({
    @required this.advanced,
    @required this.autocomplete,
    @required this.awayMessage,
    @required this.coloredNicks,
    @required this.highlightExceptions,
    @required this.highlights,
    @required this.links,
    @required this.media,
    @required this.motd,
    @required this.nickPostfix,
    @required this.notifyAllMessages,
    @required this.showSeconds,
    @required this.statusMessages,
    @required this.theme,
    @required this.uploadCanvas,
    @required this.use12hClock,
    @required this.userStyles,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAllLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          advanced == other.advanced &&
          autocomplete == other.autocomplete &&
          awayMessage == other.awayMessage &&
          coloredNicks == other.coloredNicks &&
          highlightExceptions == other.highlightExceptions &&
          highlights == other.highlights &&
          links == other.links &&
          media == other.media &&
          motd == other.motd &&
          nickPostfix == other.nickPostfix &&
          notifyAllMessages == other.notifyAllMessages &&
          showSeconds == other.showSeconds &&
          statusMessages == other.statusMessages &&
          theme == other.theme &&
          uploadCanvas == other.uploadCanvas &&
          use12hClock == other.use12hClock &&
          userStyles == other.userStyles;

  @override
  int get hashCode =>
      advanced.hashCode ^
      autocomplete.hashCode ^
      awayMessage.hashCode ^
      coloredNicks.hashCode ^
      highlightExceptions.hashCode ^
      highlights.hashCode ^
      links.hashCode ^
      media.hashCode ^
      motd.hashCode ^
      nickPostfix.hashCode ^
      notifyAllMessages.hashCode ^
      showSeconds.hashCode ^
      statusMessages.hashCode ^
      theme.hashCode ^
      uploadCanvas.hashCode ^
      use12hClock.hashCode ^
      userStyles.hashCode;

  @override
  String toString() {
    return 'SettingsAllLoungeResponseBody{'
        'advanced: $advanced, '
        'autocomplete: $autocomplete, '
        'awayMessage: $awayMessage, '
        'coloredNicks: $coloredNicks, '
        'highlightExceptions: $highlightExceptions, '
        'highlights: $highlights, '
        'links: $links, '
        'media: $media, '
        'motd: $motd, '
        'nickPostfix: $nickPostfix, '
        'notifyAllMessages: $notifyAllMessages, '
        'showSeconds: $showSeconds, '
        'statusMessages: $statusMessages, '
        'theme: $theme, '
        'uploadCanvas: $uploadCanvas, '
        'use12hClock: $use12hClock, '
        'userStyles: $userStyles'
        '}';
  }

  factory SettingsAllLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$SettingsAllLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsAllLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class SessionsListLoungeResponseBodyPart extends LoungeResponseBodyPart {
  static String get eventName => LoungeResponseEventNames.sessionsList;

  final bool current;
  final int active;
  final int lastUse;
  final String ip;
  final String agent;
  final String token;

  const SessionsListLoungeResponseBodyPart({
    @required this.current,
    @required this.active,
    @required this.lastUse,
    @required this.ip,
    @required this.agent,
    @required this.token,
  });

  factory SessionsListLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$SessionsListLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SessionsListLoungeResponseBodyPartToJson(this);

  @override
  String toString() => 'SessionsListLoungeResponseBodyPart{'
      'current: $current, '
      'active: $active, '
      'lastUse: $lastUse, '
      'ip: $ip, '
      'agent: $agent, '
      'token: $token'
      '}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionsListLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          active == other.active &&
          lastUse == other.lastUse &&
          ip == other.ip &&
          agent == other.agent &&
          token == other.token;

  @override
  int get hashCode =>
      current.hashCode ^
      active.hashCode ^
      lastUse.hashCode ^
      ip.hashCode ^
      agent.hashCode ^
      token.hashCode;
}

@JsonSerializable()
class MsgLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.msg;

  final int chan;
  final int highlight;
  final int unread;
  final MsgLoungeResponseBodyPart msg;

  const MsgLoungeResponseBody({
    @required this.chan,
    @required this.highlight,
    @required this.unread,
    @required this.msg,
  });

  @override
  String toString() {
    return 'MessageLoungeResponseBody{'
        'chan: $chan, '
        'highlight: $highlight, '
        'unread: $unread, '
        'msg: $msg'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsgLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          highlight == other.highlight &&
          unread == other.unread &&
          msg == other.msg;

  @override
  int get hashCode =>
      chan.hashCode ^ highlight.hashCode ^ unread.hashCode ^ msg.hashCode;

  factory MsgLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$MsgLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class MsgSpecialLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.msgSpecial;

  final int chan;
  final dynamic data;

  const MsgSpecialLoungeResponseBody({
    @required this.chan,
    @required this.data,
  });

  @override
  String toString() {
    return 'MessageSpecialLoungeResponseBody{'
        'chan: $chan, '
        'data: $data'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsgSpecialLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          data == other.data;

  @override
  int get hashCode => chan.hashCode ^ data.hashCode;

  factory MsgSpecialLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgSpecialLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$MsgSpecialLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class ConfigurationDefaultsLoungeResponseBodyPart
    extends LoungeResponseBodyPart {
  final String name;
  final String host;
  final int port;
  final String password;
  final bool tls;
  final bool rejectUnauthorized;
  final String nick;
  final String username;
  final String realname;
  final String join;
  final String leaveMessage;
  final String sasl;
  final String saslAccount;
  final String saslPassword;

  const ConfigurationDefaultsLoungeResponseBodyPart({
    @required this.name,
    @required this.host,
    @required this.port,
    @required this.password,
    @required this.tls,
    @required this.rejectUnauthorized,
    @required this.nick,
    @required this.username,
    @required this.realname,
    @required this.join,
    @required this.leaveMessage,
    @required this.sasl,
    @required this.saslAccount,
    @required this.saslPassword,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationDefaultsLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          host == other.host &&
          port == other.port &&
          password == other.password &&
          tls == other.tls &&
          rejectUnauthorized == other.rejectUnauthorized &&
          nick == other.nick &&
          username == other.username &&
          realname == other.realname &&
          join == other.join &&
          leaveMessage == other.leaveMessage &&
          sasl == other.sasl &&
          saslAccount == other.saslAccount &&
          saslPassword == other.saslPassword;

  @override
  int get hashCode =>
      name.hashCode ^
      host.hashCode ^
      port.hashCode ^
      password.hashCode ^
      tls.hashCode ^
      rejectUnauthorized.hashCode ^
      nick.hashCode ^
      username.hashCode ^
      realname.hashCode ^
      join.hashCode ^
      leaveMessage.hashCode ^
      sasl.hashCode ^
      saslAccount.hashCode ^
      saslPassword.hashCode;

  @override
  String toString() {
    return 'DefaultsLoungeResponseBodyPart{'
        'host: $host, '
        'port: $port, '
        'join: $join, '
        'name: $name, '
        'nick: $nick, '
        'password: $password, '
        'realname: $realname, '
        'rejectUnathorized: $rejectUnauthorized, '
        'tls: $tls, '
        'username: $username'
        'leaveMessage: $leaveMessage'
        'sasl: $sasl'
        'saslAccount: $saslAccount'
        'saslPassword: $saslPassword'
        '}';
  }

  factory ConfigurationDefaultsLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$ConfigurationDefaultsLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ConfigurationDefaultsLoungeResponseBodyPartToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConfigurationLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.configuration;
  final bool public;
  final bool lockNetwork;
  final bool useHexIp;
  final bool prefetch;
  final bool fileUpload;
  final bool ldapEnabled;
  final ConfigurationDefaultsLoungeResponseBodyPart defaults;
  final bool isUpdateAvailable;
  final String applicationServerKey;
  final String version;
  final String gitCommit;

  bool get displayNetwork => !lockNetwork;

  final List<dynamic> themes;
  final String defaultTheme;
  final int fileUploadMaxFileSize;

  // custom field, available only in forked TheLounge, see Readme.md
  @JsonKey(defaultValue: false)
  final bool signUp;

  // custom field, available only in forked TheLounge, see Readme.md
  @JsonKey(defaultValue: false)
  final bool fcmPushEnabled;

  const ConfigurationLoungeResponseBody({
    @required this.public,
    @required this.useHexIp,
    @required this.prefetch,
    @required this.fileUpload,
    @required this.ldapEnabled,
    @required this.defaults,
    @required this.isUpdateAvailable,
    @required this.applicationServerKey,
    @required this.version,
    @required this.gitCommit,
    @required this.lockNetwork,
    @required this.themes,
    @required this.defaultTheme,
    @required this.fileUploadMaxFileSize,
    @required this.signUp,
    @required this.fcmPushEnabled,
  });

  @override
  String toString() {
    return 'ConfigurationLoungeResponseBody{'
        'defaultTheme: $defaultTheme, '
        'defaults: $defaults, '
        'displayNetwork: $displayNetwork, '
        'fileUpload: $fileUpload, '
        'ldapEnabled: $ldapEnabled, '
        'lockNetwork: $lockNetwork, '
        'prefetch: $prefetch, '
        'public: $public, '
        'useHexIp: $useHexIp, '
        'themes: $themes, '
        'fileUploadMaxFileSize: $fileUploadMaxFileSize, '
        'gitCommit: $gitCommit, '
        'version: $version'
        'applicationServerKey: $applicationServerKey'
        'isUpdateAvailable: $isUpdateAvailable'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          public == other.public &&
          lockNetwork == other.lockNetwork &&
          useHexIp == other.useHexIp &&
          prefetch == other.prefetch &&
          fileUpload == other.fileUpload &&
          ldapEnabled == other.ldapEnabled &&
          defaults == other.defaults &&
          isUpdateAvailable == other.isUpdateAvailable &&
          applicationServerKey == other.applicationServerKey &&
          version == other.version &&
          gitCommit == other.gitCommit &&
          displayNetwork == other.displayNetwork &&
          themes == other.themes &&
          defaultTheme == other.defaultTheme &&
          fileUploadMaxFileSize == other.fileUploadMaxFileSize &&
          signUp == other.signUp &&
          fcmPushEnabled == other.fcmPushEnabled;

  @override
  int get hashCode =>
      public.hashCode ^
      lockNetwork.hashCode ^
      useHexIp.hashCode ^
      prefetch.hashCode ^
      fileUpload.hashCode ^
      ldapEnabled.hashCode ^
      defaults.hashCode ^
      isUpdateAvailable.hashCode ^
      applicationServerKey.hashCode ^
      version.hashCode ^
      gitCommit.hashCode ^
      displayNetwork.hashCode ^
      themes.hashCode ^
      defaultTheme.hashCode ^
      fileUploadMaxFileSize.hashCode ^
      signUp.hashCode ^
      fcmPushEnabled.hashCode;

  factory ConfigurationLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ConfigurationLoungeResponseBodyToJson(this);
}

// not supported on original TheLounge
@JsonSerializable()
class SignedUpLoungeResponseBody extends LoungeResponseBody {
  static const errorTypeInvalid = "invalid";
  static const errorTypeAlreadyExist = "already_exist";

  static String get eventName => LoungeResponseEventNames.signedUp;

  final bool success;
  final String errorType;

  @override
  const SignedUpLoungeResponseBody({
    @required this.success,
    @required this.errorType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignedUpLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          errorType == other.errorType;

  @override
  int get hashCode => success.hashCode ^ errorType.hashCode;

  @override
  String toString() {
    return 'RegistrationResponseBody{'
        'success: $success, '
        'errorType: $errorType'
        '}';
  }

  factory SignedUpLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$SignedUpLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$SignedUpLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class JoinLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.join;

  final ChannelLoungeResponseBodyPart chan;
  final int index;
  final String network;

  const JoinLoungeResponseBody({
    @required this.chan,
    @required this.index,
    @required this.network,
  });

  @override
  String toString() {
    return 'JoinLoungeResponseBody{'
        'chan: $chan, '
        'index: $index, '
        'network: $network'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JoinLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          index == other.index &&
          network == other.network;

  @override
  int get hashCode => chan.hashCode ^ index.hashCode ^ network.hashCode;

  factory JoinLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$JoinLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$JoinLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class PartLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.part;

  final int chan;

  const PartLoungeResponseBody({
    @required this.chan,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan;

  @override
  int get hashCode => chan.hashCode;

  @override
  String toString() {
    return 'PartLoungeResponseBody{'
        'chan: $chan'
        '}';
  }

  factory PartLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$PartLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$PartLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class QuitLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.quit;

  final String network;

  const QuitLoungeResponseBody({
    @required this.network,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuitLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          network == other.network;

  @override
  int get hashCode => network.hashCode;

  @override
  String toString() {
    return 'QuitLoungeResponseBody{network: $network}';
  }

  factory QuitLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$QuitLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$QuitLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class NetworkStatusLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.networkStatus;

  final bool connected;
  final String network;
  final bool secure;

  const NetworkStatusLoungeResponseBody({
    @required this.connected,
    @required this.network,
    @required this.secure,
  });

  @override
  String toString() {
    return 'NetworkStatusLoungeResponseBody{'
        'connected: $connected, '
        'network: $network, '
        'secure: $secure'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkStatusLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          connected == other.connected &&
          network == other.network &&
          secure == other.secure;

  @override
  int get hashCode => connected.hashCode ^ network.hashCode ^ secure.hashCode;

  factory NetworkStatusLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkStatusLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NetworkStatusLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class NetworkOptionsLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.networkOptions;

  final String network;
  final NetworkServerOptionsLoungeResponseBodyPart serverOptions;

  const NetworkOptionsLoungeResponseBody({
    @required this.network,
    @required this.serverOptions,
  });

  @override
  String toString() {
    return 'NetworkOptionsLoungeResponseBody{'
        'network: $network, '
        'serverOptions: $serverOptions'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkOptionsLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          network == other.network &&
          serverOptions == other.serverOptions;

  @override
  int get hashCode => network.hashCode ^ serverOptions.hashCode;

  factory NetworkOptionsLoungeResponseBody.fromJson(
          Map<String, dynamic> json) =>
      _$NetworkOptionsLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NetworkOptionsLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class NetworkServerOptionsLoungeResponseBodyPart
    extends LoungeResponseBodyPart {
  @JsonKey(name: "CHANTYPES")
  final List<String> chanTypes;

  @JsonKey(name: "NETWORK")
  final String network;

  @JsonKey(name: "PREFIX")
  final List<String> prefix;

  const NetworkServerOptionsLoungeResponseBodyPart({
    @required this.chanTypes,
    @required this.network,
    @required this.prefix,
  });

  @override
  String toString() {
    return 'NetworkServerOptionsLoungeResponseBodyPart{'
        'chanTypes: $chanTypes, '
        'network: $network, '
        'prefix: $prefix'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkServerOptionsLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          chanTypes == other.chanTypes &&
          network == other.network &&
          prefix == other.prefix;

  @override
  int get hashCode => chanTypes.hashCode ^ network.hashCode ^ prefix.hashCode;

  factory NetworkServerOptionsLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$NetworkServerOptionsLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NetworkServerOptionsLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class ChannelStateLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.channelState;
  final int chan;
  final int state;

  const ChannelStateLoungeResponseBody({
    @required this.chan,
    @required this.state,
  });

  @override
  String toString() {
    return 'ChannelStateLoungeResponseBody{'
        'chan: $chan, '
        'state: $state'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelStateLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          state == other.state;

  @override
  int get hashCode => chan.hashCode ^ state.hashCode;

  factory ChannelStateLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ChannelStateLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelStateLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class UsersLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.users;
  final int chan;
  final int unread;
  final int highlight;

  // simple or special
  final dynamic msg;

  const UsersLoungeResponseBody({
    @required this.chan,
    @required this.unread,
    @required this.highlight,
    @required this.msg,
  });

  factory UsersLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$UsersLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$UsersLoungeResponseBodyToJson(this);

  @override
  String toString() {
    return 'UsersLoungeResponseBody{'
        'chan: $chan, '
        'unread: $unread, '
        'highlight: $highlight, '
        'msg: $msg'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsersLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          unread == other.unread &&
          highlight == other.highlight &&
          msg == other.msg;

  @override
  int get hashCode =>
      chan.hashCode ^ unread.hashCode ^ highlight.hashCode ^ msg.hashCode;
}

@JsonSerializable()
class NickLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.nick;

  final String network;
  final String nick;

  const NickLoungeResponseBody({
    @required this.network,
    @required this.nick,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NickLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          network == other.network &&
          nick == other.nick;

  @override
  int get hashCode => network.hashCode ^ nick.hashCode;

  factory NickLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NickLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$NickLoungeResponseBodyToJson(this);

  @override
  String toString() {
    return 'NickLoungeResponseBody{'
        'network: $network, '
        'nick: $nick'
        '}';
  }
}

@JsonSerializable()
class MsgLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final MsgUserLoungeResponseBodyPart from;
  final MsgUserLoungeResponseBodyPart target;
  final String command;
  final String type;
  final String time;

  @JsonKey(name: "new_nick")
  final String newNick;

  @JsonKey(name: "new_host")
  final String newHost;

  @JsonKey(name: "new_ident")
  final String newIdent;
  final String text;
  final String ctcpMessage;
  final String hostmask;
  final bool self;
  final bool highlight;
  final bool showInActive;
  final List<String> users;
  final List<MsgPreviewLoungeResponseBodyPart> previews;
  final List<String> params;
  final int id;
  final WhoIsLoungeResponseBodyPart whois;

  MsgLoungeResponseBodyPart({
    @required this.from,
    @required this.target,
    @required this.command,
    @required this.type,
    @required this.time,
    @required this.newNick,
    @required this.newHost,
    @required this.newIdent,
    @required this.text,
    @required this.ctcpMessage,
    @required this.hostmask,
    @required this.self,
    @required this.highlight,
    @required this.showInActive,
    @required this.users,
    @required this.previews,
    @required this.params,
    @required this.id,
    @required this.whois,
  });

  @override
  String toString() {
    return 'MsgLoungeResponseBodyPart{'
        'from: $from, '
        'target: $target, '
        'command: $command, '
        'type: $type, '
        'time: $time, '
        'new_nick: $newNick, '
        'new_host: $newHost, '
        'new_ident: $newIdent, '
        'text: $text, '
        'ctcpMessage: $ctcpMessage,'
        'hostmask: $hostmask, '
        'self: $self, '
        'highlight: $highlight, '
        'showInActive: $showInActive, '
        'users: $users, '
        'previews: $previews, '
        'params: $params, '
        'id: $id, '
        'whois: $whois'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsgLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          target == other.target &&
          command == other.command &&
          type == other.type &&
          time == other.time &&
          newNick == other.newNick &&
          newHost == other.newHost &&
          newIdent == other.newIdent &&
          text == other.text &&
          ctcpMessage == other.ctcpMessage &&
          hostmask == other.hostmask &&
          self == other.self &&
          highlight == other.highlight &&
          showInActive == other.showInActive &&
          users == other.users &&
          previews == other.previews &&
          params == other.params &&
          id == other.id &&
          whois == other.whois;

  @override
  int get hashCode =>
      from.hashCode ^
      target.hashCode ^
      command.hashCode ^
      type.hashCode ^
      time.hashCode ^
      newNick.hashCode ^
      newHost.hashCode ^
      newIdent.hashCode ^
      text.hashCode ^
      ctcpMessage.hashCode ^
      hostmask.hashCode ^
      self.hashCode ^
      highlight.hashCode ^
      showInActive.hashCode ^
      users.hashCode ^
      previews.hashCode ^
      params.hashCode ^
      id.hashCode ^
      whois.hashCode;

  factory MsgLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$MsgLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$MsgLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class WhoIsLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final String account;
  final String channels;
  final String hostname;
  final String ident;

  @JsonKey(name: "actual_hostname")
  final String actualHostname;

  @JsonKey(name: "actual_ip")
  final String actualIp;
  final String idle;
  final int idleTime;
  final int logonTime;
  final String logon;
  final String nick;

  @JsonKey(name: "real_name")
  final String realName;
  final bool secure;
  final String server;

  @JsonKey(name: "server_info")
  final String serverInfo;

  @override
  String toString() {
    return 'WhoIsLoungeResponseBodyPart{'
        'account: $account, '
        'channels: $channels, '
        'hostname: $hostname, '
        'ident: $ident, '
        'idle: $idle, '
        'idleTime: $idleTime, '
        'logonTime: $logonTime, '
        'logon: $logon, '
        'nick: $nick, '
        'realName: $realName, '
        'secure: $secure, '
        'actualIp: $actualIp, '
        'actualHostname: $actualHostname, '
        'server: $server, '
        'serverInfo: $serverInfo'
        '}';
  }

  const WhoIsLoungeResponseBodyPart({
    @required this.account,
    @required this.channels,
    @required this.hostname,
    @required this.ident,
    @required this.idle,
    @required this.idleTime,
    @required this.logonTime,
    @required this.logon,
    @required this.actualHostname,
    @required this.actualIp,
    @required this.nick,
    @required this.realName,
    @required this.secure,
    @required this.server,
    @required this.serverInfo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhoIsLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          account == other.account &&
          channels == other.channels &&
          hostname == other.hostname &&
          ident == other.ident &&
          actualHostname == other.actualHostname &&
          actualIp == other.actualIp &&
          idle == other.idle &&
          idleTime == other.idleTime &&
          logonTime == other.logonTime &&
          logon == other.logon &&
          nick == other.nick &&
          realName == other.realName &&
          secure == other.secure &&
          server == other.server &&
          serverInfo == other.serverInfo;

  @override
  int get hashCode =>
      account.hashCode ^
      channels.hashCode ^
      hostname.hashCode ^
      ident.hashCode ^
      actualHostname.hashCode ^
      actualIp.hashCode ^
      idle.hashCode ^
      idleTime.hashCode ^
      logonTime.hashCode ^
      logon.hashCode ^
      nick.hashCode ^
      realName.hashCode ^
      secure.hashCode ^
      server.hashCode ^
      serverInfo.hashCode;

  factory WhoIsLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$WhoIsLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$WhoIsLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class MsgUserLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final int id;
  final String mode;
  final String nick;

  const MsgUserLoungeResponseBodyPart({
    @required this.id,
    @required this.mode,
    @required this.nick,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsgUserLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mode == other.mode &&
          nick == other.nick;

  @override
  int get hashCode => id.hashCode ^ mode.hashCode ^ nick.hashCode;

  @override
  String toString() {
    return 'MsgFromLoungeResponseBodyPart{'
        'id: $id, '
        'mode: $mode, '
        'nick: $nick'
        '}';
  }

  factory MsgUserLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$MsgUserLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$MsgUserLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class MsgPreviewLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final String head;
  final String body;
  final bool canDisplay;
  final bool shown;
  final String link;
  final String thumb;
  final String media;
  final String mediaType;
  final String type;

  const MsgPreviewLoungeResponseBodyPart({
    @required this.head,
    @required this.body,
    @required this.canDisplay,
    @required this.shown,
    @required this.link,
    @required this.thumb,
    @required this.media,
    @required this.mediaType,
    @required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsgPreviewLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          head == other.head &&
          body == other.body &&
          canDisplay == other.canDisplay &&
          shown == other.shown &&
          link == other.link &&
          thumb == other.thumb &&
          media == other.media &&
          mediaType == other.mediaType &&
          type == other.type;

  @override
  int get hashCode =>
      head.hashCode ^
      body.hashCode ^
      canDisplay.hashCode ^
      shown.hashCode ^
      link.hashCode ^
      thumb.hashCode ^
      media.hashCode ^
      mediaType.hashCode ^
      type.hashCode;

  @override
  String toString() {
    return 'MsgPreviewLoungeResponseBodyPart{'
        'head: $head, '
        'body: $body, '
        'canDisplay: $canDisplay, '
        'shown: $shown, '
        'link: $link, '
        'thumb: $thumb, '
        'media: $media, '
        'mediaType: $mediaType, '
        'type: $type'
        '}';
  }

  factory MsgPreviewLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$MsgPreviewLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MsgPreviewLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class MsgPreviewLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.msgPreview;

  final int id;
  final int chan;

  final MsgPreviewLoungeResponseBodyPart preview;

  @override
  String toString() => 'MsgPreviewLoungeResponseBody{'
      'id: $id, '
      'chan: $chan, '
      'preview: $preview'
      '}';

  const MsgPreviewLoungeResponseBody({
    @required this.id,
    @required this.chan,
    @required this.preview,
  });

  factory MsgPreviewLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$MsgPreviewLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$MsgPreviewLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class InitLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.init;

  static final int undefinedActiveID = -1;

  final int active;
  final List<NetworkLoungeResponseBodyPart> networks;
  final String token;
  final String applicationServerKey;
  final InitPushSubscriptionLoungeResponseBodyPart pushSubscription;

  const InitLoungeResponseBody({
    @required this.active,
    @required this.networks,
    @required this.token,
    @required this.applicationServerKey,
    @required this.pushSubscription,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InitLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          active == other.active &&
          networks == other.networks &&
          token == other.token &&
          applicationServerKey == other.applicationServerKey &&
          pushSubscription == other.pushSubscription;

  @override
  int get hashCode =>
      active.hashCode ^
      networks.hashCode ^
      token.hashCode ^
      applicationServerKey.hashCode ^
      pushSubscription.hashCode;

  factory InitLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$InitLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$InitLoungeResponseBodyToJson(this);

  @override
  String toString() {
    return 'InitLoungeResponseBody{'
        'active: $active, '
        'applicationServerKey: $applicationServerKey, '
        'token: $token, networks: $networks, '
        'pushSubscription: $pushSubscription'
        '}';
  }
}

@JsonSerializable()
class InitPushSubscriptionLoungeResponseBodyPart
    extends LoungeResponseBodyPart {
  final String agent;
  final String ip;
  final int lastUse;

  const InitPushSubscriptionLoungeResponseBodyPart({
    @required this.agent,
    @required this.ip,
    @required this.lastUse,
  });

  @override
  String toString() {
    return 'PushSubscriptionLoungeResponseBodyPart{'
        'agent: $agent, '
        'ip: $ip, '
        'lastUse: $lastUse'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InitPushSubscriptionLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          ip == other.ip &&
          lastUse == other.lastUse;

  @override
  int get hashCode => agent.hashCode ^ ip.hashCode ^ lastUse.hashCode;

  factory InitPushSubscriptionLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$InitPushSubscriptionLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$InitPushSubscriptionLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class NamesLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.names;

  final int id;
  final List<UserLoungeResponseBodyPart> users;

  const NamesLoungeResponseBody({
    @required this.id,
    @required this.users,
  });

  factory NamesLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NamesLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$NamesLoungeResponseBodyToJson(this);

  @override
  String toString() {
    return 'NamesLoungeResponseBody{'
        'id: $id, '
        'users: $users'
        '}';
  }
}

@JsonSerializable()
class TopicLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.topic;

  final int chan;
  final String topic;

  TopicLoungeResponseBody({
    @required this.chan,
    @required this.topic,
  });

  @override
  String toString() {
    return 'TopicLoungeResponseBody{'
        'chan: $chan, '
        'topic: $topic'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          chan == other.chan &&
          topic == other.topic;

  @override
  int get hashCode => chan.hashCode ^ topic.hashCode;

  factory TopicLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$TopicLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$TopicLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class TextSpecialMessageLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final String text;

  @override
  String toString() {
    return 'TextSpecialMessageLoungeResponseBodyPart{'
        'text: $text'
        '}';
  }

  const TextSpecialMessageLoungeResponseBodyPart({
    @required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSpecialMessageLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  factory TextSpecialMessageLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$TextSpecialMessageLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TextSpecialMessageLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class ChannelListItemSpecialMessageLoungeResponseBodyPart
    extends LoungeResponseBodyPart {
  final String channel;
  final String topic;

  @JsonKey(name: "num_users")
  final int numUsers;

  const ChannelListItemSpecialMessageLoungeResponseBodyPart({
    @required this.channel,
    @required this.topic,
    @required this.numUsers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelListItemSpecialMessageLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          channel == other.channel &&
          topic == other.topic &&
          numUsers == other.numUsers;

  @override
  int get hashCode => channel.hashCode ^ topic.hashCode ^ numUsers.hashCode;

  @override
  String toString() {
    return 'ChannelListItemSpecialMessageLoungeResponseBodyPart{'
        'channel: $channel, '
        'topic: $topic, '
        'numUsers: $numUsers'
        '}';
  }

  factory ChannelListItemSpecialMessageLoungeResponseBodyPart.fromJson(
          Map<String, dynamic> json) =>
      _$ChannelListItemSpecialMessageLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ChannelListItemSpecialMessageLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class UserLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final int lastMessage;
  final String mode;
  final String nick;

  const UserLoungeResponseBodyPart({
    @required this.lastMessage,
    @required this.mode,
    @required this.nick,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          lastMessage == other.lastMessage &&
          mode == other.mode &&
          nick == other.nick;

  @override
  int get hashCode => lastMessage.hashCode ^ mode.hashCode ^ nick.hashCode;

  factory UserLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$UserLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoungeResponseBodyPartToJson(this);

  @override
  String toString() {
    return 'UserLoungeResponseBodyPart{'
        'lastMessage: $lastMessage, '
        'mode: $mode, nick: $nick'
        '}';
  }
}

@JsonSerializable()
class NetworkLoungeResponseBody extends LoungeResponseBody {
  static String get eventName => LoungeResponseEventNames.network;

  final List<NetworkLoungeResponseBodyPart> networks;

  @override
  String toString() {
    return 'NetworkLoungeResponseBody{'
        'networks: $networks'
        '}';
  }

  const NetworkLoungeResponseBody({
    @required this.networks,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkLoungeResponseBody &&
          runtimeType == other.runtimeType &&
          networks == other.networks;

  @override
  int get hashCode => networks.hashCode;

  factory NetworkLoungeResponseBody.fromJson(Map<String, dynamic> json) =>
      _$NetworkLoungeResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkLoungeResponseBodyToJson(this);
}

@JsonSerializable()
class NetworkLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final List<dynamic> commands;
  final bool hasSTSPolicy;
  final String host;
  final String leaveMessage;
  final String name;
  final String nick;
  final String password;
  final int port;
  final String realname;
  final bool rejectUnauthorized;

  final String sasl;
  final String saslAccount;
  final String saslPassword;

  final bool tls;

  final String username;

  final String uuid;

  bool get userDisconnected => status.connected != true;
  final bool isCollapsed;
  final bool isJoinChannelShown;
  final List<ChannelLoungeResponseBodyPart> channels;
  final NetworkServerOptionsLoungeResponseBodyPart serverOptions;
  final NetworkStatusLoungeResponseBody status;



  const NetworkLoungeResponseBodyPart({
    @required this.uuid,
    @required this.name,
    @required this.host,
    @required this.port,
    @required this.tls,
    @required this.rejectUnauthorized,
    @required this.isCollapsed,
    @required this.isJoinChannelShown,
    @required this.nick,
    @required this.username,
    @required this.realname,
    @required this.commands,
    @required this.channels,
    @required this.serverOptions,
    @required this.status,
    @required this.leaveMessage,
    @required this.hasSTSPolicy,
    @required this.sasl,
    @required this.saslAccount,
    @required this.saslPassword,
    @required this.password,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          commands == other.commands &&
          hasSTSPolicy == other.hasSTSPolicy &&
          host == other.host &&
          leaveMessage == other.leaveMessage &&
          name == other.name &&
          nick == other.nick &&
          password == other.password &&
          port == other.port &&
          realname == other.realname &&
          rejectUnauthorized == other.rejectUnauthorized &&
          sasl == other.sasl &&
          saslAccount == other.saslAccount &&
          saslPassword == other.saslPassword &&
          tls == other.tls &&
          username == other.username &&
          uuid == other.uuid &&
          isCollapsed == other.isCollapsed &&
          isJoinChannelShown == other.isJoinChannelShown &&
          channels == other.channels &&
          serverOptions == other.serverOptions &&
          status == other.status;

  @override
  int get hashCode =>
      commands.hashCode ^
      hasSTSPolicy.hashCode ^
      host.hashCode ^
      leaveMessage.hashCode ^
      name.hashCode ^
      nick.hashCode ^
      password.hashCode ^
      port.hashCode ^
      realname.hashCode ^
      rejectUnauthorized.hashCode ^
      sasl.hashCode ^
      saslAccount.hashCode ^
      saslPassword.hashCode ^
      tls.hashCode ^
      username.hashCode ^
      uuid.hashCode ^
      isCollapsed.hashCode ^
      isJoinChannelShown.hashCode ^
      channels.hashCode ^
      serverOptions.hashCode ^
      status.hashCode;


  @override
  String toString() {
    return 'NetworkLoungeResponseBodyPart{'
        'commands: $commands, '
        'hasSTSPolicy: $hasSTSPolicy, '
        'host: $host, '
        'leaveMessage: $leaveMessage, '
        'name: $name, '
        'nick: $nick, '
        'password: $password, '
        'port: $port, '
        'realname: $realname, '
        'rejectUnauthorized: $rejectUnauthorized, '
        'sasl: $sasl, '
        'saslAccount: $saslAccount, '
        'saslPassword: $saslPassword, '
        'tls: $tls, '
        'username: $username, '
        'uuid: $uuid, '
        'isCollapsed: $isCollapsed, '
        'isJoinChannelShown: $isJoinChannelShown, '
        'channels: $channels, '
        'serverOptions: $serverOptions, '
        'status: $status'
        '}';
  }

  factory NetworkLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$NetworkLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkLoungeResponseBodyPartToJson(this);
}

@JsonSerializable()
class ChannelLoungeResponseBodyPart extends LoungeResponseBodyPart {
  final String name;
  final String type;
  final String key;
  final String pendingMessage;
  final List<MsgLoungeResponseBodyPart> messages;
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
  final List<UserLoungeResponseBodyPart> users;
  final int totalMessages;

  @override
  String toString() {
    return 'ChannelLoungeResponseBody{'
        'name: $name, '
        'type: $type, '
        'key: $key, '
        'pendingMessage: $pendingMessage, '
        'messages: $messages, '
        'inputHistory: $inputHistory, '
        'inputHistoryPosition: $inputHistoryPosition, '
        'id: $id, '
        'moreHistoryAvailable: $moreHistoryAvailable, '
        'historyLoading: $historyLoading, '
        'editTopic: $editTopic, '
        'scrolledToBottom: $scrolledToBottom, '
        'topic: $topic, '
        'state: $state, '
        'firstUnread: $firstUnread, '
        'totalMessages: $totalMessages, '
        'unread: $unread, '
        'highlight: $highlight, '
        'users: $users'
        '}';
  }

  const ChannelLoungeResponseBodyPart({
    @required this.name,
    @required this.type,
    @required this.key,
    @required this.pendingMessage,
    @required this.messages,
    @required this.inputHistory,
    @required this.inputHistoryPosition,
    @required this.id,
    @required this.moreHistoryAvailable,
    @required this.historyLoading,
    @required this.editTopic,
    @required this.scrolledToBottom,
    @required this.topic,
    @required this.state,
    @required this.firstUnread,
    @required this.unread,
    @required this.highlight,
    @required this.users,
    @required this.totalMessages,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelLoungeResponseBodyPart &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          key == other.key &&
          pendingMessage == other.pendingMessage &&
          messages == other.messages &&
          inputHistory == other.inputHistory &&
          inputHistoryPosition == other.inputHistoryPosition &&
          id == other.id &&
          moreHistoryAvailable == other.moreHistoryAvailable &&
          historyLoading == other.historyLoading &&
          editTopic == other.editTopic &&
          scrolledToBottom == other.scrolledToBottom &&
          topic == other.topic &&
          state == other.state &&
          firstUnread == other.firstUnread &&
          unread == other.unread &&
          highlight == other.highlight &&
          users == other.users &&
          totalMessages == other.totalMessages;

  @override
  int get hashCode =>
      name.hashCode ^
      type.hashCode ^
      key.hashCode ^
      pendingMessage.hashCode ^
      messages.hashCode ^
      inputHistory.hashCode ^
      inputHistoryPosition.hashCode ^
      id.hashCode ^
      moreHistoryAvailable.hashCode ^
      historyLoading.hashCode ^
      editTopic.hashCode ^
      scrolledToBottom.hashCode ^
      topic.hashCode ^
      state.hashCode ^
      firstUnread.hashCode ^
      unread.hashCode ^
      highlight.hashCode ^
      users.hashCode ^
      totalMessages.hashCode;

  factory ChannelLoungeResponseBodyPart.fromJson(Map<String, dynamic> json) =>
      _$ChannelLoungeResponseBodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelLoungeResponseBodyPartToJson(this);
}
