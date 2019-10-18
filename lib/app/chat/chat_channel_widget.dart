import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_widget.dart';
import 'package:flutter_appirc/app/chat/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/message/messages_list_widget.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_text_field.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef VisibleAreaCallback(int minVisibleIndex, int maxVisibleIndex);

class NetworkChannelWidget extends StatefulWidget {
  final VisibleAreaCallback visibleAreaCallback;

  NetworkChannelWidget(this.visibleAreaCallback);

  @override
  _NetworkChannelWidgetState createState() =>
      _NetworkChannelWidgetState(visibleAreaCallback);
}

class _NetworkChannelWidgetState extends State<NetworkChannelWidget> {
  final VisibleAreaCallback visibleAreaCallback;

  TextEditingController searchController;

  _NetworkChannelWidgetState(this.visibleAreaCallback) {
//    streamSubscription = chatMessagesListBloc.forcedMessagesListIndexStream
//        .listen((newForcedIndex) {
//      if (newForcedIndex != null &&
//          newForcedIndex > 0) {
//        scrollController.jumpTo(
//            index: newForcedIndex);
//      }
//    });
  }

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
                      StreamBuilder<MessagesSearchState>(
                          stream: chatListMessagesBloc.foundMessagesStream,
                          initialData: chatListMessagesBloc.foundMessages,
                          builder: (context, snapshot) {
                            var messagesSearchState = snapshot.data;

                            String labelText;
                            if (messagesSearchState != null) {
                              if (messagesSearchState.messages.isEmpty) {
                                labelText = AppLocalizations.of(context)
                                    .tr("chat.messages.search.label_empty");
                              } else {
                                var currentPosition = messagesSearchState.currentIndex + 1;
                                var maxPosition = messagesSearchState
                                    .messages.length;
                                labelText = AppLocalizations.of(context).tr(
                                    "chat.messages.search.label_not_empty",
                                    args: [
                                      currentPosition.toString(),
                                      maxPosition.toString()
                                    ]);
                              }
                            }

                            return Flexible(
                              child: buildPlatformTextField(
                                  context,
                                  channelBloc.messagesBloc.searchFieldBloc,
                                  searchController,
                                  labelText,
                                  AppLocalizations.of(context)
                                      .tr("chat.messages.search.hint")),
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
        Expanded(child: buildListWidget(context)),
        NetworkChannelNewMessageWidget()
      ],
    );
  }

  NetworkChannelMessagesListWidget buildListWidget(BuildContext context) {
    return NetworkChannelMessagesListWidget(visibleAreaCallback);
  }
}
