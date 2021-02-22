import 'dart:ui';

import 'package:flutter_appirc/colored_nicknames/colored_nicknames_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

class ColoredNicknamesBloc extends DisposableOwner {
  final ColoredNicknamesData nicknameColorsData;

  List<Color> get _colors => nicknameColorsData.colors;

  ColoredNicknamesBloc(this.nicknameColorsData);

  int _currentColorIndex = 0;
  final Map<String, Color> _nickToColor = {};

  Color getColorForNick(String nick) {
    if (!_nickToColor.containsKey(nick)) {
      var index = (_currentColorIndex++ % _colors.length);
      _nickToColor[nick] = _colors[index];
    }

    return _nickToColor[nick];
    }
}
