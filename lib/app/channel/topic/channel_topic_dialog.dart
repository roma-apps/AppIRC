import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void showTopicDialog(BuildContext context, ChannelBloc channelBloc) {
  showPlatformDialog(
      context: context,
      builder: (_) {
        var topicString = channelBloc.channelTopic;
        ChannelTopicFormBloc topicFormBloc = ChannelTopicFormBloc(topicString);

        return PlatformAlertDialog(
          title: Text(AppLocalizations.of(context).tr(
              "chat.channel.topic.dialog.title",
              args: [channelBloc.channel.name])),
          content: Provider(
            providable: topicFormBloc,
            child: ChannelTopicWidget(topicString),
          ),
          actions: <Widget>[
            _buildEditTopicActionWidget(topicFormBloc, channelBloc),
            _buildCancelActionWidget(context)
          ],
        );
      },
      androidBarrierDismissible: true);
}

PlatformDialogAction _buildCancelActionWidget(BuildContext context) {
  return PlatformDialogAction(
    child: Text(AppLocalizations.of(context)
        .tr("chat.channel.topic.dialog.action.cancel")),
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
            topicFormBloc.dispose();
            Navigator.pop(context);
          };
        }
        return PlatformDialogAction(
          child: Text(AppLocalizations.of(context)
              .tr("chat.channel.topic.dialog.action.change")),
          onPressed: onPressed,
        );
      });
}
