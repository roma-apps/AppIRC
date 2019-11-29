import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_widget.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_page.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_widget.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

enum MessageWidgetType { formatted, raw }

Widget buildMessageWidget(
    {@required ChatMessage message,
    @required bool inSearchResults,
    @required bool enableMessageActions,
    @required MessageWidgetType messageWidgetType}) {
  Widget child;
  switch (message.chatMessageType) {
    case ChatMessageType.regular:
      child = RegularMessageWidget(
          message: message,
          inSearchResults: inSearchResults,
          enableMessageActions: enableMessageActions,
          messageWidgetType: messageWidgetType);
      break;
    case ChatMessageType.special:
      child = SpecialMessageWidget(
          message: message,
          inSearchResults: inSearchResults,
          enableMessageActions: enableMessageActions,
          messageWidgetType: messageWidgetType);
      break;
  }
  return child;
}

abstract class MessageWidget<T extends ChatMessage> extends StatelessWidget {
  final T message;
  final bool inSearchResults;
  final bool enableMessageActions;
  final MessageWidgetType messageWidgetType;

  String getBodyRawText(BuildContext context);

  MessageWidget(
      {@required this.message,
      @required this.enableMessageActions,
      @required this.inSearchResults,
      @required this.messageWidgetType});

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
    Navigator.push(context,
        platformPageRoute(builder: (context) => MessagePage(channel, message)));
  }

  void _showMessagePopup(BuildContext context, RelativeRect tapPosition) {
    var appLocalizations = AppLocalizations.of(context);
    showPlatformAwarePopup(context, tapPosition, [
      PlatformAwarePopupMenuAction(
          text: appLocalizations.tr("chat.message.action.copy"),
          iconData: Icons.content_copy,
          actionCallback: (action) {
            Clipboard.setData(ClipboardData(text: getBodyRawText(context)));
          }),
    ]);
  }

  Widget _buildDecoratedBody(BuildContext context) {
    MessageListBloc messageListBloc = Provider.of(context);
    return StreamBuilder<ChatMessage>(
      stream: messageListBloc.getMessageUpdateStream(message),
      initialData: message,
      builder: (context, snapshot) {

        ChatMessage message = snapshot.data;
        return Container(
            decoration:
                _createMessageDecoration(context: context, message: message),
            child: buildMessageBody(context));
      }
    );
  }

  Widget buildMessageBody(BuildContext context);

  _createMessageDecoration(
      {@required BuildContext context, @required ChatMessage message}) {
    var isHighlightBySearch = inSearchResults;

    var decoration;
    bool isHighlightByServer;

    if (message is RegularMessage) {
      isHighlightByServer = isHighlightedByServer(message);
    }

    var messagesSkin = Provider.of<MessageListSkinBloc>(context);
    if (isHighlightBySearch) {
      decoration = messagesSkin.highlightSearchDecoration;
    } else {
      if (isHighlightByServer ??= false) {
        decoration = messagesSkin.highlightServerDecoration;
      }
    }
    return decoration;
  }
}

var _timeFormatter = new DateFormat().add_Hm();

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

TextSpan buildMessageDateTextSpan(
    {@required BuildContext context,
    @required DateTime date,
    @required Color color}) {
  var messagesSkin = Provider.of<MessageSkinBloc>(context);
  var dateString = _timeFormatter.format(date);

  var dateTextSpan = TextSpan(
    // add additional space as right margin
    // hack, but using additional space is better for performance
    // than additional empty span for space
    text: "$dateString",
    style: messagesSkin.createDateTextStyle(color),
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

var _dateFormatter = new DateFormat().add_yMd().add_Hms();

Widget buildMessageRawBody(
    BuildContext context, ChatMessage message, String text) {
  MessageSkinBloc messageSkinBloc = Provider.of(context);

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
        child: SelectableText(text,
            toolbarOptions: ToolbarOptions(
                copy: true, selectAll: true, cut: false, paste: false),
            style: messageSkinBloc.messageBodyTextStyle),
      )),
    ],
  );
}
