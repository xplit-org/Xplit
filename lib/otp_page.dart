// ignore_for_file: dead_code

import 'package:expenser/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'user_details_page.dart';
import 'logic/create_local_db.dart';
import 'home_page.dart';

enum OtpPageType { login, signup }

class OtpPage extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;
  final int? resendToken;
  final OtpPageType pageType;

  const OtpPage({
    super.key,
    required this.mobileNumber,
    required this.verificationId,
    required this.pageType,
    this.resendToken,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isVerifying = false;

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
      resizeToAvoidBottomInset: true,
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
            Expanded(flex: 2, child: _buildTopSection()),

            // Bottom Section - OTP Form (60% of screen)
            Expanded(flex: 6, child: _buildBottomSection()),
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
            color: Colors.black,
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
            color: Colors.black,
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeaderSection(),
            _buildOtpInputSection(),
            const SizedBox(height: 30),
            _buildVerifyButton(),
            const SizedBox(height: 40),
            _buildResendOtpSection(),
            const SizedBox(height: 40),
            _buildBackToLink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Center(
          child: Text(
            widget.pageType == OtpPageType.login
                ? 'Login Verification'
                : 'Verify OTP',
            style: const TextStyle(
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
          children: List.generate(6, (index) => _buildOtpInputField(index)),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Enter the 6-digit verification code sent to your mobile number',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputField(int index) {
    return SizedBox(
      width: 40,
      height: 50,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
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

          // Input field
          Positioned.fill(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  setState(() {
                    // <--- Add this
                    // If current box has a value, clear it and move focus back
                    if (_otpControllers[index].text.isNotEmpty) {
                      _otpControllers[index].clear();

                      // Move focus to previous box if it exists
                      if (index > 0) {
                        _otpFocusNodes[index - 1].requestFocus();
                      }
                    }
                    // If current box is already empty, move focus back and clear previous box
                    else if (index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                      _otpControllers[index - 1].clear();
                    }
                  });
                }
              },

              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  if (value.isEmpty) {
                    setState(() {}); // just refresh UI
                    return;
                  }

                  // ✅ Case 1: Paste multiple digits
                  if (value.length > 1) {
                    for (int i = 0; i < value.length; i++) {
                      if (index + i < _otpControllers.length) {
                        _otpControllers[index + i].text = value[i];
                      }
                    }
                    int nextIndex = (index + value.length).clamp(
                      0,
                      _otpControllers.length - 1,
                    );
                    _otpFocusNodes[nextIndex].requestFocus();
                  } else {
                    // ✅ Case 2: Single digit typed
                    if (_otpControllers[index].text.isEmpty) {
                      // If empty → put digit here
                      _otpControllers[index].text = value;
                    } else if (index < _otpControllers.length - 1) {
                      _otpFocusNodes[index + 1].requestFocus();
                    }
                  }

                  setState(() {});
                },
              ),
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
        onPressed: (_isOtpComplete() && !_isVerifying)
            ? () => _verifyOtp()
            : null,
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
        child: _isVerifying
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
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

  Widget _buildBackToLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  widget.pageType == OtpPageType.login
                  ? const LoginPage()
                  : const SignUpPage(),
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
          text: TextSpan(
            style: TextStyle(fontSize: 16),
            children: [
              TextSpan(
                text: "Back to ",
                style: TextStyle(color: Colors.black54),
              ),
              TextSpan(
                text: widget.pageType == OtpPageType.login
                    ? 'Login'
                    : 'Sign Up',
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

  void _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    print('Verifying OTP: $otp for mobile: ${widget.mobileNumber}');

    setState(() {
      _isVerifying = true;
    });

    try {
      // Create PhoneAuthCredential with the OTP and verification ID
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in with the credential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verification successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate based on page type after a short delay
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            if (widget.pageType == OtpPageType.signup) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      UserDetailsPage(mobileNumber: widget.mobileNumber),
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
            } else {
              // For login: Check user data in database and navigate accordingly
              _handleLoginSuccess();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _resendOtp() async {
    try {
      // Format phone number with country code
      String phoneNumber = '+91${widget.mobileNumber}'; // Assuming India (+91)

      // Send OTP again using Firebase
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('Auto-verification completed on resend');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Resend verification failed: ${e.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to resend OTP: ${e.message}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print(
            'OTP resent successfully! New Verification ID: $verificationId',
          );
          // Update the verification ID for the new OTP
          setState(() {
            // Clear all OTP input fields
            for (var controller in _otpControllers) {
              controller.clear();
            }
            // Focus on the first OTP field
            _otpFocusNodes[0].requestFocus();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'OTP resent successfully! Check your phone for the new verification code.',
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('OTP resend auto-retrieval timeout');
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: widget.resendToken,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleLoginSuccess() async {
    try {
      // Initialize local database and sync data
      print(
        'Initializing local database and syncing data for: ${widget.mobileNumber}',
      );

      // Clear the database
      await LocalDB.clearDatabase();
      // Initialize the local database
      final db = await LocalDB.database;
      print('Local database initialized');

      // Sync user data from Firebase
      await LocalDB().syncUserData('+91${widget.mobileNumber}');
      print('User data synced from Firebase');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Data synced locally.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        print('User found - Navigate to Home/Dashboard');

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
