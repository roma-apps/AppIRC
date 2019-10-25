import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_bloc.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_text_field.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NetworkChannelTopicWidget extends StatefulWidget {
  final String _initTopicString;

  NetworkChannelTopicWidget(this._initTopicString);

  @override
  State<StatefulWidget> createState() =>
      NetworkChannelTopicWidgetState(_initTopicString);
}

class NetworkChannelTopicWidgetState extends State<NetworkChannelTopicWidget> {
  String _initTopicString;

  NetworkChannelTopicWidgetState(this._initTopicString);

  TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: _initTopicString);
  }

  @override
  Widget build(BuildContext context) {
    var formBloc = Provider.of<ChannelTopicFormBloc>(context);

    return buildPlatformTextField(
        context,
        formBloc.topicFieldBloc,
        _topicController,
        AppLocalizations.of(context)
            .tr("chat.channel.topic.dialog.field.edit.label"),
        AppLocalizations.of(context)
            .tr("chat.channel.topic.dialog.field.edit.hint"),
        minLines: 1,
        textInputAction: TextInputAction.done);
  }

  @override
  void dispose() {
    super.dispose();
    _topicController.dispose();
  }
}

void showTopicDialog(BuildContext context, NetworkChannelBloc channelBloc) {
  showPlatformDialog(
      context: context,
      builder: (_) {
        var topicString = channelBloc.networkChannelTopic;
        ChannelTopicFormBloc topicFormBloc = ChannelTopicFormBloc(topicString);

        return PlatformAlertDialog(
          title: Text(AppLocalizations.of(context).tr(
              "chat.channel.topic.dialog.title",
              args: [channelBloc.channel.name])),
          content: Provider(
            providable: topicFormBloc,
            child: NetworkChannelTopicWidget(topicString),
          ),
          actions: <Widget>[
            StreamBuilder<bool>(
                stream: topicFormBloc.isPossibleToChangeTopicStream,
                initialData: topicFormBloc.isPossibleToChangeTopic,
                builder: (context, snapshot) {
                  var isPossibleToChange = snapshot.data;
                  var onPressed;
                  if (isPossibleToChange) {
                    onPressed = () {
                      channelBloc.editNetworkChannelTopic(
                          topicFormBloc.extractTopic());
                      topicFormBloc.dispose();
                      Navigator.pop(context);
                    };
                  }
                  return PlatformDialogAction(
                    child: Text(AppLocalizations.of(context)
                        .tr("chat.channel.topic.dialog.action.change")),
                    onPressed: onPressed,
                  );
                }),
            PlatformDialogAction(
              child: Text(AppLocalizations.of(context)
                  .tr("chat.channel.topic.dialog.action.cancel")),
              onPressed: () {
                // TODO: check
                topicFormBloc.dispose();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
      androidBarrierDismissible: true);
}