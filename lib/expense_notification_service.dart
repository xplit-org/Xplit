import 'dart:convert';
import 'package:expenser/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class ExpenseNotificationService {
  ExpenseNotificationService._internal();
  static final ExpenseNotificationService _instance =
      ExpenseNotificationService._internal();
  factory ExpenseNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'expense_notifications_channel',
    'Expense Notifications',
    description: 'Notifications for new split requests and expenses',
    importance: Importance.high,
  );

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isInitialized = false;

  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    if (_isInitialized) return;
    
    _navigatorKey = navigatorKey;

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    try {
      await _fln.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final payload = response.payload;
          if (payload == null) return;
          _openDashboard();
        },
      );

      // Android channel
      await _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);

      _isInitialized = true;
      print('Expense notification service initialized successfully');
    } catch (e) {
      print('Failed to initialize expense notification service: $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      // Request notification permission
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        print('Notification permission granted');
        return true;
      } else if (status.isDenied) {
        print('Notification permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        print('Notification permission permanently denied');
        // Open app settings if permanently denied
        await openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> showExpenseNotification({
    required String amount,
    required String splitBy,
    String? expenseId,
    String? splitTime,
  }) async {
    // Ensure service is initialized
    if (!_isInitialized) {
      print('Expense notification service not initialized');
      return;
    }

    // Request permission if not granted
    final hasPermission = await requestNotificationPermission();
    if (!hasPermission) {
      print('Notification permission not granted');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
        icon: 'ic_notification',
      );
      const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      final payload = jsonEncode({
        'amount': amount,
        'split_by': splitBy,
        'expense_id': expenseId,
        'split_time': splitTime ?? DateTime.now().toIso8601String(),
      });

      await _fln.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        'New Split Request',
        'You owe ₹$amount to $splitBy',
        details,
        payload: payload,
      );
      
      print('Expense notification shown successfully');
    } catch (e) {
      print('Error showing expense notification: $e');
    }
  }

  void _openDashboard() {
    final key = _navigatorKey;
    if (key == null) {
      print('Navigator key is null');
      return;
    }
    
    final navigator = key.currentState;
    if (navigator == null) {
      print('Navigator state is null');
      return;
    }

    try {
      print('Navigating to UserDashboard from expense notification');
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      print('Error navigating to UserDashboard: $e');
    }
  }
} 