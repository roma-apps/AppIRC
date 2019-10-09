class PushMessage {
  final PushMessageType type;
  final Map<String, dynamic> data;
  PushMessage(this.type, this.data);

  @override
  String toString() {
    return 'PushMessage{type: $type, data: $data}';
  }


}

enum PushMessageType {
  DEFAULT, LAUNCH, BACKGROUND, RESUME
}