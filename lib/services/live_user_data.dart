import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/app_data.dart';
import '../models/month_key.dart';
import 'app_data_decoder.dart';
import 'user_collections.dart';
import 'user_documents.dart';

/// Live view of one account's data. Keeps a Firestore listener on the profile
/// and on every subcollection and reassembles [AppData] whenever any of them
/// changes, including the other phone's edits. Firestore answers from its
/// offline cache first, so the app keeps working without a connection.
///
/// A listener that fails is finished for good, so it is reopened after
/// [firstRetry], doubling up to [longestRetry]; until then its error is
/// exposed on [error] instead of the screens waiting forever.
class LiveUserData extends ChangeNotifier {
  LiveUserData(
    this._docs, {
    this._decoder = const AppDataDecoder(),
    DateTime Function()? clock,
    this.firstRetry = const Duration(seconds: 5),
    this.longestRetry = const Duration(minutes: 1),
  }) : _clock = clock ?? DateTime.now;

  static const String _profileKey = 'profile';

  final UserCollections _docs;
  final AppDataDecoder _decoder;
  final DateTime Function() _clock;
  final Duration firstRetry;
  final Duration longestRetry;

  final Map<String, StreamSubscription<Object?>> _subs = {};
  final Map<String, Timer> _retries = {};
  final Map<String, Duration> _nextDelay = {};
  final Map<String, Object> _errors = {};
  final Map<String, List<Map<String, dynamic>>> _collections = {};
  final Set<String> _fromServer = {};
  final Completer<AppData> _ready = Completer();
  final Completer<void> _serverConfirmed = Completer();
  Map<String, dynamic>? _profile;
  bool _profileLoaded = false;
  String? _expensesMonth;
  AppData? _data;
  bool _disposed = false;

  /// The assembled data; null until every listener has answered once.
  AppData? get data => _data;

  Object? get error => _errors.values.firstOrNull;

  bool get profileExists => _profile != null;

  /// The budget month expenses are booked to until it is closed.
  String get openMonth =>
      (_profile?['currentMonth'] as String?) ?? monthKey(_clock());

  /// True once every listener has heard from the server, not just the cache.
  bool get confirmedByServer => _serverConfirmed.isCompleted;

  /// The raw documents behind [data], with their ids.
  UserDocuments get documents =>
      UserDocuments(profile: _profile, collections: _collections);

  Future<AppData> ready() => _data != null ? Future.value(_data) : _ready.future;

  /// True when the server confirms the account holds no data yet, false when
  /// it holds some, null when the server did not answer within [timeout]
  /// (offline: the cache cannot tell an empty account from an unsynced one).
  Future<bool?> isEmptyOnServer({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      await _serverConfirmed.future.timeout(timeout);
    } on TimeoutException {
      return null;
    }
    return _data?.isEmpty ?? true;
  }

  void start() {
    _watch<DocumentSnapshot<Map<String, dynamic>>>(
      _profileKey,
      () => _docs.profile.snapshots(includeMetadataChanges: true),
      _onProfile,
    );
    for (final name in UserCollections.names) {
      if (name == UserCollections.expensesName) continue;
      _watch<QuerySnapshot<Map<String, dynamic>>>(
        name,
        () => _docs.collection(name).snapshots(includeMetadataChanges: true),
        (snap) => _onCollection(name, snap),
      );
    }
  }

  void _onProfile(DocumentSnapshot<Map<String, dynamic>> snap) {
    _profile = snap.data();
    _profileLoaded = true;
    _markSource(_profileKey, snap.metadata);
    if (openMonth != _expensesMonth) _watchExpenses(openMonth);
  }

  /// Only the open month's expenses are live; closing the month moves the
  /// profile on, which brings us back here for the new month.
  void _watchExpenses(String month) {
    const name = UserCollections.expensesName;
    _cancel(name);
    _expensesMonth = month;
    _collections.remove(name);
    _watch<QuerySnapshot<Map<String, dynamic>>>(
      name,
      () => _docs.expenses
          .where('month', isEqualTo: month)
          .snapshots(includeMetadataChanges: true),
      (snap) => _onCollection(name, snap),
    );
  }

  void _onCollection(String name, QuerySnapshot<Map<String, dynamic>> snap) {
    _collections[name] = [
      for (final doc in snap.docs) {...doc.data(), 'id': doc.id},
    ];
    _markSource(name, snap.metadata);
  }

  void _markSource(String key, SnapshotMetadata metadata) {
    if (!metadata.isFromCache) _fromServer.add(key);
  }

  void _rebuild() {
    final loaded = _profileLoaded &&
        UserCollections.names.every(_collections.containsKey);
    if (!loaded) return;
    _data = _decoder.decode(documents, fallbackMonth: monthKey(_clock()));
    if (!_ready.isCompleted) _ready.complete(_data);
    if (!_serverConfirmed.isCompleted &&
        _fromServer.containsAll([_profileKey, ...UserCollections.names])) {
      _serverConfirmed.complete();
    }
    notifyListeners();
  }

  void _watch<T>(String key, Stream<T> Function() open, void Function(T) on) {
    _subs[key] = open().listen(
      (value) {
        if (_disposed) return;
        _errors.remove(key);
        _nextDelay.remove(key);
        on(value);
        _rebuild();
      },
      onError: (Object e) {
        if (_disposed) return;
        _errors[key] = e;
        _cancel(key);
        notifyListeners();
        final delay = _nextDelay[key] ?? firstRetry;
        final next = delay * 2;
        _nextDelay[key] = next > longestRetry ? longestRetry : next;
        _retries[key] = Timer(delay, () {
          _retries.remove(key);
          if (!_disposed) _watch(key, open, on);
        });
      },
    );
  }

  void _cancel(String key) {
    _subs.remove(key)?.cancel();
    _retries.remove(key)?.cancel();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final key in [..._subs.keys, ..._retries.keys]) {
      _cancel(key);
    }
    super.dispose();
  }
}
