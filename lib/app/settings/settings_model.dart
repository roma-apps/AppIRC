import 'package:flutter_appirc/json/json_model.dart';

abstract class ISettings<T> implements IJsonObject {
  T clone();
}
