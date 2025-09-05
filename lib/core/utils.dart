import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Utils {
  /// Pick profile picture from gallery or camera
  static Future<Uint8List?> pickProfilePic(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    } else {
      print("No Profile Pic is selected");
      return null;
    }
  }

  /// Helper function to create ImageProvider for profile pictures
  static ImageProvider? getProfileImageProvider(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      print('Profile picture is null or empty');
      return null;
    }
    
    // Check if it's a base64 image
    if (profilePicture.startsWith('data:image/')) {
      try {
        // Extract base64 data from the data URL
        final base64Data = profilePicture.split(',')[1];
        final bytes = base64Decode(base64Data);
        print('Successfully created MemoryImage from base64');
        return MemoryImage(bytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
        return null;
      }
    }
    
    // Check if it's a network URL
    if (profilePicture.startsWith('http://') || profilePicture.startsWith('https://')) {
      print('Creating NetworkImage for: $profilePicture');
      return NetworkImage(profilePicture);
    }
    
    // If it's a local asset path
    if (profilePicture.startsWith('assets/')) {
      print('Creating AssetImage for: $profilePicture');
      return AssetImage(profilePicture);
    }
    
    print('Profile picture format not recognized: $profilePicture');
    return null;
  }
}
