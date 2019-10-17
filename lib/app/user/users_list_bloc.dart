import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "ChannelUsersListBloc", enabled: true);

class ChannelUsersListBloc extends Providable {
  NetworkChannelBloc channelBloc;

  // ignore: close_sinks
  BehaviorSubject<List<NetworkChannelUser>> _usersController;

  Stream<List<NetworkChannelUser>> get usersStream => _usersController.stream;

  List<NetworkChannelUser> get users => _usersController.value;

  FormValueFieldBloc<String> filterFieldBloc;

  ChannelUsersListBloc(this.channelBloc) {
    _usersController = BehaviorSubject(seedValue: channelBloc.users);

    filterFieldBloc = FormValueFieldBloc("");

    addDisposable(
        streamSubscription: filterFieldBloc.valueStream.listen((filter) {
      onNeedChangeUsersList();
    }));

    addDisposable(
        streamSubscription: channelBloc.usersStream.listen((newUsers) {
      onNeedChangeUsersList();
    }));

    addDisposable(disposable: filterFieldBloc);
    addDisposable(subject: _usersController);
  }

  onNeedChangeUsersList() {
    var filter = filterFieldBloc.value;
    var filteredUsers = channelBloc.users.where((user) {
      return user.nick.contains(RegExp(filter, caseSensitive: false));
    }).toList();

    _logger.d(() => "filteredUsers for $filter: $filteredUsers ");
    _usersController.add(filteredUsers);
  }
}
