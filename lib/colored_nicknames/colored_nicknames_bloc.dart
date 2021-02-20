import 'dart:ui';

import 'package:flutter_appirc/colored_nicknames/colored_nicknames_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ColoredNicknamesBloc extends Providable {
  final ColoredNicknamesData nicknameColorsData;

  List<Color> get _colors => nicknameColorsData.colors;

  ColoredNicknamesBloc(this.nicknameColorsData);

  int _currentColorIndex = 0;
  final Map<String, Color> _nickToColor = {};

  Color getColorForNick(String nick) {
    if (!_nickToColor.containsKey(nick)) {
      _nickToColor[nick] = _colors[(_currentColorIndex++ % _colors.length)];
    }

    return _nickToColor[nick];
  }
}
