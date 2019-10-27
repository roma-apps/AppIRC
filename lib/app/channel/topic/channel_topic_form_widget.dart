import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
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

    return buildFormTextField(
        context: context,
        bloc: formBloc.topicFieldBloc,
        controller: _topicController,
        label: AppLocalizations.of(context)
            .tr("chat.channel.topic.dialog.field.edit.label"),
        hint: AppLocalizations.of(context)
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
    ChannelTopicFormBloc topicFormBloc, NetworkChannelBloc channelBloc) {
  return StreamBuilder<bool>(
      stream: topicFormBloc.isPossibleToChangeTopicStream,
      initialData: topicFormBloc.isPossibleToChangeTopic,
      builder: (context, snapshot) {
        var isPossibleToChange = snapshot.data;
        var onPressed;
        if (isPossibleToChange) {
          onPressed = () {
            channelBloc.editNetworkChannelTopic(topicFormBloc.extractTopic());
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
