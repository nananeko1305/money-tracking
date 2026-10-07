import 'dart:async';

/// Firestore applies a write to the local cache at once, and the screens see
/// it from there; the returned future only completes once the server has it,
/// which offline can take hours. So nobody awaits a write: it is handed to
/// [track], and a rejection (say, permission denied) is reported on [errors]
/// for the shell to show.
class WriteErrors {
  final StreamController<Object> _errors = StreamController.broadcast();

  Stream<Object> get errors => _errors.stream;

  void track(Future<void> write) {
    unawaited(write.catchError((Object e) {
      if (!_errors.isClosed) _errors.add(e);
    }));
  }

  void dispose() => _errors.close();
}
