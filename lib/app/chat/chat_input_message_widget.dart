import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_upload_helper.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_upload_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_upload_file_picker.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_type_ahead_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class NetworkChannelNewMessageWidget extends StatefulWidget {
  NetworkChannelNewMessageWidget();

  @override
  State<StatefulWidget> createState() => NetworkChannelNewMessageState();
}

class NetworkChannelNewMessageState
    extends State<NetworkChannelNewMessageWidget> {
  @override
  Widget build(BuildContext context) {
    var hintStr = AppLocalizations.of(context).tr("chat.enter_message.hint");

    var inputMessageSkinBloc = Provider.of<ChatInputMessageSkinBloc>(context);

    var channelBloc = NetworkChannelBloc.of(context);
    ChatInputMessageBloc inputMessageBloc = channelBloc.inputMessageBloc;
    var appSkinTheme = AppSkinBloc.of(context).appSkinTheme;
    var popupBackgroundColor = appSkinTheme.backgroundColor;

    var children = <Widget>[
      Flexible(
          child: Container(
//              decoration: BoxDecoration(border: Border.all(color: inputMessageSkinBloc.inputMessageCursorColor)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: createPlatformTypeAhead(
            context,
            keepSuggestionsOnSuggestionSelected: true,
            direction: AxisDirection.up,
            noItemsFoundBuilder: (_) => SizedBox.shrink(),
            suggestionsCallback: (pattern) async {
              var suggestions = await inputMessageBloc
                  .calculateAutoCompleteSuggestions(pattern);
              return suggestions;
            },
            itemBuilder: (context, suggestion) {
              return Container(
                decoration: BoxDecoration(color: popupBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(suggestion),
                ),
              );
            },
            onSuggestionSelected: (suggestion) {
              inputMessageBloc.onAutoCompleteSelected(suggestion);
            },
            android: () {
              return AndroidTypeAheadData(
                  textFieldConfiguration: TextFieldConfiguration(
                      autofocus: false,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        inputMessageBloc.sendMessage();
                      },
                      controller: inputMessageBloc.messageController,
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontStyle: FontStyle.italic),
                      decoration: InputDecoration(
                          hintText: hintStr,
                          hintStyle:
                              inputMessageSkinBloc.inputMessageHintTextStyle)));
            },
            ios: () {
              return CupertinoTypeAheadData(
                  textFieldConfiguration: CupertinoTextFieldConfiguration(
                      autofocus: false,
                      controller: inputMessageBloc.messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        inputMessageBloc.sendMessage();
                      },
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontStyle: FontStyle.italic,
                          color: appSkinTheme.textColor),
                      placeholder: hintStr));
            },
          ),
        ),
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
          icon: Icon(Icons.message),
          onPressed: () {
            inputMessageBloc.sendMessage();
          }),
    ];

    ChatUploadBloc chatUploadBloc = Provider.of<ChatUploadBloc>(context);
    if (chatUploadBloc.isUploadSupported) {
      children.insert(
          0,
          PlatformIconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () async {
                pickFileForUpload().then((pickedFile) async {
                  if (pickedFile != null) {
                    try {
                      await doAsyncOperationWithDialog(context, () async {
                        var uploadRequestResult =
                            await chatUploadBloc.uploadFile(pickedFile);
                        var remoteURL = uploadRequestResult.result;

                        if (remoteURL != null) {
                          inputMessageBloc.appendText(remoteURL);
                        }
                      });
                    } on ServerAuthUploadException {
                      showPlatformDialog(
                          context: context,
                          builder: (_) => PlatformAlertDialog(
                              title: Text("Server auth error")));
                    } on FileSizeUploadException {
                      showPlatformDialog(
                          context: context,
                          builder: (_) => PlatformAlertDialog(
                              title: Text("File size error")));
                    } on HttpUploadException {
                      showPlatformDialog(
                          context: context,
                          builder: (_) => PlatformAlertDialog(
                              title: Text("Http error")));
                    }
                  }
                });
//            inputMessageBloc.sendMessage();
              }));
    }
    return Container(
      decoration: BoxDecoration(
          color: inputMessageSkinBloc.inputMessageBackgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: children,
        ),
      ),
    );
  }
}
