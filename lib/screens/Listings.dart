import 'package:flutter/material.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  int _selectedTab = 0;

  static const _listings = [
    _Listing(
      title: 'Home in Yucca Valley',
      subtitle: 'Desert dream oasis with spa',
      beds: '2 beds',
      rating: '4.97',
      reviews: '786',
      price: '\$762',
      isFavorite: false,
      imageColor: Color(0xFFD4C5A9),
    ),
    _Listing(
      title: 'Cabin in the Pines',
      subtitle: 'Cozy retreat with mountain views',
      beds: '3 beds',
      rating: '4.89',
      reviews: '412',
      price: '\$540',
      isFavorite: true,
      imageColor: Color(0xFFA8C5A0),
    ),
    _Listing(
      title: 'Beachfront Villa',
      subtitle: 'Private pool and ocean access',
      beds: '4 beds',
      rating: '4.95',
      reviews: '1,023',
      price: '\$1,240',
      isFavorite: false,
      imageColor: Color(0xFF9EC4D4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _listings.length,
                itemBuilder: (context, index) =>
                    _ListingCard(listing: _listings[index]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, size: 20, color: Color(0xFF222222)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Anywhere',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  Text(
                    'Any week  •  Add guests',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.tune, size: 16, color: Color(0xFF222222)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['Trending', 'Cabins', 'Beach', 'Pools', 'Amazing views'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => Chip(
          label: Text(
            filters[index],
            style: const TextStyle(fontSize: 12, color: Color(0xFF222222)),
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.search, 'Explore'),
      (Icons.favorite_border, 'Wishlists'),
      (Icons.calendar_today_outlined, 'Trips'),
      (Icons.chat_bubble_outline, 'Inbox'),
      (Icons.person_outline, 'Profile'),
    ];

    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (i) => setState(() => _selectedTab = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF385C),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: items
          .map((e) => BottomNavigationBarItem(icon: Icon(e.$1), label: e.$2))
          .toList(),
    );
  }
}

class _ListingCard extends StatefulWidget {
  final _Listing listing;
  const _ListingCard({required this.listing});

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.listing.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 280,
                  color: widget.listing.imageColor,
                  child: Center(
                    child: Icon(
                      Icons.home_outlined,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Guest favorite',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? const Color(0xFFFF385C)
                        : Colors.white,
                    size: 26,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.listing.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 13, color: Color(0xFF222222)),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.listing.rating} (${widget.listing.reviews})',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF222222)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            widget.listing.subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            widget.listing.beds,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${widget.listing.price} ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const TextSpan(
                  text: 'total before taxes',
                  style: TextStyle(fontSize: 13, color: Color(0xFF222222)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Listing {
  final String title;
  final String subtitle;
  final String beds;
  final String rating;
  final String reviews;
  final String price;
  final bool isFavorite;
  final Color imageColor;

  const _Listing({
    required this.title,
    required this.subtitle,
    required this.beds,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.isFavorite,
    required this.imageColor,
  });
}
