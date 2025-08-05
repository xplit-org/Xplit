import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FocusNode _mobileFocusNode = FocusNode();
  final TextEditingController _mobileController = TextEditingController();
  bool _isMobileFocused = false;
  bool _hasMobileText = false;

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(() {
      setState(() {
        _isMobileFocused = _mobileFocusNode.hasFocus;
      });
    });
    _mobileController.addListener(() {
      setState(() {
        _hasMobileText = _mobileController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _mobileFocusNode.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xDF0439A4), Color(0xDF0439A4)],
          ),
        ),
        child: Column(
          children: [
            // Top Section - Illustration (40% of screen)
            Expanded(
              flex: 3,
              child: _buildTopSection(),
            ),

            // Bottom Section - Sign Up Form (60% of screen)
            Expanded(
              flex: 6,
              child: _buildBottomSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        
        child: Image.asset(
          'assets/image 4.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildPersonIllustration(String emoji, {bool isOnATM = false, bool isOnGround = false, bool isOnMoneyStack = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildATMIllustration() {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                '\$',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDollarSign() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '\$',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
             child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const SizedBox(height: 20),
           _buildHeaderSection(),
           _buildMobileInputField(),
           const SizedBox(height: 40),
           _buildContinueButton(),
           const SizedBox(height: 30),
           _buildLoginLink(),
           const Spacer(),
           _buildTermsAndConditions(),
         ],
       ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            'SignUp to Split',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Welcome to split app, Sign up with your mobile number',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInputField() {
    return Container(
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildInputFieldContainer(),
          _buildFloatingLabel(),
        ],
      ),
    );
  }

  Widget _buildInputFieldContainer() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              _buildCountryCodeSelector(),
              _buildSeparator(),
              _buildMobileNumberInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCodeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Text(
            '🇮🇳',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildMobileNumberInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 0,
        ),
        child: TextField(
          controller: _mobileController,
          focusNode: _mobileFocusNode,
          decoration: const InputDecoration(
            hintText: 'Enter mobile number',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 8,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          enableInteractiveSelection: true,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFloatingLabel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      top: 10,
      left: 12,
      child: Material(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 0,
          ),
          child: const Text(
            'Mobile Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2196F3),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleContinueButton(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleContinueButton() {
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile number'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_mobileController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to OTP page with the mobile number
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OtpPage(
          mobileNumber: _mobileController.text,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 16),
            children: [
              TextSpan(
                text: "Already have an account? ",
                style: TextStyle(color: Colors.black54),
              ),
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 12, color: Colors.black54),
          children: [
            TextSpan(text: "By continuing, you agree to our "),
            TextSpan(
              text: "Terms and Conditions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(text: " and "),
            TextSpan(
              text: "Privacy policy.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const squareSize = 20.0;
    const spacing = 30.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 