import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChannelTopicWidget extends StatefulWidget {
  final String _initTopicString;

  ChannelTopicWidget(this._initTopicString);

  @override
  State<StatefulWidget> createState() =>
      ChannelTopicWidgetState(_initTopicString);
}

class ChannelTopicWidgetState extends State<ChannelTopicWidget> {
  String _initTopicString;

  ChannelTopicWidgetState(this._initTopicString);

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
        label: tr("chat.channel.topic.dialog.field.edit.label"),
        hint: tr("chat.channel.topic.dialog.field.edit.hint"),
        minLines: 1,
        textInputAction: TextInputAction.done);
  }

  @override
  void dispose() {
    super.dispose();
    _topicController.dispose();
  }
}
