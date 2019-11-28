
import 'package:flutter/widgets.dart';

abstract class SpecialMessageBody {

  Map<String, dynamic> toJson();

  bool isContainsText(String searchTerm, {@required bool ignoreCase});
}
