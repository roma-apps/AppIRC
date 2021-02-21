import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:provider/provider.dart';

StreamBuilder<bool> buildConnectionIcon(
    BuildContext context, Color foregroundColor, bool connected) {
  ChatConnectionBloc chatConnectionBloc = Provider.of(context);

  return StreamBuilder(
    stream: chatConnectionBloc.isConnectedStream,
    initialData: chatConnectionBloc.isConnected,
    builder: (context, snapshot) {
      var chatConnected = snapshot.data;
      if (connected && chatConnected) {
        return SizedBox.shrink();
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.cloud_off, color: foregroundColor),
        );
      }
    },
  );
}
