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
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        print("Error: User not authenticated");
        return null;
      }

      String uid = _auth.currentUser!.uid;
      print("Uploading profile picture for user: $uid");
      
      // Try Firebase Storage first
      try {
        Reference ref = _storage.ref().child('user_profiles').child(uid).child('profile.jpg');
        
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': uid},
        );
        
        UploadTask uploadTask = ref.putData(fileBytes, metadata);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        
        print("Profile picture uploaded to Firebase Storage: $downloadUrl");
        return downloadUrl;
      } catch (storageError) {
        print("Firebase Storage failed: $storageError");
        print("Falling back to base64 encoding...");
        
        // Fallback: Convert image to base64 and store in Firestore
        String base64Image = _convertToBase64(fileBytes);
        print("Image converted to base64 (${base64Image.length} characters)");
        return base64Image;
      }
    } catch (e) {
      print("All upload methods failed: $e");
      return null;
    }
  }

  // Helper method to convert image to base64
  String _convertToBase64(Uint8List imageBytes) {
    // Import dart:convert for base64 encoding
    String base64String = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  // Save user info to Firestore with exact schema match
  Future<void> saveUserDetails({
    required String fullName,
    required String mobileNumber,
    required String recoveryEmail,
    required String profilePicUrl,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore.collection('user_details').doc(uid).set({
        'country_code': '+91',
        'full_name': fullName,
        'last_login': FieldValue.serverTimestamp(),
        'mobile_number': mobileNumber,
        'profile_picture': profilePicUrl,
        'recovery_mail': recoveryEmail,
        'upi_id': '${mobileNumber}@gpz',
        'user_creation': FieldValue.serverTimestamp(),
      });
      
      print("User data saved successfully to user_details collection");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
}
