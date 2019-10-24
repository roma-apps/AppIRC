import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
