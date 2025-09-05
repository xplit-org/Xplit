import 'dart:async';
import 'package:expenser/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'services/firebase_sync_service.dart';
import 'services/friend_request_notification_service.dart';
import 'services/expense_notification_service.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _friendRequestSubscription;
  StreamSubscription? _expenseSyncSubscription;

  @override
  void initState() {
    super.initState();
    _initializeNotificationService();
    _startFriendRequestListener();
    _startExpenseSyncListener();
  }

  @override
  void dispose() {
    _friendRequestSubscription?.cancel();
    _expenseSyncSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Xplit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }

  Future<void> _initializeNotificationService() async {
    try {
      await FriendRequestNotificationService().initialize(navigatorKey: _navigatorKey);
      await ExpenseNotificationService().initialize(navigatorKey: _navigatorKey);
      print('Notification services initialized in main.dart');
    } catch (e) {
      print('Failed to initialize notification services: $e');
    }
  }

  void _startFriendRequestListener() {
    print('Starting friend request listener in main.dart');
    
    _friendRequestSubscription = FirebaseSyncService.startFriendRequestListener().listen(
      (_) {},
      onError: (error) {
        print('Error in friend request listener: $error');
      },
    );
    
    print('Friend request listener started successfully');
  }

  void _startExpenseSyncListener() {
    print('Starting expense sync listener in main.dart');
    
    _expenseSyncSubscription = FirebaseSyncService.startExpenseSyncListener().listen(
      (_) {},
      onError: (error) {
        print('Error in expense sync listener: $error');
      },
    );
    
    print('Expense sync listener started successfully');
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
          return const HomePage();
        }
        
        // If user is not logged in, go to login page
        print('No user logged in, showing login page');
        return const LoginPage();
      },
    );
  }
}
