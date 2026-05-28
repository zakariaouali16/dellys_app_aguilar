import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/currency_provider.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggled;

  const ListingDetailScreen({
    super.key,
    required this.listing,
    this.isFavorite = false,
    this.onFavoriteToggled,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  late bool _isFavorite;
  final _pageController = PageController();

  static const _amenityIcons = <String, IconData>{
    'WiFi': Icons.wifi,
    'Pool': Icons.pool,
    'Kitchen': Icons.kitchen_outlined,
    'Free parking': Icons.local_parking,
    'Air conditioning': Icons.ac_unit,
    'Washer': Icons.local_laundry_service,
    'TV': Icons.tv_outlined,
    'Gym': Icons.fitness_center,
    'Beach access': Icons.beach_access,
    'Mountain view': Icons.landscape_outlined,
    'Hot tub': Icons.hot_tub,
    'Fireplace': Icons.fireplace_outlined,
    'Workspace': Icons.desk,
    'Outdoor dining': Icons.outdoor_grill_outlined,
    'Breakfast': Icons.breakfast_dining_outlined,
  };

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final currency = context.watch<CurrencyProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildImageGallery(listing)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(listing),
                      if (listing.description.isNotEmpty) _buildDescription(listing),
                      if (listing.hostName.isNotEmpty) _buildHostSection(listing),
                      if (listing.amenities.isNotEmpty) _buildAmenities(listing),
                      if (listing.reviews.isNotEmpty) _buildReviews(listing),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _overlayButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF222222)),
                ),
                _overlayButton(
                  onTap: () {
                    setState(() => _isFavorite = !_isFavorite);
                    widget.onFavoriteToggled?.call(_isFavorite);
                  },
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: _isFavorite ? const Color(0xFFFF385C) : const Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(listing, currency),
    );
  }

  Widget _overlayButton({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildImageGallery(Listing listing) {
    final placeholder = Container(
      height: 320,
      color: _placeholderColor(listing),
      child: Center(
        child: Icon(
          Icons.home_outlined,
          size: 80,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );

    if (listing.images.isEmpty) return placeholder;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: listing.images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (_, i) => Image.network(
              listing.images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, _, _) => placeholder,
            ),
          ),
          if (listing.images.length > 1) ...[
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(listing.images.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _currentImageIndex ? 8 : 6,
                    height: i == _currentImageIndex ? 8 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == _currentImageIndex ? Colors.white : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentImageIndex + 1} / ${listing.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleSection(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (listing.isGuestFavorite) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Guest favorite',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          listing.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          listing.subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.star, size: 14, color: Color(0xFF222222)),
            Text(
              listing.rating.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            Text(
              '·  ${listing.reviewCount} reviews  ·  ${listing.bedsLabel}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, color: Color(0xFFEEEEEE)),
        const Text(
          'About this place',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          listing.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
        ),
      ],
    );
  }

  Widget _buildHostSection(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, color: Color(0xFFEEEEEE)),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF222222),
              child: Text(
                listing.hostName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hosted by ${listing.hostName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 3),
                if (listing.hostRating > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Color(0xFF222222)),
                      const SizedBox(width: 3),
                      Text(
                        '${listing.hostRating.toStringAsFixed(1)} host rating',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenities(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, color: Color(0xFFEEEEEE)),
        const Text(
          'What this place offers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: listing.amenities.map((amenity) {
            final icon = _amenityIcons[amenity] ?? Icons.check_circle_outline;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 40) / 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Icon(icon, size: 22, color: const Color(0xFF222222)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviews(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, color: Color(0xFFEEEEEE)),
        Row(
          children: [
            const Icon(Icons.star, size: 18, color: Color(0xFF222222)),
            const SizedBox(width: 6),
            Text(
              '${listing.rating.toStringAsFixed(2)}  ·  ${listing.reviewCount} reviews',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...listing.reviews.map(_buildReviewCard),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                child: Text(
                  review.authorName.isNotEmpty ? review.authorName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF222222),
                      ),
                    ),
                    Text(
                      review.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round() ? Icons.star : Icons.star_border,
                    size: 13,
                    color: const Color(0xFF222222),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Listing listing, CurrencyProvider currency) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${currency.formatPrice(listing.pricePerNight)} ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const TextSpan(
                        text: 'night',
                        style: TextStyle(fontSize: 14, color: Color(0xFF222222)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFF222222)),
                    const SizedBox(width: 2),
                    Text(
                      listing.rating.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF222222),
                      ),
                    ),
                    Text(
                      '  ·  ${listing.reviewCount} reviews',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF385C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Reserve',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _placeholderColor(Listing listing) {
    const colors = [
      Color(0xFFD4C5A9),
      Color(0xFFA8C5A0),
      Color(0xFF9EC4D4),
      Color(0xFFD4A8C5),
    ];
    return colors[listing.id.hashCode.abs() % colors.length];
  }
}
