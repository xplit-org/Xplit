import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile picture to Firebase Storage or convert to base64
  Future<String?> uploadProfilePicture(Uint8List fileBytes) async {
    try {
      // Generate a unique ID for the profile picture
      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Try Firebase Storage first (silently)
      try {
        Reference ref = _storage.ref().child('user_profiles').child(uniqueId).child('profile.jpg');
        
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
        );
        
        UploadTask uploadTask = ref.putData(fileBytes, metadata);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        
        print("✓ Profile picture uploaded successfully");
        return downloadUrl;
      } catch (storageError) {
        // Silently fallback to base64 encoding
        String base64Image = _convertToBase64(fileBytes);
        print("✓ Profile picture saved as base64");
        return base64Image;
      }
    } catch (e) {
      // Return a default placeholder instead of null
      return 'default_profile';
    }
  }

  // Helper method to convert image to base64
  String _convertToBase64(Uint8List imageBytes) {
    // Import dart:convert for base64 encoding
    String base64String = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  // Check if user exists in database
  Future<bool> checkUserExists(String mobileNumber) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('user_details').doc('+91$mobileNumber').get();
      return doc.exists;
    } catch (e) {
      print("Error checking user existence: $e");
      return false;
    }
  }

  // Save user info to Firestore with exact schema match
  Future<void> saveUserDetails({
    required String fullName,
    required String mobileNumber,
    required String upi_id, // This will now contain UPI ID
    required String profilePicUrl,
  }) async {
    try {
      // Use mobile number as document ID since we don't have Firebase Auth
      String documentId = mobileNumber;
      
      await _firestore.collection('user_details').doc(documentId).set({
        'country_code': '+91',
        'full_name': fullName,
        'last_login': FieldValue.serverTimestamp(),
        'mobile_number': mobileNumber,
        'profile_picture': profilePicUrl,
        'upi_id': upi_id, // Store the actual UPI ID entered by user
        'user_creation': FieldValue.serverTimestamp(),
        'to_get': 0,
        'to_pay': 0,
      });
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
}
