import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/message/highlight/message_link_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_search_highlight.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/body/channel_info/message_special_channel_info_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';

class ChannelInfoSpecialMessageBodyWidget
    extends SpecialMessageBodyWidget<ChannelInfoSpecialMessageBody> {
  ChannelInfoSpecialMessageBodyWidget(
      {@required SpecialMessage message,
      @required ChannelInfoSpecialMessageBody body,
      @required bool inSearchResults,
      @required MessageWidgetType messageWidgetType})
      : super(
            message: message,
            body: body,
            inSearchResults: inSearchResults,
            messageWidgetType: messageWidgetType);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildChannelInfoName(context: context, channelName: body.name),
              _buildChannelInfoUsersCount(
                  context: context, usersCount: body.usersCount),
            ],
          ),
          _buildChannelInfoTopic(
              context: context,
              topic: body.topic,
              linksInText: message.linksInText),
        ],
      ),
    );
  }

  @override
  String getBodyRawText(BuildContext context) {
    return "${body.name}(${body.usersCount}): ${body.topic}";
  }

  Widget _buildChannelInfoName(
      {@required BuildContext context, @required String channelName}) {
    var password = ""; // channels list contains only channels without password
    MessageSkinBloc messagesSkinBloc = Provider.of(context);
    return GestureDetector(
        onTap: () {
          NetworkBloc networkBloc = NetworkBloc.of(context);

          networkBloc.joinChannel(
              ChannelPreferences.name(name: channelName, password: password));
        },
        child: Text(
          channelName,
          style: messagesSkinBloc.linkTextStyle,
        ));
  }

  Widget _buildChannelInfoTopic(
      {@required BuildContext context,
      @required String topic,
      @required List<String> linksInText}) {
    MessageSkinBloc messageSkinBloc = Provider.of(context);

    var spanBuilders = <SpanBuilder>[];
    spanBuilders.addAll(linksInText
        .map((link) => buildLinkHighlighter(context: context, link: link)));
    if (inSearchResults) {
      MessageListBloc messageListBloc = Provider.of(context);
      var searchTerm = messageListBloc.searchTerm;
      spanBuilders.add(
          buildSearchSpanHighlighter(context: context, searchTerm: searchTerm));
    }
    var spans = createSpans(
        context: context,
        text: topic,
        defaultTextStyle: messageSkinBloc.messageBodyTextStyle,
        spanBuilders: spanBuilders);
    return Padding(
        padding: const EdgeInsets.all(8.0), child: buildMessageRichText(spans));
  }

  Widget _buildChannelInfoUsersCount(
      {@required BuildContext context, @required int usersCount}) {
    return Text(AppLocalizations.of(context).tr(
        "chat"
        ".message.special.channels_list.users",
        args: [usersCount.toString()]));
  }
}
