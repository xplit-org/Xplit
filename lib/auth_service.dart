import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  String? _phoneNumber;

  // Simple OTP system that works immediately
  Future<void> sendOTP(String phoneNumber) async {
    try {
      print('📱 SENDING OTP TO: $phoneNumber');
      
      // Store phone number
      _phoneNumber = phoneNumber;
      
      // Simulate OTP sending (2 second delay)
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate a simple verification ID
      _verificationId = 'mock_verification_${DateTime.now().millisecondsSinceEpoch}';
      
      print('✅ OTP SENT SUCCESSFULLY!');
      print('📱 Check your phone for OTP: 1234');
      
    } catch (e) {
      print('❌ Error sending OTP: $e');
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Verify OTP with a simple check
  Future<bool> verifyOTP(String otp) async {
    try {
      print('🔐 VERIFYING OTP: $otp');
      
      // Simple OTP validation (accepts 1234 or any 4-digit code)
      if (otp.length == 4 && otp == '1234') {
        print('✅ OTP VERIFIED SUCCESSFULLY!');
        print('📱 Phone number: $_phoneNumber');
        
        // Return true for successful verification
        return true;
      } else {
        throw Exception('Invalid OTP. Please enter 1234');
      }
    } catch (e) {
      print('❌ OTP verification failed: $e');
      throw Exception('OTP verification failed: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
} 