import 'dart:async';
import 'package:expenser/home_page.dart';
import 'package:expenser/otp_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'user_dashboard.dart';
import 'otp_page.dart';
import 'firebase_sync_service.dart';
import 'friend_request_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, go to home page
        if (snapshot.hasData && snapshot.data != null) {
          print('User already logged in: ${snapshot.data!.phoneNumber}');
          return HomePageWithFriendRequestListener();
        }
        
        // If user is not logged in, go to login page
        print('No user logged in, showing login page');
        return const LoginPage();
      },
    );
  }
}

class HomePageWithFriendRequestListener extends StatefulWidget {
  const HomePageWithFriendRequestListener({super.key});

  @override
  State<HomePageWithFriendRequestListener> createState() => _HomePageWithFriendRequestListenerState();
}

class _HomePageWithFriendRequestListenerState extends State<HomePageWithFriendRequestListener> {
  StreamSubscription? _friendRequestSubscription;

  @override
  void initState() {
    super.initState();
    _startFriendRequestListener();
  }

  @override
  void dispose() {
    _friendRequestSubscription?.cancel();
    super.dispose();
  }

  void _startFriendRequestListener() {
    print('🔍 Starting friend request listener in main.dart');
    
    _friendRequestSubscription = FirebaseSyncService.startFriendRequestListener().listen(
      (_) {
        // New friend request received - you can show notification here
        
      },
      onError: (error) {
        print('Error in friend request listener: $error');
      },
    );
    
    print('Friend request listener started successfully');
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
