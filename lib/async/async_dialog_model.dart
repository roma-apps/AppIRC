class AsyncDialogResult<T> {
  final T result;
  final bool canceled;

  bool get isNotCanceled => !canceled;

  AsyncDialogResult(this.result, this.canceled);

  @override
  String toString() {
    return 'AsyncDialogResult{result: $result, canceled: $canceled}';
  }
}
