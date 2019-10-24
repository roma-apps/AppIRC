import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "ChannelMessagesListBloc", enabled: true);

class ChannelMessagesListBloc extends Providable {
  // ignore: close_sinks
  BehaviorSubject<bool> _searchEnabledController =
      BehaviorSubject(seedValue: false);

  Stream<bool> get searchEnabledStream =>
      _searchEnabledController.stream.distinct();
  bool get searchEnabled => _searchEnabledController.value;

  VisibleMessagesBounds visibleMessagesBounds;

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
        streamSubscription: _searchEnabledController.stream.listen((enabled) {
      if (!enabled) {
        searchFieldBloc.onNewValue("");
      }
    }));

    addDisposable(subject: _searchEnabledController);
    addDisposable(disposable: searchFieldBloc);
  }

  bool _mapIsNeedSearchTerm(searchEnabled, searchTerm) =>
      searchEnabled && searchTerm?.isNotEmpty == true;

  void onVisibleMessagesBounds(VisibleMessagesBounds visibleMessagesBounds) {
    this.visibleMessagesBounds = visibleMessagesBounds;
    _logger.d(() => "visibleMessagesBounds $visibleMessagesBounds");
  }

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
