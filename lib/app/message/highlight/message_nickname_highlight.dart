import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter.dart';

SpanHighlighter buildNicknameSpanHighlighter(
    {@required BuildContext context, @required String nickname}) {
  var messagesSkin = Provider.of<MessageSkinBloc>(context);

  var nickNamesBloc = Provider.of<ColoredNicknamesBloc>(context);
  return SpanHighlighter.name(
      highlightString: nickname,
      highlightTextStyle: messagesSkin
          .createNickTextStyle(nickNamesBloc.getColorForNick(nickname)),
      tapCallback: (word, screenPosition) {
        var local = screenPosition.global;
        RelativeRect position =
            RelativeRect.fromLTRB(local.dx, local.dy, local.dx, local.dy);
        ChannelBloc channelBloc = Provider.of(context);
        String nick = word;
        showPopupMenuForUser(context, position, nick, channelBloc);
      });
}
