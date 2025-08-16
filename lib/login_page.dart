import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'otp_page.dart';
import 'user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode _mobileFocusNode = FocusNode();
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(() {
      setState(() {
      });
    });
    _mobileController.addListener(() {
      setState(() {
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
    return SizedBox(
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
    // Check if mobile number meets validation conditions
    bool isMobileValid = _mobileController.text.isNotEmpty && 
                        _mobileController.text.length == 10;
    
    // Button is disabled if loading OR if mobile number is invalid
    bool isButtonDisabled = _isLoading || !isMobileValid;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : _handleContinueButton,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonDisabled 
              ? Colors.grey.shade400 
              : const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isButtonDisabled ? Colors.grey.shade600 : Colors.white,
                ),
              ),
      ),
    );
  }

  void _handleContinueButton() async {
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Format phone number with country code
      String phoneNumber = '+91${_mobileController.text}'; // Assuming India (+91)
      
      // Check if user exists in database before sending OTP
      UserService userService = UserService();
      bool userExists = await userService.checkUserExists(_mobileController.text);
      
      if (!userExists) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mobile number not registered. Please sign up first.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate to signup page after showing message
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
        }
        return;
      }
      else{
        // Send OTP using Firebase Phone Authentication
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            print('Auto-verification completed');
            // This can happen on Android when SMS is auto-retrieved
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Auto-verification completed!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Verification failed: ${e.message}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification failed: ${e.message}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            print('OTP sent successfully! Verification ID: $verificationId');
            if (mounted) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP sent successfully! Check your phone for the verification code.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              
              // Navigate to OTP page with the mobile number and verification ID
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      OtpPage(
                        mobileNumber: _mobileController.text,
                        verificationId: verificationId,
                        pageType: OtpPageType.login,
                        resendToken: resendToken,
                      ),
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
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('OTP auto-retrieval timeout');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP timeout - but request was sent. Please check your phone.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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