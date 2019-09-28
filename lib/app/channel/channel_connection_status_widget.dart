import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

import 'channels_list_skin_bloc.dart';

buildConnectionIcon(
    BuildContext context, Color foregroundColor, bool connected) {
  if (!connected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(Icons.cloud_off, color: foregroundColor),
    );
  } else {
    return Container();
  }
}
