import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_bloc.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

MyLogger _logger = MyLogger(logTag: "message_list_jump_to_newest_widget"
    ".dart", enabled: true);

class MessageListJumpToNewestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MessagesListJumpToNewestBloc messagesListJumpToNewestBloc =
        Provider.of(context);

    return StreamBuilder<MessagesListJumpToNewestState>(
        stream: messagesListJumpToNewestBloc.stateStream,
        initialData: messagesListJumpToNewestBloc.state,
        builder: (context, snapshot) {
          MessagesListJumpToNewestState state = snapshot.data;

          _logger.d(() => "MessagesListJumpToNewestState $state");

          if (state.isLastMessageShown) {
            return SizedBox.shrink();
          } else {
            return GestureDetector(
              onTap: () {
                messagesListJumpToNewestBloc.jumpToLatestMessage();
              },
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).backgroundColor),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildJumpText(context, state),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Text _buildJumpText(
      BuildContext context, MessagesListJumpToNewestState state) {
    var newMessagesCount = state.newMessagesCount;

    String text;
    if (newMessagesCount > 0) {
      text = tr(
          "chat.messages_list.jump_to_latest.with_new_messages",
          args: [newMessagesCount.toString()]);
    } else {
      text = tr("chat.messages_list.jump_to_latest.no_messages");
    }

    return Text(text);
  }
}
