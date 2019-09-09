import 'package:flutter/material.dart';

typedef void BooleanCallback(bool);

buildFormTitle(BuildContext context, String title) => Padding(
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.title,
          ),
          Divider()
        ],
      ),
      padding: const EdgeInsets.all(4.0),
    );

buidFormTextRow(String title, TextEditingController controller,
        ValueChanged<String> callback) =>
    Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Text(title)),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: controller,
                onChanged: callback,
              ),
            ),
          ),
        ],
      ),
    );

buildFormBooleanRow(String title, bool startValue, BooleanCallback callback) =>
    Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(title),
          Checkbox(
            value: startValue,
            onChanged: callback,
          ),
        ],
      ),
    );
