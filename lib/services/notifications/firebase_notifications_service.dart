import 'dart:async';
import 'dart:convert';

import 'package:Medito/utils/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../models/notification/notification_payload_model.dart';
import '../../providers/events/analytics_configurator.dart';
import '../../routes/routes.dart';
import '../../views/bottom_navigation/bottom_navigation_bar_view.dart';

final firebaseMessagingProvider = Provider<FirebaseMessagingHandler>((ref) {
  return FirebaseMessagingHandler();
});

class FirebaseMessagingHandler {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context, WidgetRef ref) async {
    try {
      await _configureFirebaseMessaging(context, ref);
      await _initializeLocalNotifications(context, ref);
      await updateAnalyticsCollectionBasedOnConsent();
      await FirebaseAnalytics.instance.setUserId(id: 'medito_user');
    } catch (e) {
      unawaited(Sentry.captureException(e));
    }
  }

  void onFirebaseMessageAppOpened(BuildContext context, WidgetRef ref) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message, context, ref);
    });
  }

  Future<void> _configureFirebaseMessaging(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // await _messaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage
        .listen((message) => _handleForegroundMessage(message, context, ref));
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _handleMessageOpenedApp(message, context, ref));
    onFirebaseMessageAppOpened(context, ref);
  }

  Future<void> _initializeLocalNotifications(
    BuildContext context,
    WidgetRef ref,
  ) async {
    const initializationSettingsAndroid = AndroidInitializationSettings('logo');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          final data = json.decode(payload);
          _navigate(context, ref, data);
        }
      },
    );
  }

  void _handleForegroundMessage(
    RemoteMessage message,
    BuildContext context,
    WidgetRef ref,
  ) {
    final snackBar = SnackBar(
      content: Text(message.notification?.body ?? 'New message'),
      action: SnackBarAction(
        label: 'View',
        onPressed: () {
          _navigate(context, ref, message.data);
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _showBackgroundNotification(RemoteMessage message) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'firebase_messaging_channel',
      'Firebase Messaging',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  void _handleMessageOpenedApp(
    RemoteMessage message,
    BuildContext context,
    WidgetRef ref,
  ) {
    _navigate(context, ref, message.data);
  }

  void _navigate(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
    var payload = NotificationPayloadModel.fromJson(data);

    if (payload.type?.isNotNullAndNotEmpty() == true) {
      handleNavigation(
        payload.type,
        [payload.id.toString().getIdFromPath(), payload.path],
        context,
        ref: ref,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BottomNavigationBarView(),
        ),
      );
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final handler = FirebaseMessagingHandler();
  await handler._showBackgroundNotification(message);
}