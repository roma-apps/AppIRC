import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/upload/chat_upload_bloc.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/lounge/upload/lounge_upload_file_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_type_ahead_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/popup_menu_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';

class ChannelNewMessageWidget extends StatefulWidget {
  ChannelNewMessageWidget();

  @override
  State<StatefulWidget> createState() => ChannelNewMessageState();
}

class ChannelNewMessageState extends State<ChannelNewMessageWidget> {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Flexible(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _buildInputMessageField(context),
        ),
      )),
      _buildSendButton(context),
    ];

    ChatUploadBloc chatUploadBloc = Provider.of<ChatUploadBloc>(context);
    if (chatUploadBloc.isUploadSupported) {
      children.insert(0, _buildUploadButton(context, chatUploadBloc));
    }

    return _buildContainer(context, children);
  }

  Container _buildContainer(BuildContext context, List<Widget> children) {
    var inputMessageSkinBloc = Provider.of<ChatInputMessageSkinBloc>(context);
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

  Widget _buildInputMessageField(BuildContext context) {
    var inputMessageSkinBloc = Provider.of<ChatInputMessageSkinBloc>(context);

    var channelBloc = ChannelBloc.of(context);
    ChatInputMessageBloc inputMessageBloc = channelBloc.inputMessageBloc;

    PopupMenuSkinBloc popupMenuSkinBloc = Provider.of(context);

    var popupBackgroundColor = popupMenuSkinBloc.backgroundColor;
    var hintText = tr("chat.new_message.field.enter_message.hint");

    ChatConnectionBloc chatConnectionBloc = Provider.of(context);

    return StreamBuilder<bool>(
        stream: chatConnectionBloc.isConnectedStream,
        initialData: chatConnectionBloc.isConnected,
        builder: (context, snapshot) {
          var connected = snapshot.data;

          TextInputAction inputAction;
          if (connected) {
            inputAction = TextInputAction.send;
          } else {
            inputAction = TextInputAction.done;
          }
          var submitted;
          if (connected) {
            submitted = (_) {
              inputMessageBloc.sendMessage();
            };
          }
//          return TextField();
          return createPlatformTypeAhead(
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
                      textInputAction: inputAction,
                      onSubmitted: submitted,
                      focusNode: inputMessageBloc.focusNode,
                      controller: inputMessageBloc.messageController,
                      style: inputMessageSkinBloc.inputMessageHintTextStyle,
                      decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle:
                              inputMessageSkinBloc.inputMessageHintTextStyle)));
            },
            ios: () {
              return CupertinoTypeAheadData(
                  textFieldConfiguration: CupertinoTextFieldConfiguration(
                      autofocus: false,
                      controller: inputMessageBloc.messageController,
                      textInputAction: inputAction,
                      onSubmitted: submitted,
                      focusNode: inputMessageBloc.focusNode,
                      style: inputMessageSkinBloc.inputMessageHintTextStyle,
                      placeholder: hintText));
            },
          );
        });
  }

  Widget _buildUploadButton(
      BuildContext context, ChatUploadBloc chatUploadBloc) {
    ChatConnectionBloc chatConnectionBloc = Provider.of(context);
    var channelBloc = ChannelBloc.of(context);

    return StreamBuilder<bool>(
        stream: chatConnectionBloc.isConnectedStream,
        initialData: chatConnectionBloc.isConnected,
        builder: (context, snapshot) {
          var connected = snapshot.data;

          return createPlatformPopupMenuButton(context,
              child: Icon(Icons.attach_file),
              actions: _buildAttachMenuItems(
                  context, chatUploadBloc, channelBloc.inputMessageBloc),
              enabled: connected);
        });
  }

  Widget _buildSendButton(BuildContext context) {
    ChatConnectionBloc chatConnectionBloc = Provider.of(context);

    return StreamBuilder<bool>(
        stream: chatConnectionBloc.isConnectedStream,
        initialData: chatConnectionBloc.isConnected,
        builder: (context, snapshot) {
          var connected = snapshot.data;
          var pressed;
          if (connected) {
            pressed = () {
              ChatInputMessageBloc inputMessageBloc =
                  ChannelBloc.of(context).inputMessageBloc;
              inputMessageBloc.sendMessage();
            };
          }
          return PlatformIconButton(
              icon: Icon(Icons.message), onPressed: pressed);
        });
  }

  _buildAttachMenuItems(BuildContext context, ChatUploadBloc chatUploadBloc,
      ChatInputMessageBloc inputMessageBloc) {
    return <PlatformAwarePopupMenuAction>[
      PlatformAwarePopupMenuAction(
        text: tr("chat.new_message.attach.action.file"),
        iconData: Icons.insert_drive_file,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.any, context, chatUploadBloc, inputMessageBloc);
        },
      ),
      PlatformAwarePopupMenuAction(
        text: tr("chat.new_message.attach.action.audio"),
        iconData: Icons.audiotrack,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.audio, context, chatUploadBloc, inputMessageBloc);
        },
      ),
      PlatformAwarePopupMenuAction(
        text: tr("chat.new_message.attach.action.image"),
        iconData: Icons.image,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.image, context, chatUploadBloc, inputMessageBloc);
        },
      ),
      PlatformAwarePopupMenuAction(
        text: tr("chat.new_message.attach.action.camera"),
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
        text: tr("chat.new_message.attach.action.video"),
        iconData: Icons.video_library,
        actionCallback: (PlatformAwarePopupMenuAction action) {
          pickAndUploadFile(
              FileType.video, context, chatUploadBloc, inputMessageBloc);
        },
      ),
    ];
  }

  Future pickAndUploadFile(
      FileType fileType,
      BuildContext context,
      ChatUploadBloc chatUploadBloc,
      ChatInputMessageBloc inputMessageBloc) async {
    FilePicker.platform.pickFiles().then((result) {
      if (result != null) {
        try {
          File pickedFile = File(result.files.single.path);
          _uploadFile(context, chatUploadBloc, pickedFile, inputMessageBloc);
        } catch (e) {
          showPlatformAlertDialog(
              context: context,
              title: Text(tr("chat.new_message.attach"
                  ".error.title")),
              content: Text(tr("chat.new_message.attach"
                  ".error.cant_access_file")));
        }
      } else {
        // User canceled the picker
      }
    });
  }

  Future _uploadFile(BuildContext context, ChatUploadBloc chatUploadBloc,
      File pickedFile, ChatInputMessageBloc inputMessageBloc) async {
    try {
      var asyncDialogResult = await doAsyncOperationWithDialog(
          context: context,
          asyncCode: () async {
            var uploadRequestResult =
                await chatUploadBloc.uploadFile(pickedFile);

            return uploadRequestResult;
          },
          cancellationValue: null,
          isDismissible: true);

      if (asyncDialogResult.isNotCanceled) {
        var uploadRequestResult = asyncDialogResult.result;
        var remoteURL = uploadRequestResult.result;

        if (remoteURL != null) {
          inputMessageBloc.appendText(remoteURL);
        }
      }
    } on ServerAuthInvalidLoungeUploadException {
      showPlatformAlertDialog(
          context: context,
          title: Text(
            tr("chat.new_message.attach.error.title"),
          ),
          content: Text(tr("chat.new_message.attach.error.server_auth")));
    } on FileSizeExceededLoungeUploadException catch (e) {
      showPlatformAlertDialog(
          context: context,
          title: Text(
            tr("chat.new_message.attach.error.title"),
          ),
          content: Text(tr("chat.new_message.attach.error.file_size", args: [
            e.maximumPossibleUploadFileSizeInBytes.toString(),
            e.actualSizeInBytes.toString()
          ])));
    } on InvalidHttpResponseCodeLoungeUploadException catch (e) {
      showPlatformAlertDialog(
          context: context,
          title: Text(
            tr("chat.new_message.attach.error.title"),
          ),
          content: Text(tr("chat.new_message.attach.error.http_code",
              args: [e.responseCode.toString()])));
    } on InvalidHttpResponseBodyLoungeUploadException catch (e) {
      showPlatformAlertDialog(
          context: context,
          title: Text(
            tr("chat.new_message.attach.error.title"),
          ),
          content: Text(tr("chat.new_message.attach.error.http_body",
              args: [e.responseBody])));
    } on TimeoutHttpLoungeUploadException {
      showPlatformAlertDialog(
          context: context,
          title: Text(
            tr("chat.new_message.attach.error.title"),
          ),
          content: Text(tr("chat.new_message.attach.error.http_timeout")));
    }
  }
}
