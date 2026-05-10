import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  }) async {
    final String currentUserId = _auth.currentUser!.uid;

    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'postAttachment': postAttachment,
      'isRead': false,
    };

    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUserId,
      'isRead': false,
    }, SetOptions(merge: true));
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
