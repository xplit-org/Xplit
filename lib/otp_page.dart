import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_page.dart';
import 'user_details_page.dart';

class OtpPage extends StatefulWidget {
  final String mobileNumber;

  const OtpPage({super.key, required this.mobileNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
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
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: Column(
          children: [
            // Top Section - Illustration (40% of screen)
            Expanded(flex: 4, child: _buildTopSection()),

            // Bottom Section - OTP Form (60% of screen)
            Expanded(flex: 6, child: _buildBottomSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
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
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/image 4.png',
            fit: BoxFit.cover,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
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
          const SizedBox(height: 40),
          _buildOtpInputSection(),
          const SizedBox(height: 50),
          _buildVerifyButton(),
          const SizedBox(height: 20),
          _buildResendOtpSection(),
          const Spacer(),
          _buildBackToSignUpLink(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Verify OTP',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              children: [
                const TextSpan(text: 'We have sent a verification code to '),
                TextSpan(
                  text: '+91-${widget.mobileNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => _buildOtpInputField(index)),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Enter the 4-digit code sent to your mobile number',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputField(int index) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // OTP digit display
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _otpControllers[index].text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Bottom border only
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: _otpFocusNodes[index].hasFocus
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          // Transparent text field for input
          Positioned.fill(
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.transparent,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild to update the displayed digit
                });
                if (value.isNotEmpty && index < 3) {
                  _otpFocusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _otpFocusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isOtpComplete() ? () => _verifyOtp() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isOtpComplete()
              ? const Color(0xFF2196F3)
              : Colors.grey.shade300,
          foregroundColor: _isOtpComplete()
              ? Colors.white
              : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Verify OTP',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildResendOtpSection() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Didn't receive the code?",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _resendOtp(),
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SignUpPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
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
                text: "Back to ",
                style: TextStyle(color: Colors.black54),
              ),
              TextSpan(
                text: 'Sign Up',
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

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _verifyOtp() {
    // TODO: Implement OTP verification logic with database
    String otp = _otpControllers.map((controller) => controller.text).join();
    print('Verifying OTP: $otp for mobile: ${widget.mobileNumber}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP verification successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Navigate to user details page after a short delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => UserDetailsPage(
              mobileNumber: widget.mobileNumber,
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
    });
  }

  void _resendOtp() {
    // TODO: Implement resend OTP logic
    
    // Clear all OTP input fields
    setState(() {
      for (var controller in _otpControllers) {
        controller.clear();
      }
    });
    
    // Focus on the first OTP field
    _otpFocusNodes[0].requestFocus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
