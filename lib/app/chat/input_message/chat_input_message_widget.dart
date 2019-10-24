import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/upload/chat_upload_bloc.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_type_ahead_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_appirc/lounge/lounge_upload_file_helper.dart';

class NetworkChannelNewMessageWidget extends StatefulWidget {
  NetworkChannelNewMessageWidget();

  @override
  State<StatefulWidget> createState() => NetworkChannelNewMessageState();
}

class NetworkChannelNewMessageState
    extends State<NetworkChannelNewMessageWidget> {
  @override
  Widget build(BuildContext context) {
    var hintStr = AppLocalizations.of(context).tr("chat.new_message.field"
        ".enter_message"
        ".hint");

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
          createPlatformPopupMenuButton(context,
              child: Icon(Icons.attach_file),
              actions: _buildAttachMenuItems(
                  context, chatUploadBloc, inputMessageBloc)));
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

  _buildAttachMenuItems(BuildContext context, ChatUploadBloc chatUploadBloc,
      ChatInputMessageBloc inputMessageBloc) {
    var appLocalizations = AppLocalizations.of(context);
    return <PlatformAwarePopupMenuAction>[
      PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.new_message.attach.action.file"),
        iconData: Icons.insert_drive_file,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.ANY, context, chatUploadBloc, inputMessageBloc);
        },
      ),
      PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.new_message.attach.action.audio"),
        iconData: Icons.audiotrack,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.AUDIO, context, chatUploadBloc, inputMessageBloc);
        },
      ),
      PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.new_message.attach.action.image"),
        iconData: Icons.image,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.IMAGE, context, chatUploadBloc, inputMessageBloc);
        },
      ),
      PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.new_message.attach.action.camera"),
        iconData: Icons.camera_alt,
        actionCallback: (PlatformAwarePopupMenuAction action) async {
          var pickedPhoto =
              await ImagePicker.pickImage(source: ImageSource.camera);
          if (pickedPhoto != null) {
            _uploadFile(context, chatUploadBloc, pickedPhoto, inputMessageBloc);
          }
        },
      ),
      PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.new_message.attach.action.video"),
        iconData: Icons.video_library,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.VIDEO, context, chatUploadBloc, inputMessageBloc);
        },
      ),
    ];
  }

  Future pickAndUploadFile(
      FileType fileType,
      BuildContext context,
      ChatUploadBloc chatUploadBloc,
      ChatInputMessageBloc inputMessageBloc) async {
    FilePicker.getFile(type: fileType).then((pickedFile) async {
      if (pickedFile != null) {
        _uploadFile(context, chatUploadBloc, pickedFile, inputMessageBloc);
      } else {
        showPlatformDialog(
            context: context,
            builder: (_) => PlatformAlertDialog(
                title: Text(
                    AppLocalizations.of(context).tr("chat.new_message.attach"
                        ".error.cant_access_file"))));
      }
    });
  }

  Future _uploadFile(BuildContext context, ChatUploadBloc chatUploadBloc,
      File pickedFile, ChatInputMessageBloc inputMessageBloc) async {
    try {
      var asyncDialogResult =
          await doAsyncOperationWithDialog(context, asyncCode: () async {
        var uploadRequestResult = await chatUploadBloc.uploadFile(pickedFile);

        return uploadRequestResult;
      }, cancellationValue: null, isDismissible: true);

      if (asyncDialogResult.isNotCanceled) {
        var uploadRequestResult = asyncDialogResult.result;
        var remoteURL = uploadRequestResult.result;

        if (remoteURL != null) {
          inputMessageBloc.appendText(remoteURL);
        }
      }
    } on ServerAuthUploadException {
      showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
              title:
                  Text(AppLocalizations.of(context)
                      .tr("chat.new_message.attach.error.server_auth"))));
    } on FileSizeUploadException {
      showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(title: Text(AppLocalizations.of(context)
              .tr("chat.new_message.attach.error.file_size"))));
    } on HttpUploadException {
      showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(title: Text(AppLocalizations.of(context)
              .tr("chat.new_message.attach.error.transport_error"))));
    }
  }
}
