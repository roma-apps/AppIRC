import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_widget.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_model.dart';
import 'package:flutter_appirc/app/message/list/messages_list_widget.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_text_field.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "NetworkChannelWidget", enabled: true);

class NetworkChannelWidget extends StatefulWidget {

  NetworkChannelWidget();

  @override
  _NetworkChannelWidgetState createState() =>
      _NetworkChannelWidgetState();
}

class _NetworkChannelWidgetState extends State<NetworkChannelWidget> {
  TextEditingController searchController;

  _NetworkChannelWidgetState();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    MessagesRegularSkinBloc skinBloc = Provider.of(context);

    ChatMessagesListBloc chatListMessagesBloc = Provider.of(context);
    var channelBloc = NetworkChannelBloc.of(context);

    _logger.d(() => "build for ${channelBloc.channel.name} "
    "messages ${chatListMessagesBloc.messagesLoaderBloc.messages
        .length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
          stream: channelBloc.messagesBloc.searchEnabledStream,
          initialData: channelBloc.messagesBloc.searchEnabled,
          builder: (context, snapshot) {
            var enabled = snapshot.data;

            if (enabled) {
              var disabledColor = Colors.grey;
              return Container(
                decoration:
                    BoxDecoration(color: skinBloc.searchBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      StreamBuilder<ChatMessagesListSearchState>(
                          stream: chatListMessagesBloc.searchStateStream,
                          initialData: chatListMessagesBloc.searchState,
                          builder: (context, snapshot) {
                            var searchState = snapshot.data;

                            String labelText;
                            if (searchState.searchTerm?.isNotEmpty == true) {
                              if (searchState.foundMessages.isEmpty) {
                                labelText = AppLocalizations.of(context)
                                    .tr("chat.messages_list.search.field.filter"
                                    ".label.nothing_found");
                              } else {

                                labelText = AppLocalizations.of(context)
                                    .tr("chat.messages_list.search.field.filter"
                                    ".label"
                                    ".found",
                                    args: [
                                      searchState
                                          .selectedFoundMessagePosition.toString(),
                                      searchState
                                          .maxPossibleSelectedFoundPosition
                                          .toString()
                                    ]);
                              }
                            } else {
                              // empty label if search not started
                            }

                            return Flexible(
                              child: buildPlatformTextField(
                                  context,
                                  channelBloc.messagesBloc.searchFieldBloc,
                                  searchController,
                                  labelText,
                                  AppLocalizations.of(context)
                                      .tr("chat.messages_list.search.field"
                                      ".filter"
                                      ".hint")),
                            );
                          }),
                      StreamBuilder<bool>(
                        stream: chatListMessagesBloc.searchPreviousEnabledStream,
                        initialData: chatListMessagesBloc.searchPreviousEnabled,
                        builder: (context, snapshot) {
                          var enabled = snapshot.data;
                          return PlatformIconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_up,
//                        color: networkListSkinBloc
//                            .getNetworkItemIconColor(isChannelActive)
                            ),
                            onPressed:
                            enabled? () {
                                    chatListMessagesBloc.goToPreviousFoundMessage();
                                  }
                                : null,
                            disabledColor: disabledColor,
                          );
                        }
                      ),
                      StreamBuilder<bool>(
                          stream: chatListMessagesBloc.searchNextEnabledStream,
                          initialData: chatListMessagesBloc.searchNextEnabled,
                        builder: (context, snapshot) {
                          var enabled = snapshot.data;
                          return PlatformIconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
//                        color: networkListSkinBloc
//                            .getNetworkItemIconColor(isChannelActive)
                            ),
                            onPressed: enabled
                                ? () {
                                    chatListMessagesBloc.goToNextFoundMessage();
                                  }
                                : null,
                            disabledColor: disabledColor,
                          );
                        }
                      ),
                      PlatformIconButton(
                        icon: Icon(
                          Icons.cancel,
//                        color: networkListSkinBloc
//                            .getNetworkItemIconColor(isChannelActive)
                        ),
                        onPressed: () {
                          channelBloc.messagesBloc.onNeedHideSearch();
                        },
                        disabledColor: disabledColor,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        Expanded(child: NetworkChannelMessagesListWidget()),
        NetworkChannelNewMessageWidget()
      ],
    );
  }
}
