import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:video_player/video_player.dart';

Widget buildMessageAudioPreview(
        {@required BuildContext context, @required  MessagePreview preview}) =>
    MessageAudioPreviewWidget(preview.media);

class MessageAudioPreviewWidget extends StatefulWidget {
  final String _audioURL;

  MessageAudioPreviewWidget(this._audioURL);

  @override
  MessageAudioPreviewWidgetState createState() {
    return MessageAudioPreviewWidgetState(_audioURL);
  }
}

class MessageAudioPreviewWidgetState extends State<MessageAudioPreviewWidget> {
  final String _audioURL;

  MessageAudioPreviewWidgetState(this._audioURL);

  VideoPlayerController _videoPlayerController;
  ChewieAudioController _chewieAudioController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieAudioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(_audioURL);
    _chewieAudioController = ChewieAudioController(
        videoPlayerController: _videoPlayerController,
        autoInitialize: true,
        errorBuilder: (context, str) {
          return Text("$str");
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChewieAudio(controller: _chewieAudioController);
  }
}
