import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/post_details.dart';
import 'package:just_lost_and_found/services/chat_service.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final Map<String, dynamic>? postData;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.postData,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _attachedPost;

  @override
  void initState() {
    super.initState();
    _attachedPost = widget.postData;
  }

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String msgText = _messageController.text.trim();
      _messageController.clear();

      await _chatService.sendMessage(
        widget.receiverId,
        msgText,
        postAttachment: _attachedPost,
      );

      if (_attachedPost != null) {
        setState(() {
          _attachedPost = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5D5D5),
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        _auth.currentUser!.uid,
        widget.receiverId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("chat_screen.error_fetching".tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: ThemeManager.primaryBlue),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "chat_screen.say_hi".tr(),
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final messages = snapshot.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bool needsRoomUpdate = false;

          for (var doc in messages) {
            final msgData = doc.data() as Map<String, dynamic>;

            if (msgData['senderId'] != _auth.currentUser!.uid &&
                msgData['isRead'] == false) {
              doc.reference.update({'isRead': true});
              needsRoomUpdate = true;
            }
          }

          if (needsRoomUpdate) {
            List<String> ids = [_auth.currentUser!.uid, widget.receiverId];
            ids.sort();
            String chatRoomId = ids.join("_");

            FirebaseFirestore.instance
                .collection('chat_rooms')
                .doc(chatRoomId)
                .update({'isRead': true});
          }
        });
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(data);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    bool isMe = data['senderId'] == _auth.currentUser!.uid;
    Map<String, dynamic>? attachedProduct = data['postAttachment'];
    bool isRead = data['isRead'] ?? false;

    String timeString = "";
    if (data['timestamp'] != null) {
      DateTime msgDate = (data['timestamp'] as Timestamp).toDate();
      DateTime now = DateTime.now();

      int hour = msgDate.hour > 12
          ? msgDate.hour - 12
          : (msgDate.hour == 0 ? 12 : msgDate.hour);
      String amPm = msgDate.hour >= 12 ? "PM" : "AM";
      String minute = msgDate.minute.toString().padLeft(2, '0');
      String timeOnly = "$hour:$minute $amPm";

      DateTime justMsgDate = DateTime(msgDate.year, msgDate.month, msgDate.day);
      DateTime justNow = DateTime(now.year, now.month, now.day);

      int differenceInDays = justNow.difference(justMsgDate).inDays;

      if (differenceInDays == 0) {
        timeString = timeOnly;
      } else if (differenceInDays == 1) {
        timeString = "chat_screen.yesterday_time".tr(args: [timeOnly]);
      } else {
        timeString =
            "${msgDate.day}/${msgDate.month}/${msgDate.year}, $timeOnly";
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 8),
        decoration: BoxDecoration(
          color: isMe ? ThemeManager.primaryBlue : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachedProduct != null)
              StreamBuilder<DocumentSnapshot>(
                stream: attachedProduct['postId'] != null
                    ? FirebaseFirestore.instance
                          .collection('posts')
                          .doc(attachedProduct['postId'])
                          .snapshots()
                    : null,
                builder: (context, snapshot) {
                  bool isDeleted = false;
                  bool isResolved = false;
                  Map<String, dynamic> livePostData = attachedProduct;

                  if (snapshot.connectionState == ConnectionState.active) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      isDeleted = true;
                    } else {
                      livePostData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      isResolved = livePostData['isResolved'] ?? false;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "chat_screen.snack_post_deleted".tr(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (isResolved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "chat_screen.snack_post_resolved".tr(),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      if (attachedProduct['postId'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsScreen(
                              post: livePostData,
                              postId: attachedProduct['postId'],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDeleted
                            ? Colors.grey.shade500
                            : (isMe
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: isDeleted
                                ? Container(
                                    width: 45,
                                    height: 45,
                                    color: Colors.grey.shade400,
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  )
                                : (livePostData['images'] != null &&
                                          (livePostData['images'] as List)
                                              .isNotEmpty
                                      ? Image.network(
                                          livePostData['images'][0],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 45,
                                          height: 45,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 24,
                                            color: Colors.grey,
                                          ),
                                        )),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDeleted
                                    ? "chat_screen.post_deleted_title".tr()
                                    : (livePostData['title'] ??
                                          'chat_screen.default_item_title'
                                              .tr()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDeleted
                                      ? Colors.grey.shade600
                                      : ThemeManager.primaryBlue,
                                  fontSize: 13,
                                  decoration: isDeleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              if (!isDeleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isResolved
                                        ? Colors.blueGrey.withOpacity(0.2)
                                        : (livePostData['status'] == 'Found'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isResolved
                                        ? "chat_screen.resolved_status".tr()
                                        : (livePostData['status'] ?? ''),
                                    style: TextStyle(
                                      color: isResolved
                                          ? Colors.blueGrey[800]
                                          : (livePostData['status'] == 'Found'
                                                ? Colors.green[800]
                                                : Colors.red[800]),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 12.0,
                    bottom: 2.0,
                  ),
                  child: Text(
                    data['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 15,
                        color: isRead
                            ? ThemeManager.primaryYellow
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  fillColor: Colors.grey[300],
                  hintText: "chat_screen.type_message_hint".tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: ThemeManager.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
