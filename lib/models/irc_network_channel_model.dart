import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';


class IRCNetworkChannel {
  final String name;

  final int remoteId;

  @override
  String toString() {
    return 'IRCNetworkChannel{name: $name, remoteId: $remoteId}';
  }

  IRCNetworkChannel({@required this.name, @required this.remoteId});
}
