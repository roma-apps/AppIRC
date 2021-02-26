import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_bloc.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("message_list_jump_to_newest_widget.dart");

class MessageListJumpToNewestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var messagesListJumpToNewestBloc =
        Provider.of<MessagesListJumpToNewestBloc>(context);

    return StreamBuilder<MessagesListJumpToNewestState>(
        stream: messagesListJumpToNewestBloc.stateStream,
        initialData: messagesListJumpToNewestBloc.state,
        builder: (context, snapshot) {
          MessagesListJumpToNewestState state = snapshot.data;

          _logger.fine(() => "MessagesListJumpToNewestState $state");

          if (state.isLastMessageShown) {
            return const SizedBox.shrink();
          } else {
            return GestureDetector(
              onTap: () {
                messagesListJumpToNewestBloc.jumpToLatestMessage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: IAppIrcUiColorTheme.of(context).lightGrey,
                ),
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
    BuildContext context,
    MessagesListJumpToNewestState state,
  ) {
    var newMessagesCount = state.newMessagesCount;

    String text;
    if (newMessagesCount > 0) {
      text = S.of(context).chat_messages_list_jump_to_latest_with_new_messages(
          newMessagesCount);
    } else {
      text = S.of(context).chat_messages_list_jump_to_latest_no_messages;
    }

    return Text(text);
  }
}
