import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_bloc.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

DateFormat _format = DateFormat().add_yMd();

class ChatSearchWidget extends StatefulWidget {
  @override
  _ChatSearchWidgetState createState() => _ChatSearchWidgetState();
}

class _ChatSearchWidgetState extends State<ChatSearchWidget> {
  TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSearchTextField(context),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildSearchResults(context),
        )),
      ],
    );
  }

  Widget _buildGroupSeparator(DateTime date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(_format.format(date)),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    var searchBloc = Provider.of<ChatSearchBloc>(context);

    return StreamBuilder<SearchState>(
      stream: searchBloc.searchStateStream,
      initialData: searchBloc.searchState,
      builder: (context, snapshot) {
        var result = snapshot.data;

        if (result != null) {
          if (result.isLoading) {
            return CircularProgressIndicator();
          } else {
            var messages = result.messages;
            if (messages?.isNotEmpty == true) {
              return GroupedListView<ChatMessage, DateTime>(
                elements: messages,
                groupBy: (message) {
                  var date = message.date;
                  return DateTime(date.year, date.month, date.day);
                },
                groupSeparatorBuilder: _buildGroupSeparator,
                itemBuilder: (context, message) => buildMessageWidget(
                  message: message,
                  enableMessageActions: true,
                  messageWidgetType: MessageWidgetType.formatted,
                  messageInListState: MessageInListState(
                    inSearchResult: true,
                    searchTerm: result.searchTerm,
                  ),
                ),
              );
            } else {
              return Text(
                S.of(context).chat_search_nothing_found,
              );
            }
          }
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
    ChatSearchBloc searchBloc = Provider.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildFormTextField(
        context: context,
        textInputAction: TextInputAction.search,
        onEditingComplete: () {
          searchBloc.search();
        },
        bloc: searchBloc.searchFieldBloc,
        controller: _searchController,
        hint: S.of(context).chat_search_field_filter_hint,
        label: null,
      ),
    );
  }
}
