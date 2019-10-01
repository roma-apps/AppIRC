import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class NetworkChannelNewMessageWidget extends StatefulWidget {

  NetworkChannelNewMessageWidget();

  @override
  State<StatefulWidget> createState() =>
      NetworkChannelNewMessageState();
}

class NetworkChannelNewMessageState
    extends State<NetworkChannelNewMessageWidget> {

  @override
  Widget build(BuildContext context) {
    var hintStr = AppLocalizations.of(context).tr("chat.enter_message.hint");

    var inputMessageSkinBloc = Provider.of<ChatInputMessageSkinBloc>(context);

    var channelBloc = Provider.of<NetworkChannelBloc>(context);
    ChatInputMessageBloc inputMessageBloc = channelBloc.inputMessageBloc;


    return Container(
      decoration: BoxDecoration(
          color: inputMessageSkinBloc.inputMessageBackgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: <Widget>[
            Flexible(
                child: TypeAheadField(
              keepSuggestionsOnSuggestionSelected: true,
              direction: AxisDirection.up,
              noItemsFoundBuilder: (_) => SizedBox.shrink(),
              textFieldConfiguration: TextFieldConfiguration(
                  autofocus: false,
                  controller: inputMessageBloc.messageController,
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontStyle: FontStyle.italic),
                  decoration: InputDecoration(border: OutlineInputBorder())),
              suggestionsCallback: (pattern) async {
                var suggestions = await inputMessageBloc
                    .calculateAutoCompleteSuggestions(pattern);
                return suggestions;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                inputMessageBloc.onAutoCompleteSelected(suggestion);
              },
            )),
//            Flexible(
//                child: PlatformTextField(
//              android: (_) {
//                return MaterialTextFieldData(
//                    decoration: InputDecoration(
//                        hintText: hintStr,
//                        hintStyle:
//                            inputMessageSkinBloc.inputMessageHintTextStyle));
//              },
//              ios: (_) => CupertinoTextFieldData(placeholder: hintStr),
//              cursorColor: inputMessageSkinBloc.inputMessageCursorColor,
//              style: inputMessageSkinBloc.inputMessageTextStyle,
//              controller: inputMessageBloc.messageController,
//              onSubmitted: (term) {
//                inputMessageBloc.sendMessage();
//              },
//            )),
            PlatformIconButton(
                color: inputMessageSkinBloc.iconSendMessageColor,
                icon: new Icon(Icons.message),
                onPressed: () {
                  inputMessageBloc.sendMessage();
                }),
          ],
        ),
      ),
    );
  }
}
