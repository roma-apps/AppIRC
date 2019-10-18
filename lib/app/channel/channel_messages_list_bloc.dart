import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:rxdart/rxdart.dart';

class ChannelMessagesListBloc extends Providable {
  // ignore: close_sinks
  BehaviorSubject<bool> _searchEnabledController =
      BehaviorSubject(seedValue: false);
  
  Stream<bool> get searchEnabledStream =>
      _searchEnabledController.stream.distinct();
  bool get searchEnabled => _searchEnabledController.value;


  FormValueFieldBloc<String> searchFieldBloc;
  ChannelMessagesListBloc() {
    searchFieldBloc = FormValueFieldBloc("");

    addDisposable(streamSubscription: _searchEnabledController.stream.listen((enabled) {

      if(!enabled) {
        searchFieldBloc.onNewValue("");
      }
    }));

    addDisposable(subject: _searchEnabledController);
    addDisposable(disposable: searchFieldBloc);
  }

  ChatMessageListVisibleArea visibleArea;


  void onNeedShowSearch() {
    _searchEnabledController.add(true);
  }

  void onNeedHideSearch() {
    _searchEnabledController.add(false);
  }

  void onNeedToggleSearch() {
    _searchEnabledController.add(!_searchEnabledController.value);
  }



}
