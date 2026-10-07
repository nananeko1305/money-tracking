import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:budget_tracker/services/user_session.dart';

const String testUid = 'test-user';

/// A signed-in account backed by an in-memory Firestore. Pass the same
/// [firestore] twice to get two "phones" on one account. Widget tests use it
/// as is (pumping loads it); plain tests use [openFakeSession].
UserSession fakeSession({
  FakeFirebaseFirestore? firestore,
  DateTime Function()? clock,
}) =>
    UserSession(
      firestore: firestore ?? FakeFirebaseFirestore(),
      uid: testUid,
      email: 'test@example.com',
      clock: clock,
    );

/// [fakeSession] with its live view loaded.
Future<UserSession> openFakeSession({
  FakeFirebaseFirestore? firestore,
  DateTime Function()? clock,
}) async {
  final session = fakeSession(firestore: firestore, clock: clock);
  await session.live.ready();
  await settle();
  return session;
}

/// Writes are not awaited by the app; this lets them reach the fake
/// Firestore and come back through the live listeners.
Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
