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

  static Stream<List<Listing>> getFavoriteListings(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _db
        .collection('listings')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
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
        'description':
            'Wake up to the sound of waves in this beautifully renovated home just steps from the Mediterranean. The open-plan living area opens onto a large terrace with unobstructed sea views. Perfect for couples or small families looking for an authentic Algerian coastal experience.',
        'category': 'Trending',
        'beds': 2,
        'pricePerNight': 8500,
        'currency': 'DZD',
        'rating': 4.97,
        'reviewCount': 786,
        'isGuestFavorite': true,
        'images': <String>[],
        'hostId': uid,
        'hostName': 'Karim',
        'hostRating': 4.96,
        'amenities': ['WiFi', 'Beach access', 'Air conditioning', 'Kitchen', 'TV', 'Free parking'],
        'reviews': [
          {
            'authorName': 'Sofia',
            'rating': 5.0,
            'comment': 'Absolutely stunning place. The sea view from the terrace made our mornings magical. Karim was incredibly helpful and responsive.',
            'date': 'April 2025',
          },
          {
            'authorName': 'Mehdi',
            'rating': 5.0,
            'comment': 'Perfect location, spotlessly clean, and the host left us everything we needed. We\'ll definitely be back!',
            'date': 'March 2025',
          },
          {
            'authorName': 'Laura',
            'rating': 4.0,
            'comment': 'Beautiful home with an amazing view. The kitchen is well-equipped and the beach is a 2-minute walk. Highly recommend.',
            'date': 'February 2025',
          },
        ],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Cabin in the Pines',
        'subtitle': 'Cozy retreat with mountain views',
        'description':
            'Escape to this charming wooden cabin nestled in a pine forest with sweeping mountain views. A crackling fireplace, a fully equipped kitchen, and total privacy make this the perfect hideaway. Hiking trails start right at the door.',
        'category': 'Cabins',
        'beds': 3,
        'pricePerNight': 12000,
        'currency': 'DZD',
        'rating': 4.89,
        'reviewCount': 412,
        'isGuestFavorite': false,
        'images': <String>[],
        'hostId': uid,
        'hostName': 'Yasmine',
        'hostRating': 4.92,
        'amenities': ['WiFi', 'Fireplace', 'Kitchen', 'Mountain view', 'TV', 'Free parking'],
        'reviews': [
          {
            'authorName': 'Rayan',
            'rating': 5.0,
            'comment': 'One of the most peaceful places I\'ve ever stayed. The fireplace in the evening was just perfect. Yasmine thought of every detail.',
            'date': 'January 2025',
          },
          {
            'authorName': 'Amina',
            'rating': 5.0,
            'comment': 'We came for a weekend and ended up extending our stay. The views are breathtaking and the cabin is so cozy.',
            'date': 'December 2024',
          },
        ],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Beachfront Villa',
        'subtitle': 'Private pool and ocean access',
        'description':
            'Live like royalty in this spacious beachfront villa with a private heated pool and direct access to a secluded beach. The villa features 4 bedrooms, a gourmet kitchen, outdoor dining area, and a hot tub. Ideal for groups and special occasions.',
        'category': 'Beach',
        'beds': 4,
        'pricePerNight': 25000,
        'currency': 'DZD',
        'rating': 4.95,
        'reviewCount': 1023,
        'isGuestFavorite': true,
        'images': <String>[],
        'hostId': uid,
        'hostName': 'Nadia',
        'hostRating': 4.98,
        'amenities': ['WiFi', 'Pool', 'Beach access', 'Hot tub', 'Kitchen', 'Air conditioning', 'Free parking', 'TV'],
        'reviews': [
          {
            'authorName': 'Alexis',
            'rating': 5.0,
            'comment': 'This villa exceeded all our expectations. The private beach and pool are incredible, and Nadia was the most attentive host we\'ve had.',
            'date': 'May 2025',
          },
          {
            'authorName': 'Omar',
            'rating': 5.0,
            'comment': 'We celebrated my wife\'s birthday here and it was magical. The hot tub at night with the sound of the waves — unforgettable.',
            'date': 'April 2025',
          },
          {
            'authorName': 'Claire',
            'rating': 4.0,
            'comment': 'Stunning property. The kitchen has everything you need and the outdoor dining area is lovely. Worth every dinar.',
            'date': 'March 2025',
          },
        ],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Pool House Retreat',
        'subtitle': 'Heated pool with garden terrace',
        'category': 'Pools',
        'description':
            'A tranquil oasis with a large heated pool surrounded by a lush garden terrace. The interior is modern and light-filled, with a fully equipped kitchen and a dedicated workspace. Great for remote workers and families alike.',
        'beds': 2,
        'pricePerNight': 15000,
        'currency': 'DZD',
        'rating': 4.90,
        'reviewCount': 234,
        'isGuestFavorite': false,
        'images': <String>[],
        'hostId': uid,
        'hostName': 'Salim',
        'hostRating': 4.88,
        'amenities': ['WiFi', 'Pool', 'Kitchen', 'Washer', 'Air conditioning', 'Workspace', 'TV', 'Outdoor dining'],
        'reviews': [
          {
            'authorName': 'Hana',
            'rating': 5.0,
            'comment': 'The pool is even better than the photos suggest. We spent most of our time outside — the garden is beautifully maintained.',
            'date': 'April 2025',
          },
          {
            'authorName': 'Bilal',
            'rating': 4.0,
            'comment': 'Great place for a remote work trip. Fast WiFi, quiet neighborhood, and the pool after a long workday was exactly what I needed.',
            'date': 'February 2025',
          },
        ],
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
