import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';
import 'package:provider/provider.dart';

SpanBuilder buildNicknameSpanHighlighter({
  @required BuildContext context,
  @required String nickname,
}) {
  var nickNamesBloc = Provider.of<ColoredNicknamesBloc>(context);
  return SpanBuilder.name(
    highlightString: nickname,
    highlightTextStyle: IAppIrcUiTextTheme.of(context).mediumDarkGrey.copyWith(
          color: nickNamesBloc.getColorForNick(
            nickname,
          ),
        ),
    tapCallback: (word, screenPosition) {
      var local = screenPosition.global;
      RelativeRect position = RelativeRect.fromLTRB(
        local.dx,
        local.dy,
        local.dx,
        local.dy,
      );
      var channelBloc = ChannelBloc.of(
        context,
        listen: false,
      );
      String nick = word;
      showPopupMenuForUser(
        context,
        position,
        nick,
        channelBloc,
      );
    },
  );
}
