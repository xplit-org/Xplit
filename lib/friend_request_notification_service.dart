import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'user_dashboard.dart';

class FriendRequestNotificationService {
  FriendRequestNotificationService._internal();
  static final FriendRequestNotificationService _instance =
      FriendRequestNotificationService._internal();
  factory FriendRequestNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'friend_requests_channel',
    'Friend Requests',
    description: 'Notifications for new friend requests',
    importance: Importance.high,
  );

  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
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

    await _fln.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload == null) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _openDashboard();
        } catch (_) {
          _openDashboard();
        }
      },
    );

    // Android channel
    await _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);

    // Android 13+ runtime permission
    await _fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showFriendRequestNotification({
    required String name,
    required String mobile,
    String? receiverMobile,
    String? createdAtIso,
  }) async {
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
      'name': name,
      'mobile': mobile,
      'receiver': receiverMobile,
      'created_at': createdAtIso ?? DateTime.now().toIso8601String(),
    });

    await _fln.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'New friend request',
      '$name • $mobile',
      details,
      payload: payload,
    );
  }

  void _openDashboard() {
    final key = _navigatorKey;
    if (key == null) return;
    final navigator = key.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => const UserDashboard(),
      ),
    );
  }
}

