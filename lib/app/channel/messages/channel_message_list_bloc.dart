import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "channel_message_list_bloc.dart", enabled: true);

class ChannelMessageListBloc extends Providable {
  final ChatPushesService chatPushesService;

  final Channel channel;

  // ignore: close_sinks
  BehaviorSubject<MessageListVisibleBounds> _visibleMessagesBoundsSubject =
      BehaviorSubject(seedValue: null);

  Stream<MessageListVisibleBounds> get visibleMessagesBoundsStream =>
      _visibleMessagesBoundsSubject.stream.distinct();

  MessageListVisibleBounds get visibleMessagesBounds =>
      _visibleMessagesBoundsSubject.value;


  FormValueFieldBloc<String> searchFieldBloc = FormValueFieldBloc("");

  ChannelMessageListBloc(this.chatPushesService, this.channel) {
    addDisposable(subject: _visibleMessagesBoundsSubject);
    addDisposable(disposable: searchFieldBloc);

    addDisposable(streamSubscription:
        chatPushesService.chatPushMessageStream.listen((newChatPushMessage) {
      var data = newChatPushMessage.data;

      if (data.chanId == channel.remoteId) {
        if (data.messageId != null) {
          _visibleMessagesBoundsSubject.add(MessageListVisibleBounds.fromPush(
              messageRemoteId: data.messageId));
        }
      }
    }));
  }
  void onVisibleMessagesBounds(MessageListVisibleBounds visibleMessagesBounds) {
    this._visibleMessagesBoundsSubject.add(visibleMessagesBounds);
    _logger.d(() => "visibleMessagesBounds $visibleMessagesBounds");
  }
}
