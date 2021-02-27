import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:provider/provider.dart';

class ChannelConnectionIconWidget extends StatelessWidget {
  final Color foregroundColor;
  final bool connected;

  const ChannelConnectionIconWidget({
    @required this.foregroundColor,
    @required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    var chatConnectionBloc = Provider.of<ChatConnectionBloc>(context);
    return StreamBuilder(
      stream: chatConnectionBloc.isConnectedStream,
      initialData: chatConnectionBloc.isConnected,
      builder: (context, snapshot) {
        var chatConnected = snapshot.data;
        if (connected && chatConnected) {
          return const SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.cloud_off,
              color: foregroundColor,
            ),
          );
        }
      },
    );
  }
}
