import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';

class SearchState {
  final String searchTerm;
  final bool isLoading;
  final List<ChatMessage> messages;

  SearchState({
    @required this.searchTerm,
    @required this.messages,
    @required this.isLoading,
  });

  @override
  String toString() {
    return 'SearchState{'
        'searchTerm: $searchTerm, '
        'isLoading: $isLoading, '
        'messages: $messages'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          runtimeType == other.runtimeType &&
          searchTerm == other.searchTerm &&
          isLoading == other.isLoading &&
          messages == other.messages;

  @override
  int get hashCode =>
      searchTerm.hashCode ^ isLoading.hashCode ^ messages.hashCode;
}