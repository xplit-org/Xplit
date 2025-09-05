import 'package:firebase_auth/firebase_auth.dart';

class GetFirebaseData {
  final currentUser = FirebaseAuth.instance.currentUser;

  // return current user mobile number
  String getCurrentUserMobile(){
    final String? currentUserMobile = currentUser?.phoneNumber;
    if(currentUserMobile == null) return "";
    return currentUserMobile;    
  }
}