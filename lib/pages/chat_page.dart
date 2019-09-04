import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Center(child: LogConsole()),
    );
  }
}
