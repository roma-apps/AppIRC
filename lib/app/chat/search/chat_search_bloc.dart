import 'dart:async';

import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_db.dart';
import 'package:flutter_appirc/app/message/special/message_special_db.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:rxdart/subjects.dart';

import 'chat_search_model.dart';

class ChatSearchBloc extends DisposableOwner {
  final ChatDatabase _db;
  final Channel channel;

  final FormValueFieldBloc<String> searchFieldBloc = FormValueFieldBloc("");

  // ignore: close_sinks
  final BehaviorSubject<SearchState> _searchStateSubject = BehaviorSubject();

  Stream<SearchState> get searchStateStream => _searchStateSubject.stream;

  SearchState get searchState => _searchStateSubject.value;

  ChatSearchBloc(this._db, this.channel) {
    addDisposable(subject: _searchStateSubject);
    addDisposable(disposable: searchFieldBloc);
  }

  Future search() async {
    var searchTerm = searchFieldBloc.value;

    if (searchTerm?.isNotEmpty == true) {
      _searchStateSubject.add(
        SearchState(
          searchTerm: searchTerm,
          messages: [],
          isLoading: true,
        ),
      );

      var results = await _search(searchTerm);

      _searchStateSubject.add(
        SearchState(
          searchTerm: searchTerm,
          messages: results,
          isLoading: false,
        ),
      );
    } else {
      _searchStateSubject.add(
        SearchState(
          searchTerm: searchTerm,
          messages: [],
          isLoading: false,
        ),
      );
    }
  }

  Future<List<ChatMessage>> _search(String searchTerm) async {
    List<ChatMessage> messages = <ChatMessage>[];

    var query = "%$searchTerm%";

    var regularMessages = (await _db.regularMessagesDao
            .searchChannelMessagesOrderByDate(channel.remoteId, query, query))
        .map(regularMessageDBToChatMessage);
    var specialMessages = (await _db.specialMessagesDao
            .searchChannelMessagesOrderByDate(channel.remoteId, query))
        .map(specialMessageDBToChatMessage)
        .toList();

//    _removeUnnecessarySpecialLoadingMessages(specialMessages);

    messages.addAll(regularMessages);
    messages.addAll(specialMessages);
    _resort(messages);

    return messages;
  }

  void _resort(List<ChatMessage> messages) {
    messages.sort((a, b) {
      return a.date.compareTo(b.date);
    });
  }
}
