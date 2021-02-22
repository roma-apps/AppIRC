import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/upload/chat_upload_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/lounge/upload/lounge_upload_file_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_type_ahead_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
        ),
      ),
      _buildSendButton(context),
    ];

    var chatUploadBloc = Provider.of<ChatUploadBloc>(context);
    if (chatUploadBloc.isUploadSupported) {
      children.insert(
        0,
        _buildUploadButton(
          context,
          chatUploadBloc,
        ),
      );
    }

    return _buildContainer(context, children);
  }

  Container _buildContainer(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: IAppIrcUiColorTheme.of(context).primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInputMessageField(BuildContext context) {
    var channelBloc = ChannelBloc.of(context);
    ChatInputMessageBloc inputMessageBloc = channelBloc.inputMessageBloc;

    var hintText = S.of(context).chat_new_message_field_enter_message_hint;

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

        var hintStyle = IAppIrcUiTextTheme.of(context).mediumGrey;
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
              decoration: BoxDecoration(
                color: IAppIrcUiColorTheme.of(context).offWhite,
              ),
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
                style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: hintStyle,
                ),
              ),
            );
          },
          ios: () {
            return CupertinoTypeAheadData(
              textFieldConfiguration: CupertinoTextFieldConfiguration(
                autofocus: false,
                controller: inputMessageBloc.messageController,
                textInputAction: inputAction,
                onSubmitted: submitted,
                focusNode: inputMessageBloc.focusNode,
                style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
                placeholder: hintText,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    ChatUploadBloc chatUploadBloc,
  ) {
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
      },
    );
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
      },
    );
  }

  List<PlatformAwarePopupMenuAction> _buildAttachMenuItems(
    BuildContext context,
    ChatUploadBloc chatUploadBloc,
    ChatInputMessageBloc inputMessageBloc,
  ) =>
      <PlatformAwarePopupMenuAction>[
        PlatformAwarePopupMenuAction(
          text: S.of(context).chat_new_message_attach_action_file,
          iconData: Icons.insert_drive_file,
          actionCallback: (PlatformAwarePopupMenuAction action) {
            pickAndUploadFile(
                FileType.any, context, chatUploadBloc, inputMessageBloc);
          },
        ),
        PlatformAwarePopupMenuAction(
          text: S.of(context).chat_new_message_attach_action_audio,
          iconData: Icons.audiotrack,
          actionCallback: (PlatformAwarePopupMenuAction action) {
            pickAndUploadFile(
                FileType.audio, context, chatUploadBloc, inputMessageBloc);
          },
        ),
        PlatformAwarePopupMenuAction(
          text: S.of(context).chat_new_message_attach_action_image,
          iconData: Icons.image,
          actionCallback: (PlatformAwarePopupMenuAction action) {
            pickAndUploadFile(
                FileType.image, context, chatUploadBloc, inputMessageBloc);
          },
        ),
        PlatformAwarePopupMenuAction(
          text: S.of(context).chat_new_message_attach_action_camera,
          iconData: Icons.camera_alt,
          actionCallback: (PlatformAwarePopupMenuAction action) async {
            var pickedPhotoFile = await ImagePicker().getImage(
              source: ImageSource.camera,
            );
            if (pickedPhotoFile?.path != null) {
              await _uploadFile(
                context,
                chatUploadBloc,
                File(pickedPhotoFile.path),
                inputMessageBloc,
              );
            }
          },
        ),
        PlatformAwarePopupMenuAction(
          text: S.of(context).chat_new_message_attach_action_video,
          iconData: Icons.video_library,
          actionCallback: (PlatformAwarePopupMenuAction action) {
            pickAndUploadFile(
              FileType.video,
              context,
              chatUploadBloc,
              inputMessageBloc,
            );
          },
        ),
      ];

  Future pickAndUploadFile(
      FileType fileType,
      BuildContext context,
      ChatUploadBloc chatUploadBloc,
      ChatInputMessageBloc inputMessageBloc) async {
    await FilePicker.platform.pickFiles().then((result) {
      if (result != null) {
        try {
          File pickedFile = File(result.files.single.path);
          _uploadFile(
            context,
            chatUploadBloc,
            pickedFile,
            inputMessageBloc,
          );
        } catch (e) {
          showPlatformAlertDialog(
            context: context,
            title: Text(
              S.of(context).chat_new_message_attach_error_title,
            ),
            content: Text(
              S.of(context).chat_new_message_attach_error_cant_access_file,
            ),
          );
        }
      } else {
        // User canceled the picker
      }
    });
  }

  Future _uploadFile(
    BuildContext context,
    ChatUploadBloc chatUploadBloc,
    File pickedFile,
    ChatInputMessageBloc inputMessageBloc,
  ) async {
    try {
      var asyncDialogResult = await doAsyncOperationWithDialog(
        context: context,
        asyncCode: () async {
          var uploadRequestResult = await chatUploadBloc.uploadFile(pickedFile);

          return uploadRequestResult;
        },
        cancelable: true,
      );

      if (asyncDialogResult.success) {
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
          S.of(context).chat_new_message_attach_error_title,
        ),
        content: Text(
          S.of(context).chat_new_message_attach_error_server_auth,
        ),
      );
    } on FileSizeExceededLoungeUploadException catch (e) {
      showPlatformAlertDialog(
        context: context,
        title: Text(
          S.of(context).chat_new_message_attach_error_title,
        ),
        content: Text(
          S.of(context).chat_new_message_attach_error_file_size(
                e.maximumPossibleUploadFileSizeInBytes.toString(),
                e.actualSizeInBytes.toString(),
              ),
        ),
      );
    } on InvalidHttpResponseCodeLoungeUploadException catch (e) {
      showPlatformAlertDialog(
        context: context,
        title: Text(
          S.of(context).chat_new_message_attach_error_title,
        ),
        content: Text(
          S.of(context).chat_new_message_attach_error_http_code(
                e.responseCode.toString(),
              ),
        ),
      );
    } on InvalidHttpResponseBodyLoungeUploadException catch (e) {
      showPlatformAlertDialog(
        context: context,
        title: Text(
          S.of(context).chat_new_message_attach_error_title,
        ),
        content: Text(
          S.of(context).chat_new_message_attach_error_http_body(
                e.responseBody,
              ),
        ),
      );
    } on TimeoutHttpLoungeUploadException {
      showPlatformAlertDialog(
        context: context,
        title: Text(
          S.of(context).chat_new_message_attach_error_title,
        ),
        content: Text(
          S.of(context).chat_new_message_attach_error_http_timeout,
        ),
      );
    }
  }
}
