import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

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
            child = Text(
              S.of(context).chat_messages_list_load_more_not_available,
              style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
            );
            break;
          case LoadMoreState.available:
            child = PlatformButton(
              onPressed: () {
                MessageListLoadMoreBloc loadMoreBloc = Provider.of(context);
                loadMoreBloc.loadMore();
              },
              child: Text(
                S.of(context).chat_messages_list_load_more_action,
              ),
            );
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
      },
    );
  }
}
