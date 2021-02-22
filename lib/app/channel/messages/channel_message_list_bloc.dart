import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("channel_message_list_bloc.dart");

class ChannelMessageListBloc extends DisposableOwner {
  final ChatPushesService chatPushesService;

  final Channel channel;

  // ignore: close_sinks
  final BehaviorSubject<MessageListVisibleBounds>
      _visibleMessagesBoundsSubject = BehaviorSubject.seeded(null);

  Stream<MessageListVisibleBounds> get visibleMessagesBoundsStream =>
      _visibleMessagesBoundsSubject.stream.distinct();

  MessageListVisibleBounds get visibleMessagesBounds =>
      _visibleMessagesBoundsSubject.value;

  ChannelMessageListBloc(this.chatPushesService, this.channel) {
    addDisposable(subject: _visibleMessagesBoundsSubject);

    addDisposable(
      streamSubscription: chatPushesService.chatPushMessageStream.listen(
        (newChatPushMessage) {
          var data = newChatPushMessage.data;

          if (data.chanId == channel.remoteId) {
            if (data.messageId != null) {
              _visibleMessagesBoundsSubject.add(
                  MessageListVisibleBounds.fromPush(
                      messageRemoteId: data.messageId));
            }
          }
        },
      ),
    );
  }

  void onVisibleMessagesBounds(MessageListVisibleBounds visibleMessagesBounds) {
    _visibleMessagesBoundsSubject.add(visibleMessagesBounds);
    _logger.fine(() => "visibleMessagesBounds $visibleMessagesBounds");
  }
}
