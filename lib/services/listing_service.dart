import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing.dart';

class ListingService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Stream<List<Listing>> getListings({String? category}) {
    Query<Map<String, dynamic>> q = _db
        .collection('listings')
        .where('isActive', isEqualTo: true);

    if (category != null && category != 'Trending') {
      q = q.where('category', isEqualTo: category);
    }

    return q.snapshots().map(
      (snap) => snap.docs.map(Listing.fromFirestore).toList(),
    );
  }

  static Stream<List<String>> getFavorites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return <String>[];
      final data = snap.data()!;
      return List<String>.from(data['favorites'] as List? ?? []);
    });
  }

  static Future<void> toggleFavorite(String listingId, bool add) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(
      {
        'favorites': add
            ? FieldValue.arrayUnion([listingId])
            : FieldValue.arrayRemove([listingId]),
      },
      SetOptions(merge: true),
    );
  }

  /// Seeds sample listings into Firestore — call once from the console or a
  /// debug button. Safe to call multiple times (uses add() so no overwrites).
  static Future<void> seedSampleListings() async {
    final uid = _auth.currentUser?.uid ?? '';
    final batch = _db.batch();
    final col = _db.collection('listings');

    final samples = [
      {
        'title': 'Home in Dellys',
        'subtitle': 'Beachfront paradise with stunning sea views',
        'category': 'Trending',
        'beds': 2,
        'pricePerNight': 8500,
        'currency': 'DZD',
        'rating': 4.97,
        'reviewCount': 786,
        'isGuestFavorite': true,
        'images': <String>[],
        'hostId': uid,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Cabin in the Pines',
        'subtitle': 'Cozy retreat with mountain views',
        'category': 'Cabins',
        'beds': 3,
        'pricePerNight': 12000,
        'currency': 'DZD',
        'rating': 4.89,
        'reviewCount': 412,
        'isGuestFavorite': false,
        'images': <String>[],
        'hostId': uid,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Beachfront Villa',
        'subtitle': 'Private pool and ocean access',
        'category': 'Beach',
        'beds': 4,
        'pricePerNight': 25000,
        'currency': 'DZD',
        'rating': 4.95,
        'reviewCount': 1023,
        'isGuestFavorite': true,
        'images': <String>[],
        'hostId': uid,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Pool House Retreat',
        'subtitle': 'Heated pool with garden terrace',
        'category': 'Pools',
        'beds': 2,
        'pricePerNight': 15000,
        'currency': 'DZD',
        'rating': 4.90,
        'reviewCount': 234,
        'isGuestFavorite': false,
        'images': <String>[],
        'hostId': uid,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final data in samples) {
      batch.set(col.doc(), data);
    }
    await batch.commit();
  }
}
