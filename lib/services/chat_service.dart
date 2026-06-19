import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage(
    String receiverId,
    String message, {
    Map<String, dynamic>? postAttachment,
    String? imageUrl,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;

    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'postAttachment': postAttachment,
      'imageUrl': imageUrl,
      'isRead': false,
    };

    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    String displayLastMessage = message.isNotEmpty
        ? message
        : (imageUrl != null ? "📷 Photo" : "");

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': displayLastMessage,
      'timestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUserId,
      'isRead': false,
    }, SetOptions(merge: true));
    _sendPushNotification(receiverId, displayLastMessage, currentUserId);
  }

  Future<void> _sendPushNotification(
    String receiverId,
    String message,
    String currentUserId,
  ) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      String senderName = "User";
      if (userDoc.exists) {
        senderName = (userDoc.data() as Map<String, dynamic>)['name'] ?? "User";
      }

      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',

          'Authorization':
              'Basic os_v2_app_qbufkzohunhrzo62eaqmgccx6twukccitmuuua4vi7pw7xf42jjaykqxlc56r4zwflffpou4gcc3p63nscx6fr6ruej2zy7pnyj6l2i',
        },
        body: jsonEncode({
          'app_id': '80685565-c7a3-4f1c-bbda-2020c30857f4',
          'target_channel': 'push',
          'include_aliases': {
            'external_id': [receiverId],
          },
          'headings': {'en': senderName, 'ar': senderName},
          'contents': {'en': message, 'ar': message},
          'data': {'senderId': currentUserId, 'senderName': senderName},
        }),
      );
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    String chatRoomId = getChatRoomId(userId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
