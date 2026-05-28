import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String authorName;
  final double rating;
  final String comment;
  final String date;

  const Review({
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        authorName: map['authorName'] as String? ?? 'Anonymous',
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        comment: map['comment'] as String? ?? '',
        date: map['date'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'authorName': authorName,
        'rating': rating,
        'comment': comment,
        'date': date,
      };
}

class Listing {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final int beds;
  final double pricePerNight;
  final String currency;
  final double rating;
  final int reviewCount;
  final bool isGuestFavorite;
  final List<String> images;
  final String hostId;
  final String hostName;
  final double hostRating;
  final List<String> amenities;
  final List<Review> reviews;
  final bool isActive;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description = '',
    required this.category,
    required this.beds,
    required this.pricePerNight,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.isGuestFavorite,
    required this.images,
    required this.hostId,
    this.hostName = '',
    this.hostRating = 0.0,
    this.amenities = const [],
    this.reviews = const [],
    required this.isActive,
    required this.createdAt,
  });

  factory Listing.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Listing(
      id: doc.id,
      title: d['title'] as String? ?? '',
      subtitle: d['subtitle'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? 'Trending',
      beds: (d['beds'] as num?)?.toInt() ?? 1,
      pricePerNight: (d['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      currency: d['currency'] as String? ?? 'DZD',
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
      isGuestFavorite: d['isGuestFavorite'] as bool? ?? false,
      images: List<String>.from(d['images'] as List? ?? []),
      hostId: d['hostId'] as String? ?? '',
      hostName: d['hostName'] as String? ?? '',
      hostRating: (d['hostRating'] as num?)?.toDouble() ?? 0.0,
      amenities: List<String>.from(d['amenities'] as List? ?? []),
      reviews: (d['reviews'] as List? ?? [])
          .map((r) => Review.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList(),
      isActive: d['isActive'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'category': category,
        'beds': beds,
        'pricePerNight': pricePerNight,
        'currency': currency,
        'rating': rating,
        'reviewCount': reviewCount,
        'isGuestFavorite': isGuestFavorite,
        'images': images,
        'hostId': hostId,
        'hostName': hostName,
        'hostRating': hostRating,
        'amenities': amenities,
        'reviews': reviews.map((r) => r.toMap()).toList(),
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  String get formattedPrice {
    if (currency == 'DZD') {
      return '${pricePerNight.toStringAsFixed(0)} DA';
    }
    return '\$${pricePerNight.toStringAsFixed(0)}';
  }

  String get bedsLabel => beds == 1 ? '1 bed' : '$beds beds';
}
