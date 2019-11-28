import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_model.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';

class MessageListLoadMoreWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MessageListLoadMoreBloc messageListLoadMoreBloc = Provider.of(context);
    return StreamBuilder<LoadMoreState>(
        stream: messageListLoadMoreBloc.stateStream.distinct(),
        initialData: messageListLoadMoreBloc.state,
        builder: (context, snapshot) {
          var loadMoreState = snapshot.data;
          Widget child;
          switch (loadMoreState) {
            case LoadMoreState.notAvailable:
              MessageSkinBloc skinBloc = Provider.of(context);
              child = Text(
                AppLocalizations.of(context)
                    .tr("chat.messages_list.load_more.not_available"),
                style: skinBloc.messageBodyTextStyle,
              );
              break;
            case LoadMoreState.available:
              child = createSkinnedPlatformButton(context, onPressed: () {
                MessageListLoadMoreBloc loadMoreBloc = Provider.of(context);
                loadMoreBloc.loadMore();
              },
                  child: Text(AppLocalizations.of(context)
                      .tr("chat.messages_list.load_more.action")));
              break;
            case LoadMoreState.loading:
              child = CircularProgressIndicator();
              break;
          }

          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          );
        });
  }
}
