import 'package:chewie/chewie.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:video_player/video_player.dart';

Widget buildMessageVideoPreview(
        {@required BuildContext context, @required MessagePreview preview}) =>
    MessageVideoPreviewWidget(preview.media);

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

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(_videoURL);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      allowFullScreen: false,
      autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }
}
