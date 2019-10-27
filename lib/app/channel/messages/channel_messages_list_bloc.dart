import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "channel_messages_list_bloc.dart", enabled: true);

class ChannelMessagesListBloc extends Providable {
  // ignore: close_sinks
  BehaviorSubject<bool> _searchEnabledSubject =
      BehaviorSubject(seedValue: false);

  Stream<bool> get searchEnabledStream =>
      _searchEnabledSubject.stream.distinct();
  bool get searchEnabled => _searchEnabledSubject.value;

  VisibleMessagesBounds _visibleMessagesBounds;
  VisibleMessagesBounds get visibleMessagesBounds => _visibleMessagesBounds;

  bool get isNeedSearch =>
      _mapIsNeedSearchTerm(searchEnabled, searchFieldBloc.value);

  Stream<bool> get isNeedSearchStream => Observable.combineLatest2(
          searchEnabledStream, searchFieldBloc.valueStream,
          (searchEnabled, searchTerm) {
        return _mapIsNeedSearchTerm(searchEnabled, searchTerm);
      });

  FormValueFieldBloc<String> searchFieldBloc = FormValueFieldBloc("");
  ChannelMessagesListBloc() {
    addDisposable(
        streamSubscription: _searchEnabledSubject.stream.listen((enabled) {
      if (!enabled) {
        searchFieldBloc.onNewValue("");
      }
    }));

    addDisposable(subject: _searchEnabledSubject);
    addDisposable(disposable: searchFieldBloc);
  }

  bool _mapIsNeedSearchTerm(searchEnabled, searchTerm) =>
      searchEnabled && searchTerm?.isNotEmpty == true;

  void onVisibleMessagesBounds(VisibleMessagesBounds visibleMessagesBounds) {
    this._visibleMessagesBounds = visibleMessagesBounds;
    _logger.d(() => "visibleMessagesBounds $visibleMessagesBounds");
  }

  void onNeedShowSearch() {
    _searchEnabledSubject.add(true);
  }

  void onNeedHideSearch() {
    _searchEnabledSubject.add(false);
  }

  void onNeedToggleSearch() {
    _searchEnabledSubject.add(!_searchEnabledSubject.value);
  }
}
