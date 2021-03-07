import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatelessWidget {
  final Channel channel;
  final ChatMessage message;

  MessagePage(this.channel, this.message);

  @override
  Widget build(BuildContext context) {
    return buildPlatformScaffold(
      context,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PlatformAppBar _buildAppBar(BuildContext context) {
    return PlatformAppBar(
      leading: buildPlatformScaffoldAppBarBackButton(context),
      title: _buildAppBarTitle(context),
    );
  }

  Text _buildAppBarTitle(BuildContext context) {
    String text;
    switch (message.chatMessageType) {
      case ChatMessageType.special:
        text = S.of(context).chat_message_title_simple;
        break;
      case ChatMessageType.regular:
        var regularMessage = message as RegularMessage;
        var fromNick = regularMessage.fromNick;

        if (fromNick != null) {
          text = S.of(context).chat_message_title_from(fromNick);
        } else {
          text = S.of(context).chat_message_title_simple;
        }
        break;
    }

    return Text(text);
  }

  Widget _buildBody(BuildContext context) {
    var channelBloc = ChannelBlocsBloc.of(context).getChannelBloc(channel);
    return SafeArea(
      child: Provider<ChannelBloc>.value(
        value: channelBloc,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: buildMessageWidget(
              message: message,
              messageInListState: notInSearchState,
              messageWidgetType: MessageWidgetType.raw,
              enableMessageActions: false,
            ),
          ),
        ),
      ),
    );
  }
}
