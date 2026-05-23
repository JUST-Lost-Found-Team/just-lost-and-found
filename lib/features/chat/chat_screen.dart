import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_lost_and_found/features/posts/post_details.dart';
import 'package:just_lost_and_found/services/chat_service.dart';
import 'package:just_lost_and_found/services/notifications-handler.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:just_lost_and_found/services/cloudinary_service.dart';

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
  bool _isUploadingImage = false;
  File? _selectedImageFile;
  @override
  void initState() {
    super.initState();
    _attachedPost = widget.postData;
    NotificationHandler.currentActiveChatId = widget.receiverId;
  }

  @override
  void dispose() {
    NotificationHandler.currentActiveChatId = null;
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImageFile == null)
      return;

    String msgText = _messageController.text.trim();
    String? imageUrl;

    if (_selectedImageFile != null) {
      setState(() => _isUploadingImage = true);
      try {
        Cloudinary cloudinary = Cloudinary();
        imageUrl = await cloudinary.uploadToCloudinary(_selectedImageFile!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error uploading image"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isUploadingImage = false);
        return;
      }
    }

    await _chatService.sendMessage(
      widget.receiverId,
      msgText,
      postAttachment: _attachedPost,
      imageUrl: imageUrl,
    );

    _messageController.clear();
    setState(() {
      _attachedPost = null;
      _selectedImageFile = null;
      _isUploadingImage = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: ThemeManager.primaryBlue,
                ),
                title: Text(
                  "add_post.take_a_photo".tr(),
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ThemeManager.primaryBlue,
                ),
                title: Text(
                  "add_post.choose_from_gallery".tr(),
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
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
          if (_isUploadingImage)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: LinearProgressIndicator(color: ThemeManager.primaryYellow),
            ),
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
    final theme = Theme.of(context);
    bool isMe = data['senderId'] == _auth.currentUser!.uid;
    Map<String, dynamic>? attachedProduct = data['postAttachment'];
    bool isRead = data['isRead'] ?? false;
    String? imageUrl = data['imageUrl'];
    String msgText = data['message'] ?? '';
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
                            backgroundColor: ThemeManager.errorRed,
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
                            backgroundColor: ThemeManager.successGreen,
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
            if (imageUrl != null && imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 220,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 220,
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                if (msgText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 12.0,
                      bottom: 2.0,
                    ),
                    child: Text(
                      msgText,
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
    final theme = Theme.of(context);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImageFile != null)
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    top: 8,
                  ),
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_selectedImageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                if (!_isUploadingImage)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImageFile = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  color: ThemeManager.primaryBlue,
                  onPressed: _isUploadingImage ? null : _showImageOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      fillColor: theme.cardColor,
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
                    onPressed: _isUploadingImage ? null : sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
