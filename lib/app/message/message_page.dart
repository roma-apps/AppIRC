import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MessagePage extends StatelessWidget {
  final Channel channel;
  final ChatMessage message;

  MessagePage(this.channel, this.message);

  @override
  Widget build(BuildContext context) {
    return buildPlatformScaffold(context,
        appBar: _buildAppBar(context), body: _buildBody(context));
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
        text = AppLocalizations.of(context).tr("chat.message.title.simple");
        break;
      case ChatMessageType.regular:
        var regularMessage = message as RegularMessage;
        var fromNick = regularMessage.fromNick;

        if(fromNick != null) {

        text = AppLocalizations.of(context)
            .tr("chat.message.title.from", args: [fromNick]);
        } else {

          text = AppLocalizations.of(context).tr("chat.message.title.simple");
        }
        break;
    }

    return Text(text);
  }

  Widget _buildBody(BuildContext context) {
    var channelBloc = ChannelBlocsBloc.of(context).getChannelBloc(channel);
    return SafeArea(
      child: Provider(
          providable: ChannelBlocProvider(channelBloc),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildMessageWidget(
                message: message,
                messageInListState: notInSearchState,
                messageWidgetType: MessageWidgetType.raw,
                enableMessageActions: false),
          )),
    );
  }
}
