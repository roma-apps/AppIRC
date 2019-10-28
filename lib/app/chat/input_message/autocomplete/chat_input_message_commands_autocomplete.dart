
import 'package:flutter_appirc/autocomplete/autocomplete.dart';



class CommandsAutoCompleter extends AutoCompleter {
  final List<String> commands;

  CommandsAutoCompleter(this.commands);

  @override
  Future<List<String>> calculateAutoCompleteSuggestions(String pattern) async {
    var indexOf = pattern.indexOf(splitSeparator);

    if (indexOf >= 0) {
      // contains spaces
      return [];
    }

    return commands
        .where((command) => command.startsWith(pattern) && command != pattern)
        .toList();
  }

  @override
  void dispose() {

  }
}