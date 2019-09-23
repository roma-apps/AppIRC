import 'dart:ui';

import 'package:flutter_appirc/app/message/messages_colored_nicknames_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class MessagesColoredNicknamesBloc extends Providable {
  final MessagesColoredNicknamesData nicknameColorsData;

  List<Color> get _colors => nicknameColorsData.colors;

  MessagesColoredNicknamesBloc(this.nicknameColorsData);

  int _currentColorIndex = 0;
  Map<String, Color> _nickToColor = Map();


  Color getColorForNick(String nick) {

    if(!_nickToColor.containsKey(nick)) {
      _nickToColor[nick] = _colors[(_currentColorIndex++ % _colors.length)];
    }

    return _nickToColor[nick];
  }


}