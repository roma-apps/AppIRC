import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_model.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_skin_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MessageListSearchWidget extends StatefulWidget {
  MessageListSearchWidget();

  @override
  MessageListSearchWidgetState createState() => MessageListSearchWidgetState();
}

class MessageListSearchWidgetState extends State<MessageListSearchWidget> {
  TextEditingController _searchController;

  MessageListSearchWidgetState();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ChannelBloc channelBloc = ChannelBloc.of(context);

    return StreamBuilder(
      stream: channelBloc.messagesBloc.searchEnabledStream,
      initialData: channelBloc.messagesBloc.searchEnabled,
      builder: (context, snapshot) {
        var enabled = snapshot.data;

        if (enabled) {
          return _buildSearchBox(context);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Container _buildSearchBox(BuildContext context) {
    MessageListSearchSkinBloc messagesListSearchSkinBloc = Provider.of(context);
    return Container(
      decoration: messagesListSearchSkinBloc.searchBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            _buildSearchTextField(context),
            _buildGoToPreviousButton(context),
            _buildGoToNextButton(context),
            _buildHideSearchButton(context),
          ],
        ),
      ),
    );
  }

  StreamBuilder<MessageListSearchState> _buildSearchTextField(
      BuildContext context) {
    ChannelBloc channelBloc = ChannelBloc.of(context);
    MessageListBloc chatMessagesListBloc = Provider.of(context);

    return StreamBuilder<MessageListSearchState>(
        stream: chatMessagesListBloc.searchStateStream,
        initialData: chatMessagesListBloc.searchState,
        builder: (context, snapshot) {
          var searchState = snapshot.data;

          String labelText =
              _calculateSearchFieldLabelText(context, searchState);

          return Flexible(
            child: buildFormTextField(
                context: context,
                bloc: channelBloc.messagesBloc.searchFieldBloc,
                controller: _searchController,
                label: labelText,
                hint: AppLocalizations.of(context)
                    .tr("chat.messages_list.search.field.filter.hint")),
          );
        });
  }

  String _calculateSearchFieldLabelText(
      BuildContext context, MessageListSearchState searchState) {
    String labelText;
    if (searchState.searchTerm?.isNotEmpty == true) {
      if (searchState.foundItems.isEmpty) {
        labelText = AppLocalizations.of(context)
            .tr("chat.messages_list.search.field.filter"
                ".label.nothing_found");
      } else {
        labelText = AppLocalizations.of(context)
            .tr("chat.messages_list.search.field.filter.label.found", args: [
          searchState.selectedFoundMessagePosition.toString(),
          searchState.maxPossibleSelectedFoundPosition.toString()
        ]);
      }
    } else {
      // empty label if search not started
    }
    return labelText;
  }

  PlatformIconButton _buildHideSearchButton(BuildContext context) {
    ChannelBloc channelBloc = ChannelBloc.of(context);
    MessageListSearchSkinBloc messagesListSearchSkinBloc = Provider.of(context);

    Color disabledColor = messagesListSearchSkinBloc.disabledColor;
    return PlatformIconButton(
      icon: Icon(
        Icons.cancel,
        color: messagesListSearchSkinBloc.iconColor,
      ),
      onPressed: () {
        channelBloc.messagesBloc.onNeedHideSearch();
      },
      disabledColor: disabledColor,
    );
  }

  StreamBuilder<bool> _buildGoToNextButton(BuildContext context) {
    MessageListSearchSkinBloc messagesListSearchSkinBloc = Provider.of(context);

    MessageListBloc chatMessagesListBloc = Provider.of(context);
    Color disabledColor = messagesListSearchSkinBloc.disabledColor;
    return StreamBuilder<bool>(
        stream: chatMessagesListBloc.searchNextEnabledStream,
        initialData: chatMessagesListBloc.searchNextEnabled,
        builder: (context, snapshot) {
          var enabled = snapshot.data;
          return PlatformIconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: enabled
                  ? messagesListSearchSkinBloc.iconColor
                  : disabledColor,
            ),
            onPressed: enabled
                ? () {
                    chatMessagesListBloc.goToNextFoundMessage();
                  }
                : null,
            disabledColor: disabledColor,
          );
        });
  }

  StreamBuilder<bool> _buildGoToPreviousButton(BuildContext context) {
    MessageListSearchSkinBloc messagesListSearchSkinBloc = Provider.of(context);

    MessageListBloc chatMessagesListBloc = Provider.of(context);
    Color disabledColor = messagesListSearchSkinBloc.disabledColor;
    return StreamBuilder<bool>(
        stream: chatMessagesListBloc.searchPreviousEnabledStream,
        initialData: chatMessagesListBloc.searchPreviousEnabled,
        builder: (context, snapshot) {
          var enabled = snapshot.data;
          return PlatformIconButton(
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: enabled
                  ? messagesListSearchSkinBloc.iconColor
                  : disabledColor,
            ),
            onPressed: enabled
                ? () {
                    chatMessagesListBloc.goToPreviousFoundMessage();
                  }
                : null,
            disabledColor: disabledColor,
          );
        });
  }
}
