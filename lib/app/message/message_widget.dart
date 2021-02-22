import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_widget.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_page.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_widget.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';

import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("message_widget.dart");

enum MessageWidgetType { formatted, raw }

Widget buildMessageWidget(
    {@required ChatMessage message,
    @required bool enableMessageActions,
    @required MessageInListState messageInListState,
    @required MessageWidgetType messageWidgetType}) {
  Widget child;
  switch (message.chatMessageType) {
    case ChatMessageType.regular:
      child = RegularMessageWidget(
          message: message,
          messageInListState: messageInListState,
          enableMessageActions: enableMessageActions,
          messageWidgetType: messageWidgetType);
      break;
    case ChatMessageType.special:
      child = SpecialMessageWidget(
          message: message,
          messageInListState: messageInListState,
          enableMessageActions: enableMessageActions,
          messageWidgetType: messageWidgetType);
      break;
  }
  return child;
}

final MessageInListState notInSearchState =
    MessageInListState.name(inSearchResult: false, searchTerm: null);

abstract class MessageWidget<T extends ChatMessage> extends StatelessWidget {
  final T message;
  final bool enableMessageActions;
  final MessageWidgetType messageWidgetType;
  final MessageInListState messageInListState;

  String getBodyRawText(BuildContext context);

  MessageWidget({
    @required this.message,
    @required this.enableMessageActions,
    @required this.messageWidgetType,
    @required this.messageInListState,
  });

  @override
  Widget build(BuildContext context) {
    if (enableMessageActions) {
      RelativeRect tapPosition;
      void _handleTapDown(TapDownDetails details) {
//        final RenderBox referenceBox = context.findRenderObject();
        var global = details.globalPosition;
        tapPosition =
            RelativeRect.fromLTRB(global.dx, global.dy, global.dx, global.dy);
      }

      return GestureDetector(
        onTapDown: _handleTapDown,
        onLongPress: () {
          _showMessagePopup(context, tapPosition);
        },
        onTap: () {
          _showMessagePage(context);
        },
        child: _buildDecoratedBody(context),
      );
    } else {
      return _buildDecoratedBody(context);
    }
  }

  void _showMessagePage(BuildContext context) {
    var channel = ChannelBloc.of(context).channel;
    Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (context) => MessagePage(channel, message),
      ),
    );
  }

  void _showMessagePopup(BuildContext context, RelativeRect tapPosition) {
    showPlatformAwarePopup(
      context,
      tapPosition,
      [
        PlatformAwarePopupMenuAction(
          text: S.of(context).chat_message_action_copy,
          iconData: Icons.content_copy,
          actionCallback: (action) {
            Clipboard.setData(ClipboardData(text: getBodyRawText(context)));
          },
        ),
      ],
    );
  }

  Widget _buildDecoratedBody(BuildContext context) {
    var messageSaverBloc = Provider.of<MessageManagerBloc>(context);

    return StreamBuilder<ChatMessage>(
      stream: messageSaverBloc.getMessageUpdateStream(message),
      initialData: message,
      builder: (context, snapshot) {
        ChatMessage message = snapshot.data;

        _logger.fine(() => "StreamBuilder messageState =$message");
        return Container(
            decoration: _createMessageDecoration(context: context),
            child: buildMessageBody(context, message));
      },
    );
  }

  Widget buildMessageBody(BuildContext context, ChatMessage message);

  Decoration _createMessageDecoration({@required BuildContext context}) {
    var decoration;
    bool isHighlightByServer;

    var currentMessage = message;
    if (currentMessage is RegularMessage) {
      isHighlightByServer = isHighlightedByServer(currentMessage);
    }

    if (isHighlightByServer ??= false) {
      decoration = BoxDecoration(
        color: IAppIrcUiColorTheme.of(context).primaryDark,
      );
    }

    return decoration;
  }
}

var _timeFormatter = DateFormat().add_Hm();

WidgetSpan buildHighlightedNicknameButtonWidgetSpan(
    {@required BuildContext context, @required String nick}) {
  return WidgetSpan(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: buildUserNickWithPopupMenu(
          context: context, nick: nick, actionCallback: null),
    ),
  );
}

WidgetSpan buildMessageIconWidgetSpan(
    {@required IconData iconData, @required Color color}) {
  return WidgetSpan(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(
        iconData,
        size: 16,
        color: color,
      ),
    ),
  );
}

TextSpan buildMessageDateTextSpan({
  @required BuildContext context,
  @required DateTime date,
  @required Color color,
}) {
  var dateString = _timeFormatter.format(date);

  var dateTextSpan = TextSpan(
    // add additional space as right margin
    // hack, but using additional space is better for performance
    // than additional empty span for space
    text: "$dateString",
    style: IAppIrcUiTextTheme.of(context).mediumDarkGrey.copyWith(
          color: color,
        ),
  );
  return dateTextSpan;
}

RichText buildMessageRichText(List<InlineSpan> spans) {
  return RichText(
    text: TextSpan(
      children: spans,
    ),
  );
}

var _dateFormatter = DateFormat().add_yMd().add_Hms();

Widget buildMessageRawBody(
    BuildContext context, ChatMessage message, String text) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildMessageDateWidget(
                context, _dateFormatter.format(message.date)),
          )),
      Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectableText(
          text,
          toolbarOptions: ToolbarOptions(
            copy: true,
            selectAll: true,
            cut: false,
            paste: false,
          ),
          style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
        ),
      )),
    ],
  );
}
