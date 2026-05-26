import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedCountry = 'United Kingdom (+44)';
  final _phoneController = TextEditingController();
  final _googleSignIn = GoogleSignIn();
  bool _googleLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${account.displayName}')),
        );
        // TODO: navigate to home screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  static const _countries = [
    'United States (+1)',
    'United Kingdom (+44)',
    'Canada (+1)',
    'Algeria (+213)',
    'Australia (+61)',
    'France (+33)',
    'Germany (+49)',
    'Spain (+34)',
    'Italy (+39)',
    'Japan (+81)',
    'China (+86)',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: CustomPaint(
                  size: const Size(48, 48),
                  painter: _BeloPainter(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Airbnb',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 20),
              _buildDropdown(),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 12),
              Text(
                "We'll call or text you to confirm your number. Standard message and data rates apply.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              _buildContinueButton(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 16),
              _SocialButton(
                icon: const Icon(Icons.apple, size: 22, color: Colors.black87),
                label: 'Continue with Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: const Text(
                  'f',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                ),
                label: 'Continue with Facebook',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: _googleLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDB4437),
                        ),
                      ),
                label: 'Continue with Google',
                onPressed: _googleLoading ? () {} : _signInWithGoogle,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          style: const TextStyle(fontSize: 15, color: Color(0xFF222222)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          hint: const Text('Country/Region'),
          items: _countries
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) => setState(() => _selectedCountry = value!),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Phone number',
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF385C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF222222),
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(width: 24, child: Center(child: icon)),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _BeloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF385C)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Outer bélo silhouette
    final outer = Path();
    outer.moveTo(w * 0.5, h * 0.97);
    outer.cubicTo(w * 0.35, h * 0.84, w * 0.06, h * 0.68, w * 0.06, h * 0.46);
    outer.cubicTo(w * 0.06, h * 0.2, w * 0.26, h * 0.05, w * 0.5, h * 0.05);
    outer.cubicTo(w * 0.74, h * 0.05, w * 0.94, h * 0.2, w * 0.94, h * 0.46);
    outer.cubicTo(w * 0.94, h * 0.68, w * 0.65, h * 0.84, w * 0.5, h * 0.97);
    outer.close();

    // Inner hollow body
    final inner = Path();
    inner.moveTo(w * 0.5, h * 0.89);
    inner.cubicTo(w * 0.38, h * 0.79, w * 0.18, h * 0.65, w * 0.18, h * 0.48);
    inner.cubicTo(w * 0.18, h * 0.32, w * 0.33, h * 0.22, w * 0.5, h * 0.22);
    inner.cubicTo(w * 0.67, h * 0.22, w * 0.82, h * 0.32, w * 0.82, h * 0.48);
    inner.cubicTo(w * 0.82, h * 0.65, w * 0.62, h * 0.79, w * 0.5, h * 0.89);
    inner.close();

    // Head loop
    final head = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(w * 0.5, h * 0.33),
        radius: w * 0.14,
      ));

    final cutout = Path.combine(PathOperation.union, inner, head);
    final belo = Path.combine(PathOperation.difference, outer, cutout);

    canvas.drawPath(belo, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
