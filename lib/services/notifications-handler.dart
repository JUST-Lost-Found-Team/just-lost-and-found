import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/features/chat/chat_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationHandler {
  static String? pendingChatId;
  static String? pendingChatName;

  static String? currentActiveChatId;

  static Future<void> initialize() async {
    OneSignal.initialize("80685565-c7a3-4f1c-bbda-2020c30857f4");
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['senderId'] == currentActiveChatId) {
        event.preventDefault();
      }
    });

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['senderId'] != null) {
        pendingChatId = data['senderId'];
        pendingChatName = data['senderName'];
      }
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      OneSignal.login(currentUser.uid);
    }
  }

  static void setup(BuildContext context) {
    _handleNotificationNavigation(context);

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['senderId'] != null) {
        pendingChatId = data['senderId'];
        pendingChatName = data['senderName'];
        _handleNotificationNavigation(context);
      }
    });
  }

  static void _handleNotificationNavigation(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingChatId != null) {
        String chatId = pendingChatId!;
        String chatName = pendingChatName ?? "User";

        pendingChatId = null;
        pendingChatName = null;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(receiverId: chatId, receiverName: chatName),
          ),
        );
      }
    });
  }
}
