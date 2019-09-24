import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/socketio/socketio_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_request_model.g.dart';

class LoungeRequestEventNames {
  static const String networkNew = "network:new";
  static const String names = "names";
  static const String input = "input";
  static const String open = "open";
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

class InputLoungeRequestBody extends LoungeRequestBody {
  final int target;
  final String content;

  InputLoungeRequestBody({@required this.target, @required this.content});

  @override
  Map<String, dynamic> toJson() => {"target": target, "text": content};
}

@JsonSerializable()
class NamesLoungeRequestBody extends LoungeRequestBody {
  final int target;

  @override
  String toString() {
    return 'NamesLoungeRequestBody{target: $target}';
  }

  NamesLoungeRequestBody(this.target);

  NamesLoungeRequestBody.name({@required this.target});

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

  bool get isTls => tls == LoungeConstants.on;

  bool get isRejectUnauthorized => rejectUnauthorized == LoungeConstants.on;

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
