import 'package:flutter/painting.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class ChannelListSkinBloc extends SkinBloc {
  TextStyle getChannelItemTextStyle(bool isChannelActive);

  Color getChannelItemIconColor(bool isChannelActive);

  Color getChannelItemBackgroundColor(bool isChannelActive);
  Color getChannelUnreadItemBackgroundColor(bool isChannelActive);
  TextStyle getChannelUnreadTextStyle(bool isChannelActive);
}
