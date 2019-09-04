import 'dart:convert';

import 'package:logger/logger.dart';

List<String> toPrint = ["trying to conenct"];

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

void log() {
  logger.d("Log message with 2 methods");

  loggerNoStack.i("Info message");

  loggerNoStack.w("Just a warning!");

  logger.e("Error! Something bad happened", "Test Error");

  loggerNoStack.v({"key": 5, "value": "something"});

  Future.delayed(Duration(seconds: 5), log);
}

pprint(data) {
  if (data is Map) {
    data = json.encode(data);
  }
  print(data);
  logger.i(data);
  toPrint.add(data);
}
