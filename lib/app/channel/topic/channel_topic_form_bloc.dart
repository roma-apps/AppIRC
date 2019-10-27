import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ChannelTopicFormBloc extends FormBloc {

  FormValueFieldBloc<String> topicFieldBloc;
  
  // ignore: close_sinks
  BehaviorSubject<bool> _isPossibleToChangeTopicController = BehaviorSubject
    (seedValue: false);

  final String _initTopic;
  Stream<bool> get isPossibleToChangeTopicStream =>
      _isPossibleToChangeTopicController.stream.distinct();
  bool get isPossibleToChangeTopic =>
      _isPossibleToChangeTopicController.value;

  ChannelTopicFormBloc(this._initTopic) {

    addDisposable(subject: _isPossibleToChangeTopicController);


    topicFieldBloc = FormValueFieldBloc<String>(
        _initTopic,
        validators: []);

    addDisposable(streamSubscription: topicFieldBloc.valueStream.listen(
            (newTopic) {
      // topic changed
      _isPossibleToChangeTopicController.add(newTopic != _initTopic);
    }));
  }

  @override
  List<FormFieldBloc> get children => [topicFieldBloc];

  String extractTopic() => topicFieldBloc.value;
}
