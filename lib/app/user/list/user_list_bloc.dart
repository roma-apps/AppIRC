import 'dart:async';

import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';

import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("user_list_bloc.dart");

class ChannelUsersListBloc extends DisposableOwner {
  final ChannelBloc _channelBloc;

  // ignore: close_sinks
  BehaviorSubject<List<ChannelUser>> _usersSubject;

  Stream<List<ChannelUser>> get usersStream => _usersSubject.stream;

  List<ChannelUser> get users => _usersSubject.value;

  FormValueFieldBloc<String> filterFieldBloc;

  ChannelUsersListBloc(this._channelBloc) {
    _usersSubject = BehaviorSubject.seeded(_channelBloc.users);

    filterFieldBloc = FormValueFieldBloc("");

    addDisposable(
      streamSubscription: filterFieldBloc.valueStream.listen(
        (filter) {
          _onNeedChangeUsersList();
        },
      ),
    );

    addDisposable(
        streamSubscription: _channelBloc.usersStream.listen((newUsers) {
      _onNeedChangeUsersList();
    }));

    addDisposable(disposable: filterFieldBloc);
    addDisposable(subject: _usersSubject);
  }

  void _onNeedChangeUsersList() {
    var filter = filterFieldBloc.value;
    var filteredUsers = _channelBloc.users.where((user) {
      return user.nick.contains(RegExp(filter, caseSensitive: false));
    }).toList();

    _logger.fine(() => "filteredUsers for $filter: $filteredUsers ");
    _usersSubject.add(filteredUsers);
  }
}
