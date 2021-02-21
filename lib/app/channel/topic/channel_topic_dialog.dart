import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_widget.dart';
import 'package:flutter_appirc/disposable/disposable_provider.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

void showTopicDialog(BuildContext context, ChannelBloc channelBloc) {
  showPlatformDialog(
    context: context,
    builder: (_) {
      var topicString = channelBloc.channelTopic;

      return DisposableProvider(
        create: (context) => ChannelTopicFormBloc(topicString),
        child: Builder(
          builder: (context) {
            var topicFormBloc = Provider.of<ChannelTopicFormBloc>(context);
            return PlatformAlertDialog(
              title: Text(
                S
                    .of(context)
                    .chat_channel_topic_dialog_title(channelBloc.channel.name),
              ),
              content: ChannelTopicWidget(topicString),
              actions: <Widget>[
                _buildEditTopicActionWidget(topicFormBloc, channelBloc),
                _buildCancelActionWidget(context),
              ],
            );
          },
        ),
      );
    },
    androidBarrierDismissible: true,
  );
}

PlatformDialogAction _buildCancelActionWidget(BuildContext context) {
  return PlatformDialogAction(
    child: Text(S.of(context).chat_channel_topic_dialog_action_cancel),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}

StreamBuilder<bool> _buildEditTopicActionWidget(
    ChannelTopicFormBloc topicFormBloc, ChannelBloc channelBloc) {
  return StreamBuilder<bool>(
    stream: topicFormBloc.isPossibleToChangeTopicStream,
    initialData: topicFormBloc.isPossibleToChangeTopic,
    builder: (context, snapshot) {
      var isPossibleToChange = snapshot.data;
      var onPressed;
      if (isPossibleToChange) {
        onPressed = () {
          channelBloc.editChannelTopic(topicFormBloc.extractTopic());
          Navigator.pop(context);
        };
      }
      return PlatformDialogAction(
        child: Text(
          S.of(context).chat_channel_topic_dialog_action_change,
        ),
        onPressed: onPressed,
      );
    },
  );
}
