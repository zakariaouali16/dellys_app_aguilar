import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Guest';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(name, email, photoUrl),
          const SizedBox(height: 28),
          _buildCurrencySection(context),
          const SizedBox(height: 20),
          _buildRatesInfo(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String email, String? photoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF385C), Color(0xFFFF6B85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(name, photoUrl),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? photoUrl) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: const Color(0xFFFFD6DC),
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        onBackgroundImageError: photoUrl != null ? (_, _) {} : null,
        child: photoUrl == null
            ? Text(
                initials,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF385C),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCurrencySection(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Currency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how prices are displayed on listings',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _CurrencyTile(
            symbol: 'DA',
            name: 'Algerian Dinar',
            detail: 'Base currency',
            selected: provider.currency == AppCurrency.dzd,
            onTap: () => provider.setCurrency(AppCurrency.dzd),
          ),
          const SizedBox(height: 10),
          _CurrencyTile(
            symbol: '€',
            name: 'Euro',
            detail: '1 € = ${CurrencyProvider.eurToDzd.toStringAsFixed(0)} DA',
            selected: provider.currency == AppCurrency.eur,
            onTap: () => provider.setCurrency(AppCurrency.eur),
          ),
          const SizedBox(height: 10),
          _CurrencyTile(
            symbol: '\$',
            name: 'US Dollar',
            detail: '1 \$ = ${CurrencyProvider.usdToDzd.toStringAsFixed(0)} DA',
            selected: provider.currency == AppCurrency.usd,
            onTap: () => provider.setCurrency(AppCurrency.usd),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD6DC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFFF385C)),
                SizedBox(width: 6),
                Text(
                  'Exchange Rates',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RateRow(from: '1 €', to: '${CurrencyProvider.eurToDzd.toStringAsFixed(0)} DA'),
            const SizedBox(height: 4),
            _RateRow(from: '1 \$', to: '${CurrencyProvider.usdToDzd.toStringAsFixed(0)} DA'),
            const SizedBox(height: 4),
            _RateRow(from: '1 €', to: '${CurrencyProvider.eurToUsd.toStringAsFixed(2)} \$'),
          ],
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final String from;
  final String to;

  const _RateRow({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            from,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
          ),
        ),
        const Text(
          '  =  ',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Text(
          to,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final String symbol;
  final String name;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.symbol,
    required this.name,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF5F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFF385C) : Colors.grey.shade200,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF385C) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : const Color(0xFF666666),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? const Color(0xFFFF385C)
                          : const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFFFF385C) : Colors.grey.shade300,
                  width: 2,
                ),
                color: selected ? const Color(0xFFFF385C) : Colors.white,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
