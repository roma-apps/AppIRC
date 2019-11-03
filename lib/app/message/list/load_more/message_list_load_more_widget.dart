import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_model.dart';
import 'package:flutter_appirc/async/async_loading_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class MessageListLoadMoreWidget extends StatefulWidget {
  @override
  _MessageListLoadMoreWidgetState createState() =>
      _MessageListLoadMoreWidgetState();
}

class _MessageListLoadMoreWidgetState extends State<MessageListLoadMoreWidget> {
  @override
  Widget build(BuildContext context) {
    MessageListLoadMoreBloc loadMoreBloc = Provider.of(context);

    return StreamBuilder(
        initialData: loadMoreBloc.state,
        stream: loadMoreBloc.stateStream,
        builder: (context, snapshot) {
          MessageListLoadMoreState messageListLoadMoreState = snapshot.data;
          switch (messageListLoadMoreState) {
            case MessageListLoadMoreState.notAvailable:
              return buildLoadingWidget(
                  context,
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.load_more.not_available"));
              return Text(
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.load_more.not_available"));
              return SizedBox.shrink();
              break;
            case MessageListLoadMoreState.available:
              return buildLoadingWidget(
                  context,
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.load_more.available"));
              return Text(
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.load_more.available"));
              return SizedBox.shrink();
              break;
            case MessageListLoadMoreState.loading:
              return buildLoadingWidget(
                  context,
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.load_more.loading"));
              break;
          }

          throw "Invalid state $messageListLoadMoreState";
        });
  }
}
