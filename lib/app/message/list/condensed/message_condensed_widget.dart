import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_regular_condensed.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CondensedMessageWidget extends StatefulWidget {
  final CondensedMessageListItem _condensedMessageListItem;
  final bool _inSearchResults;
  final String _searchTerm;

  bool get _expanded =>
      !_condensedMessageListItem.isCondensed || _inSearchResults;
  CondensedMessageWidget(
      this._condensedMessageListItem, this._inSearchResults, this._searchTerm);

  @override
  _CondensedMessageWidgetState createState() => _CondensedMessageWidgetState();
}

class _CondensedMessageWidgetState extends State<CondensedMessageWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget._expanded) {
      return Column(children: <Widget>[
        _buildCondensedTitle(context, widget._condensedMessageListItem),
        _buildCondensedBody(context, widget._condensedMessageListItem),
      ]);
    } else {
      return _buildCondensedTitle(context, widget._condensedMessageListItem);
    }
  }

  Widget _buildCondensedTitle(
      BuildContext context, CondensedMessageListItem condensedMessageListItem) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildCondensedTitleMessage(
                  context, condensedMessageListItem)),
          _buildCondensedTitleButton(context, condensedMessageListItem),
        ]);
  }

  Widget _buildCondensedBody(
      BuildContext context, CondensedMessageListItem condensedMessageListItem) {
    return Column(
      children: condensedMessageListItem.messages.map((message) {
        var searchTerm = widget._searchTerm;
        bool inSearchResults;
        if (widget._inSearchResults) {
          inSearchResults =
              message.isContainsText(searchTerm, ignoreCase: true);
        } else {
          inSearchResults = false;
        }
        return buildMessageItem(context, message, inSearchResults, searchTerm);
      }).toList(),
    );
  }

  _buildCondensedTitleMessage(
      BuildContext context, CondensedMessageListItem condensedMessageListItem) {
    Map<RegularMessageType, List<ChatMessage>> groupedByType = Map();

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
        .map((regularType) => getCondensedStringForRegularMessageTypeAndCount(
            context, regularType, groupedByType[regularType].length))
        .join(AppLocalizations.of(context)
            .tr("chat.message.condensed.join_separator"));
    return Text(textString);
  }

  _buildCondensedTitleButton(
      BuildContext context, CondensedMessageListItem condensedMessageListItem) {
    return PlatformIconButton(
      icon: Icon(widget._expanded ? Icons.arrow_drop_down : Icons.arrow_right),
      onPressed: () {
        condensedMessageListItem.isCondensed =
            !condensedMessageListItem.isCondensed;
        setState(() {});
      },
    );
  }
}
