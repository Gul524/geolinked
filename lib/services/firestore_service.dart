import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class FirestoreService {
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get users => _db.collection('users');
  CollectionReference get asks => _db.collection('asks');
  CollectionReference get broadcasts => _db.collection('broadcasts');

  // ASKS
  Future<void> createAsk(AskModel ask) async {
    final GeoFirePoint geoFirePoint = GeoFirePoint(
      GeoPoint(ask.latitude ?? 0, ask.longitude ?? 0),
    );

    final docRef = asks.doc();
    final Map<String, dynamic> data = ask.copyWith(id: docRef.id).toJson();
    data['location'] = geoFirePoint.data;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
  }

  Future<void> deleteAsk(String askId) async {
    await asks.doc(askId).delete();
  }

  Stream<List<AskModel>> getNearbyAsks({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
   final GeoFirePoint center = GeoFirePoint(GeoPoint(latitude, longitude));
    final GeoCollectionReference<Map<String, dynamic>> geoRef =
        GeoCollectionReference(
          asks as CollectionReference<Map<String, dynamic>>,
        );

    return geoRef
        .subscribeWithin(
          center: center,
          radiusInKm: radiusKm,
          field: 'location',
          geopointFrom: (data) =>
              (data['location'] as Map<String, dynamic>)['geopoint']
                  as GeoPoint,
        )
        .map(
          (docs) => docs
              .map((doc) => AskModel.fromJson(
                    <String, dynamic>{...doc.data()!, 'id': doc.id},
                  ))
              .toList(),
        );
  }

  // BROADCASTS
  Future<void> createBroadcast(BroadcastModel broadcast) async {
    final GeoFirePoint geoFirePoint = GeoFirePoint(
      GeoPoint(broadcast.latitude ?? 0, broadcast.longitude ?? 0),
    );

    final docRef = broadcasts.doc();
    final Map<String, dynamic> data =
        broadcast.copyWith(id: docRef.id).toJson();
    data['location'] = geoFirePoint.data;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
  }

  Future<void> deleteBroadcast(String broadcastId) async {
    await broadcasts.doc(broadcastId).delete();
  }

  Stream<List<BroadcastModel>> getNearbyBroadcasts({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
final GeoFirePoint center = GeoFirePoint(GeoPoint(latitude, longitude));
    final GeoCollectionReference<Map<String, dynamic>> geoRef =
        GeoCollectionReference(
          broadcasts as CollectionReference<Map<String, dynamic>>,
        );

    return geoRef
        .subscribeWithin(
          center: center,
          radiusInKm: radiusKm,
          field: 'location',
          geopointFrom: (data) =>
              (data['location'] as Map<String, dynamic>)['geopoint']
                  as GeoPoint,
        )
        .map(
          (docs) => docs
              .map((doc) => BroadcastModel.fromJson(
                    <String, dynamic>{...doc.data()!, 'id': doc.id},
                  ))
              .toList(),
        );
  }

  // COMMENTS / DISCUSSIONS
  Future<void> addComment(
    String type,
    String postId,
    Map<String, dynamic> comment,
  ) async {
    final collection = type == 'ask' ? asks : broadcasts;
    await collection.doc(postId).collection('comments').add({
      ...comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(
    String type,
    String postId,
    String commentId,
  ) async {
    final collection = type == 'ask' ? asks : broadcasts;
    await collection.doc(postId).collection('comments').doc(commentId).delete();
  }

  Stream<List<Map<String, dynamic>>> getComments(String type, String postId) {
    final collection = type == 'ask' ? asks : broadcasts;
    return collection
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  Future<void> incrementViewCount(String type, String postId) async {
    final collection = type == 'ask' ? asks : broadcasts;
    final field = type == 'ask' ? 'viewCount' : 'seenCount';
    await collection.doc(postId).update({
      field: FieldValue.increment(1),
    });
  }
}
