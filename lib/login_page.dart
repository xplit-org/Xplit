import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

            // Bottom Section - Login Form (60% of screen)
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
          const SizedBox(height: 30),
          _buildContinueButton(),
          const Spacer(),
          _buildSignUpLink(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Login to Split',
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
            'Welcome back, Please login to continue',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInputField() {
    return Container(
      height: 100,
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
      top: 40,
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
          const SizedBox(width: 2),
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
      top: 30,
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
        onPressed: () {},
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

  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SignUpPage(),
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
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 16),
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: Colors.black54),
              ),
              TextSpan(
                text: 'Sign up',
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
} 