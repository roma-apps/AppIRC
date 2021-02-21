import 'package:flutter/material.dart' show Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_regular_condensed.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class CondensedMessageWidget extends StatefulWidget {
  final CondensedMessageListItem _condensedMessageListItem;

  CondensedMessageWidget(this._condensedMessageListItem);

  @override
  _CondensedMessageWidgetState createState() => _CondensedMessageWidgetState();
}

class _CondensedMessageWidgetState extends State<CondensedMessageWidget> {
  @override
  Widget build(BuildContext context) {
    bool expanded = widget._condensedMessageListItem.isCondensed == false;
    if (expanded) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCondensedTitle(
                context, widget._condensedMessageListItem, expanded),
            _buildCondensedBody(context, widget._condensedMessageListItem),
          ]);
    } else {
      return _buildCondensedTitle(
          context, widget._condensedMessageListItem, expanded);
    }
  }

  Widget _buildCondensedTitle(BuildContext context,
      CondensedMessageListItem condensedMessageListItem, bool expanded) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildCondensedTitleMessage(
                  context, condensedMessageListItem),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildCondensedTitleButton(
                  context, condensedMessageListItem, expanded)),
        ]);
  }

  Widget _buildCondensedBody(
      BuildContext context, CondensedMessageListItem condensedMessageListItem) {
//    MessageListBloc messageListBloc = Provider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: condensedMessageListItem.messages.map((message) {
        return buildMessageWidget(
            message: message,
            enableMessageActions: true,
            messageWidgetType: MessageWidgetType.formatted,
            messageInListState: notInSearchState);
      }).toList(),
    );
  }

  Widget _buildCondensedTitleMessage(
    BuildContext context,
    CondensedMessageListItem condensedMessageListItem,
  ) {
    Map<RegularMessageType, List<ChatMessage>> groupedByType = {};

    condensedMessageListItem.messages.forEach((message) {
      if (message is RegularMessage) {
        var regularMessageType = message.regularMessageType;
        if (!groupedByType.containsKey(regularMessageType)) {
          groupedByType[regularMessageType] = <ChatMessage>[];
        }

        groupedByType[regularMessageType].add(message);
      } else {
        throw "Invalid message type $message";
      }
    });

    var textString = groupedByType.keys
        .map(
          (regularType) => getCondensedStringForRegularMessageTypeAndCount(
            context,
            regularType,
            groupedByType[regularType].length,
          ),
        )
        .join(
          S.of(context).chat_message_condensed_join_separator,
        );

    return GestureDetector(
      onTap: () {
        _toggleCondensed(context);
      },
      child: Text(
        textString,
        softWrap: true,
        style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
      ),
    );
  }

  Widget _buildCondensedTitleButton(
    BuildContext context,
    CondensedMessageListItem condensedMessageListItem,
    bool expanded,
  ) {
    return GestureDetector(
      onTap: () {
        _toggleCondensed(context);
      },
      child: Icon(
        expanded ? Icons.arrow_drop_down : Icons.arrow_right,
        color: IAppIrcUiColorTheme.of(context).darkGrey,
      ),
    );
  }

  void _toggleCondensed(BuildContext context) {
    var messageListItem = widget._condensedMessageListItem;
    messageListItem.isCondensed = !messageListItem.isCondensed;

    ChannelBloc channelBloc = ChannelBloc.of(context);
    MessageCondensedBloc condensedBloc = Provider.of(context);

    condensedBloc.onCondensedStateChanged(channelBloc.channel, messageListItem);

    setState(() {});
  }
}
