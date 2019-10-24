import 'package:chewie/chewie.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/preview/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_body_widget.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

var _logger = MyLogger(logTag: "messages_regular_widgets.dart", enabled: true);

var todayDateFormatter = new DateFormat().add_Hm();
var regularDateFormatter = new DateFormat().add_yMd().add_Hm();

//class NetworkChannelMessageWidget extends StatelessWidget {
//  final RegularMessage message;
//
//  NetworkChannelMessageWidget(this.message);
//

Widget buildRegularMessage(BuildContext context, RegularMessage message,
    bool isHighlightedBySearch, String searchTerm) {
  var channelBloc = NetworkChannelBloc.of(context);

  var body =
      _buildMessageBody(context, message, isHighlightedBySearch, searchTerm);

  var title = _buildMessageTitle(context, channelBloc, message);

  var subMessage = _buildTitleSubMessage(context, message);

  if (subMessage != null) {
    body = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[subMessage, body]);
  }

  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var color =
      messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

  return buildRegularMessageWidget(context, title, body, color);
}

Widget _buildMessageBody(BuildContext context, RegularMessage message,
    bool isHighlightedBySearch, String searchTerm) {
  var regularMessageType = message.regularMessageType;

  if (regularMessageType == RegularMessageType.AWAY ||
      regularMessageType == RegularMessageType.JOIN ||
      regularMessageType == RegularMessageType.TOPIC_SET_BY ||
      regularMessageType == RegularMessageType.MOTD ||
      regularMessageType == RegularMessageType.MODE_CHANNEL ||
      regularMessageType == RegularMessageType.BACK) {
    return SizedBox.shrink();
  }
  if (regularMessageType == RegularMessageType.MODE) {
    if (!isHaveLongText(message)) {
      return SizedBox.shrink();
    }
  }

  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var rows = <Widget>[
//      Text("${message.type}"),
  ];

  var params = message.params;

  if (params != null) {
    rows.add(Text("${params.join(", ")}",
        style: messagesSkin.regularMessageBodyTextStyle));
  }

  if (message.text != null) {
    var text = message.text;
    rows.add(buildRegularMessageBody(context, text, message.nicknames,
        message.linksInText, isHighlightedBySearch, searchTerm));
  }

  if (message.previews != null) {
    message.previews.forEach(
        (preview) => rows.add(buildPreview(context, message, preview)));
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rows,
  );
}

Widget _buildMessageTitle(BuildContext context, NetworkChannelBloc channelBloc,
    RegularMessage message) {
  var icon = _buildTitleIcon(context, message);

  var startPart;

  if (message.isHaveFromNick) {
    var messageTitleNick =
        _buildMessageTitleNick(context, channelBloc, message);
//    if (subMessage != null) {
//      startPart = Row(children: <Widget>[
//        messageTitleNick,
//        Padding(
//          padding: const EdgeInsets.symmetric(horizontal: 8.0),
//          child: subMessage,
//        )
//      ]);
//    } else {
    startPart = messageTitleNick;
//    }
  } else {
    startPart = SizedBox.shrink();
//    if (subMessage != null) {
//      startPart = subMessage;
//    }
  }
  // todo: rework

  var endPart;
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);
  var color =
      messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

  if (icon != null) {
    endPart = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildMessageTitleDate(context, message, color),
        icon,
      ],
    );
  } else {
    endPart = buildMessageTitleDate(context, message, color);
  }

  return buildMessageTitle(startPart, endPart);
}

Widget _buildMessageTitleNick(BuildContext context,
    NetworkChannelBloc channelBloc, RegularMessage message) {
  var nick = message.fromNick;

  var nickNamesBloc = Provider.of<ColoredNicknamesBloc>(context);
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);
  var child = Text(
    nick,
    style:
        messagesSkin.createNickTextStyle(nickNamesBloc.getColorForNick(nick)),
  );

  return buildUserNickWithPopupMenu(context, child, nick, channelBloc);
}

_buildTitleIcon(BuildContext context, RegularMessage message) {
  var iconData = _findTitleIconDataForMessage(message);
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var color =
      messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

  return buildMessageIcon(iconData, color);
}

Widget _buildTitleSubMessage(BuildContext context, RegularMessage message) {
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var regularMessageType = message.regularMessageType;
  var appLocalizations = AppLocalizations.of(context);
  String str;
  switch (regularMessageType) {
    case RegularMessageType.TOPIC_SET_BY:
      str = appLocalizations.tr("chat.message.regular.sub_message.topic_set_by");
      break;
    case RegularMessageType.TOPIC:
      str = appLocalizations.tr("chat.message.regular.sub_message.topic");
      break;
    case RegularMessageType.WHO_IS:
      str = appLocalizations.tr("chat.message.regular.sub_message.who_is");
      break;
    case RegularMessageType.UNHANDLED:
      str = null;
      break;
    case RegularMessageType.UNKNOWN:
      str = appLocalizations.tr("chat.message.regular.sub_message.unknown");
      break;
    case RegularMessageType.MESSAGE:
      str = null;
      break;
    case RegularMessageType.JOIN:
      str = appLocalizations.tr("chat.message.regular.sub_message.join");
      break;
    case RegularMessageType.MODE:
      if (isHaveLongText(message)) {
        str = appLocalizations.tr("chat.message.regular.sub_message.mode_long");
      } else {
        str = appLocalizations
            .tr("chat.message.regular.sub_message.mode_short", args: [message.text]);
      }

      break;
    case RegularMessageType.MOTD:
      str = appLocalizations.tr("chat.message.regular.sub_message.motd", args: [message.text]);
      break;
    case RegularMessageType.NOTICE:
      str = appLocalizations.tr("chat.message.regular.sub_message.notice");
      break;
    case RegularMessageType.ERROR:
      str = appLocalizations.tr("chat.message.regular.sub_message.error");
      break;
    case RegularMessageType.AWAY:
      str = appLocalizations.tr("chat.message.regular.sub_message.away");
      break;
    case RegularMessageType.BACK:
      str = appLocalizations.tr("chat.message.regular.sub_message.back");
      break;
    case RegularMessageType.MODE_CHANNEL:
      str = appLocalizations
          .tr("chat.message.regular.sub_message.channel_mode", args: [message.text]);
      break;
    case RegularMessageType.QUIT:
      str = appLocalizations.tr("chat.message.regular.sub_message.quit");
      break;
    case RegularMessageType.RAW:
      str = null;
      break;
    case RegularMessageType.PART:
      str = appLocalizations.tr("chat.message.regular.sub_message.part");
      break;
    case RegularMessageType.NICK:
      str =
          appLocalizations.tr("chat.message.regular.sub_message.nick", args: [message.newNick]);
      break;
    case RegularMessageType.CTCP_REQUEST:
      str = appLocalizations.tr("chat.message.regular.sub_message.ctcp_request");
      break;
  }

  if (str != null) {
    var color = messagesSkin.findTitleColorDataForMessage(regularMessageType);
    return Text(str, style: messagesSkin.createDateTextStyle(color));
  } else {
    return null;
  }
}

Widget buildPreview(
    BuildContext context, RegularMessage message, MessagePreview preview) {
  _logger.d((() => " build preview for $preview"));

  var previewBody;
  switch (preview.type) {
    case MessagePreviewType.LINK:
      previewBody = buildMessageLinkPreview(context, preview);

      break;
    case MessagePreviewType.IMAGE:
      previewBody = buildMessageImagePreview(context, preview);
      break;
    case MessagePreviewType.LOADING:
      previewBody = Text("Loading");
      break;
    case MessagePreviewType.AUDIO:
      previewBody = buildMessageAudioPreview(context, preview);
      break;
    case MessagePreviewType.VIDEO:
      previewBody = buildMessageVideoPreview(context, preview);
      break;
  }

  if (previewBody != null) {
    return Stack(children: <Widget>[
      preview.shown ? previewBody : SizedBox.shrink(),
      PlatformIconButton(
          icon: Icon(preview.shown ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            NetworkChannelBloc channelBloc = NetworkChannelBloc.of(context);
            channelBloc.togglePreview(message, preview);
          })
    ]);

//    return Row(children: <Widget>[
//      previewBody,  PlatformIconButton(
//        icon: Icon(preview.shown ? Icons.expand_less : Icons.expand_more),
//        onPressed: () {
//
//        },
//      )
//    ],);
  } else {
    return SizedBox.shrink();
  }
}

Widget buildMessageVideoPreview(BuildContext context, MessagePreview preview) =>
    MessageVideoPreviewWidget(preview.media);

Widget buildMessageAudioPreview(BuildContext context, MessagePreview preview) =>
    MessageAudioPreviewWidget(preview.media);

Widget buildMessageLinkPreview(BuildContext context, MessagePreview preview) {
  var rows = <Widget>[
    Text(preview.head),
    Text(preview.body),
  ];

  if (preview.thumb != null) {
    rows.add(_buildPreviewThumb(context, preview.thumb));
  }
  return Column(children: rows);
}

Widget buildMessageImagePreview(BuildContext context, MessagePreview preview) {
  return _buildPreviewThumb(context, preview.thumb);
}

Widget _buildPreviewThumb(BuildContext context, String thumb) {
  return Image.network(thumb);
}

isNeedHighlight(RegularMessage message) =>
    message.highlight == true ||
    message.regularMessageType ==
        RegularMessageType.UNKNOWN;

bool isHaveLongText(RegularMessage message) =>
    message.text != null ? message.text.length > 10 : false;

IconData _findTitleIconDataForMessage(RegularMessage message) {
  IconData icon;
  switch (message.regularMessageType) {
    case RegularMessageType.TOPIC_SET_BY:
      icon = Icons.assistant_photo;
      break;
    case RegularMessageType.TOPIC:
      icon = Icons.title;
      break;
    case RegularMessageType.WHO_IS:
      icon = Icons.account_circle;
      break;
    case RegularMessageType.UNHANDLED:
      icon = Icons.info;
      break;
    case RegularMessageType.UNKNOWN:
      icon = Icons.help;
      break;
    case RegularMessageType.MESSAGE:
      icon = Icons.message;
      break;
    case RegularMessageType.JOIN:
      icon = Icons.arrow_forward;
      break;

    case RegularMessageType.AWAY:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.MODE:
      icon = Icons.info;
      break;
    case RegularMessageType.MOTD:
      icon = Icons.info;
      break;
    case RegularMessageType.NOTICE:
      icon = Icons.info;
      break;
    case RegularMessageType.ERROR:
      icon = Icons.error;
      break;
    case RegularMessageType.BACK:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.MODE_CHANNEL:
      icon = Icons.info;
      break;
    case RegularMessageType.QUIT:
      icon = Icons.exit_to_app;
      break;
    case RegularMessageType.RAW:
      icon = Icons.info;
      break;
    case RegularMessageType.PART:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.NICK:
      icon = Icons.accessibility_new;
      break;
    case RegularMessageType.CTCP_REQUEST:
      icon = Icons.info;
      break;
  }
  return icon;
}

Widget buildRegularMessageWidget(
    BuildContext context, Widget title, Widget body, Color color) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: title,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: body,
        ),
      ],
    ),
  );
}

Widget buildMessageTitle(startPart, endPart) {
  if (startPart != null && endPart != null) {
    return Row(
        children: <Widget>[startPart, endPart],
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  } else {
    if (startPart != null) {
      return Align(child: startPart, alignment: Alignment.centerLeft);
    } else if (endPart != null) {
      return Align(child: endPart, alignment: Alignment.centerRight);
    } else {
      return Container();
    }
  }
}

Widget buildMessageTitleDate(
    BuildContext context, ChatMessage message, Color color) {
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var dateString;

  var date = message.date;

  if (message.isMessageDateToday) {
    dateString = todayDateFormatter.format(date);
  } else {
    dateString = regularDateFormatter.format(date);
  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Text(
      dateString,
      style: messagesSkin.createDateTextStyle(color),
    ),
  );
}

Icon buildMessageIcon(IconData iconData, Color color) {
  return Icon(iconData, color: color);
}

class MessageVideoPreviewWidget extends StatefulWidget {
  final String _videoURL;

  MessageVideoPreviewWidget(this._videoURL);

  @override
  State<StatefulWidget> createState() {
    return MessageVideoPreviewWidgetState(_videoURL);
  }
}

class MessageVideoPreviewWidgetState extends State<MessageVideoPreviewWidget> {
  String _videoURL;

  MessageVideoPreviewWidgetState(this._videoURL);

  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController1 = VideoPlayerController.network(_videoURL);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1, allowFullScreen: false,

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      autoInitialize: true,
//      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }
}

class MessageAudioPreviewWidget extends StatefulWidget {
  final String _audioURL;

  MessageAudioPreviewWidget(this._audioURL);

  @override
  State<StatefulWidget> createState() {
    return MessageAudioPreviewWidgetState(_audioURL);
  }
}

class MessageAudioPreviewWidgetState extends State<MessageAudioPreviewWidget> {
  String _audioURL;

  MessageAudioPreviewWidgetState(this._audioURL);

  VideoPlayerController _videoPlayerController1;
  ChewieAudioController chewieAudioController;

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    chewieAudioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController1 = VideoPlayerController.network(_audioURL);
    chewieAudioController = ChewieAudioController(
        videoPlayerController: _videoPlayerController1,
        autoInitialize: true,
        errorBuilder: (context, str) {
          return Text("$str");
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChewieAudio(controller: chewieAudioController);
  }
}
