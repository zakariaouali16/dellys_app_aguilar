import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/currency_provider.dart';
import '../services/listing_service.dart';
import 'profile_screen.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  int _selectedTab = 0;
  String _selectedCategory = 'Trending';
  final Set<String> _favorites = {};

  static const _categories = [
    'Trending',
    'Cabins',
    'Beach',
    'Pools',
    'Amazing views',
  ];

  @override
  void initState() {
    super.initState();
    ListingService.getFavorites().listen((favs) {
      if (mounted) setState(() => _favorites..clear()..addAll(favs));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: switch (_selectedTab) {
          1 => _buildWishlistsTab(),
          4 => const ProfileScreen(),
          _ => _buildExploreTab(),
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
      // TEMPORARY: remove after seeding data once
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF385C),
        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
        label: const Text('Seed Data', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          await ListingService.seedSampleListings();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Sample listings added to Firestore!'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: StreamBuilder<List<Listing>>(
            stream: ListingService.getListings(category: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF385C)),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                );
              }
              final listings = snapshot.data ?? [];
              if (listings.isEmpty) return _buildEmptyState();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return _ListingCard(
                    listing: listing,
                    isFavorite: _favorites.contains(listing.id),
                    onFavoriteToggled: (add) async {
                      setState(() {
                        if (add) {
                          _favorites.add(listing.id);
                        } else {
                          _favorites.remove(listing.id);
                        }
                      });
                      await ListingService.toggleFavorite(listing.id, add);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Text(
            'Wishlists',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ),
        Expanded(
          child: _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'No saved listings yet',
                        style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the heart on any listing to save it here',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : StreamBuilder<List<Listing>>(
                  stream: ListingService.getFavoriteListings(_favorites.toList()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF385C)),
                      );
                    }
                    final listings = snapshot.data ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return _ListingCard(
                          listing: listing,
                          isFavorite: true,
                          onFavoriteToggled: (add) async {
                            setState(() {
                              if (add) {
                                _favorites.add(listing.id);
                              } else {
                                _favorites.remove(listing.id);
                              }
                            });
                            await ListingService.toggleFavorite(listing.id, add);
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No listings in this category yet',
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
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
              child:
                  const Icon(Icons.tune, size: 16, color: Color(0xFF222222)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Chip(
              label: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : const Color(0xFF222222),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              backgroundColor:
                  selected ? const Color(0xFF222222) : Colors.white,
              side: BorderSide(
                color: selected ? const Color(0xFF222222) : Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
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

class _ListingCard extends StatelessWidget {
  final Listing listing;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggled;

  const _ListingCard({
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteToggled,
  });

  static const _placeholderColors = [
    Color(0xFFD4C5A9),
    Color(0xFFA8C5A0),
    Color(0xFF9EC4D4),
    Color(0xFFD4A8C5),
  ];

  Color get _placeholderColor =>
      _placeholderColors[listing.id.hashCode.abs() % _placeholderColors.length];

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 280,
                        color: _placeholderColor,
                        child: Center(
                          child: Icon(
                            Icons.home_outlined,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
              ),
              if (listing.isGuestFavorite)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
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
                  onTap: () => onFavoriteToggled(!isFavorite),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? const Color(0xFFFF385C)
                        : Colors.white,
                    size: 26,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 4),
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
              Expanded(
                child: Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 13, color: Color(0xFF222222)),
                  const SizedBox(width: 2),
                  Text(
                    '${listing.rating.toStringAsFixed(2)} (${listing.reviewCount})',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF222222)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            listing.subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            listing.bedsLabel,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${currency.formatPrice(listing.pricePerNight)} ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const TextSpan(
                  text: 'total before taxes',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF222222)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
