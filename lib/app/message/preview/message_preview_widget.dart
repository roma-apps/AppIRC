import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/preview/message_audio_preview_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_error_preview_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_image_preview_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_link_preview_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_loading_preview_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_skin_bloc.dart';
import 'package:flutter_appirc/app/message/preview/message_video_preview_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

MyLogger _logger =
    MyLogger(logTag: "message_preview_model.dart", enabled: true);

Widget buildPreview(
    BuildContext context, RegularMessage message, MessagePreview preview) {
  _logger.d((() => " build preview for $preview"));

  MessagePreviewSkinBloc skinBloc = Provider.of(context);

  TextSkinBloc textSkinBloc = Provider.of(context);

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Container(
      decoration:
          BoxDecoration(border: Border.all(color: skinBloc.previewBorderColor)),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(tr("chat.message.preview.title"), style: textSkinBloc
                    .defaultTextStyle),
              ),
              PlatformIconButton(
                  icon: Icon(
                      preview.shown ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    ChannelBloc channelBloc = ChannelBloc.of(context);
                    channelBloc.togglePreview(message, preview);
                  })
            ],
          ),
          preview.shown
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: _buildPreviewBody(context, preview),
                )
              : SizedBox.shrink(),
        ],
      ),
    ),
  );
}

Widget _buildPreviewBody(BuildContext context, MessagePreview preview) {
  var previewBody;
  switch (preview.type) {
    case MessagePreviewType.link:
      previewBody = buildMessageLinkPreview(context: context, preview: preview);

      break;
    case MessagePreviewType.image:
      previewBody =
          buildMessageImagePreview(context: context, preview: preview);
      break;
    case MessagePreviewType.loading:
      previewBody =
          buildMessageLoadingPreview(context: context, preview: preview);
      break;
    case MessagePreviewType.audio:
      previewBody =
          buildMessageAudioPreview(context: context, preview: preview);
      break;
    case MessagePreviewType.video:
      previewBody =
          buildMessageVideoPreview(context: context, preview: preview);
      break;
    case MessagePreviewType.error:
      previewBody =
          buildMessageErrorPreview(context: context, preview: preview);
      break;
  }

  return previewBody ?? SizedBox.shrink();
}
