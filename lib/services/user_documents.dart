import 'user_collections.dart';

/// The raw documents of one account: the profile (null while it does not
/// exist) and the documents of every subcollection, keyed by the collection
/// names in [UserCollections]. Every document map carries its own id under
/// 'id', except the profile.
class UserDocuments {
  UserDocuments({
    this.profile,
    Map<String, List<Map<String, dynamic>>>? collections,
  }) : collections = {
          for (final name in UserCollections.names)
            name: collections?[name] ?? [],
        };

  final Map<String, dynamic>? profile;
  final Map<String, List<Map<String, dynamic>>> collections;

  List<Map<String, dynamic>> operator [](String name) => collections[name]!;

  /// The ids present in collection [name].
  Set<String> idsIn(String name) =>
      {for (final doc in this[name]) doc['id'] as String};
}
