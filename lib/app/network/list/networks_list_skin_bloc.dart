

import 'package:flutter/painting.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class NetworkListSkinBloc extends SkinBloc {
  Color get separatorColor;

  TextStyle getNetworkItemTextStyle(bool isChannelActive);

  Color getNetworkItemIconColor(bool isChannelActive);

  Color getNetworkItemBackgroundColor(bool isChannelActive);
}
