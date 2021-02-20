import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:rxdart/subjects.dart';

class ChannelTopicFormBloc extends FormBloc {
  FormValueFieldBloc<String> _topicFieldBloc;

  FormValueFieldBloc<String> get topicFieldBloc => _topicFieldBloc;

  // ignore: close_sinks
  BehaviorSubject<bool> _isPossibleToChangeTopicSubject =
      BehaviorSubject.seeded(false);

  final String _initTopic;

  Stream<bool> get isPossibleToChangeTopicStream =>
      _isPossibleToChangeTopicSubject.stream.distinct();

  bool get isPossibleToChangeTopic => _isPossibleToChangeTopicSubject.value;

  ChannelTopicFormBloc(this._initTopic) {
    addDisposable(subject: _isPossibleToChangeTopicSubject);

    _topicFieldBloc = FormValueFieldBloc<String>(_initTopic, validators: []);

    addDisposable(
      streamSubscription: topicFieldBloc.valueStream.listen(
        (newTopic) {
          // topic changed
          _isPossibleToChangeTopicSubject.add(newTopic != _initTopic);
        },
      ),
    );
  }

  @override
  List<FormFieldBloc> get children => [topicFieldBloc];

  String extractTopic() => topicFieldBloc.value;
}
