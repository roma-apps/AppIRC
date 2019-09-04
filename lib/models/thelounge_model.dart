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
