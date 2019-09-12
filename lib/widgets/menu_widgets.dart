
import 'package:flutter/material.dart';

PopupMenuItem<T> buildDropdownMenuItemRow<T>(
    {@required String text,
      @required IconData iconData,
      @required T value}) =>
    PopupMenuItem<T>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(iconData),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
        ],
      ),
    );
