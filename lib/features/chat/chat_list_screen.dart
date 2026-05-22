import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_lost_and_found/features/chat/chat_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('users', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasError) {
            return Center(child: Text("chat_list.error_fetching".tr()));
          }
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeManager.primaryBlue),
            );
          }

          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "chat_list.no_messages".tr(),
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final rawChats = streamSnapshot.data!.docs;

          final chats = rawChats.toList();
          chats.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final Timestamp? timeA = aData['timestamp'] as Timestamp?;
            final Timestamp? timeB = bData['timestamp'] as Timestamp?;

            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;

            return timeB.compareTo(timeA);
          });

          List<Future<DocumentSnapshot>> userFutures = [];
          for (var chatDoc in chats) {
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final List users = chatData['users'] ?? [];
            final String otherUserId = users.firstWhere(
              (id) => id != currentUserId,
              orElse: () => "",
            );

            if (otherUserId.isNotEmpty) {
              userFutures.add(
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
              );
            }
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(userFutures),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ThemeManager.primaryBlue,
                  ),
                );
              }

              if (!futureSnapshot.hasData) return const SizedBox.shrink();

              final usersData = {
                for (var doc in futureSnapshot.data!)
                  doc.id: doc.data() as Map<String, dynamic>?,
              };

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chatDoc = chats[index];
                  final chatData = chatDoc.data() as Map<String, dynamic>;

                  final List users = chatData['users'] ?? [];

                  final String otherUserId = users.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => "",
                  );

                  if (otherUserId.trim().isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final userData = usersData[otherUserId];
                  if (userData == null) return const SizedBox.shrink();

                  final String otherUserName =
                      userData['name'] ?? "chat_list.default_user".tr();
                  final String otherUserImage = userData['profileImage'] ?? "";

                  final String lastSenderId =
                      chatData['lastMessageSenderId'] ?? "";
                  final bool isRead = chatData['isRead'] ?? true;
                  final bool hasUnreadMessages =
                      (lastSenderId != currentUserId) && !isRead;

                  String timeString = "";
                  if (chatData['timestamp'] != null) {
                    DateTime msgDate = (chatData['timestamp'] as Timestamp)
                        .toDate();
                    DateTime now = DateTime.now();

                    int hour = msgDate.hour > 12
                        ? msgDate.hour - 12
                        : (msgDate.hour == 0 ? 12 : msgDate.hour);
                    String amPm = msgDate.hour >= 12 ? "PM" : "AM";
                    String minute = msgDate.minute.toString().padLeft(2, '0');
                    String timeOnly = "$hour:$minute $amPm";

                    DateTime justMsgDate = DateTime(
                      msgDate.year,
                      msgDate.month,
                      msgDate.day,
                    );
                    DateTime justNow = DateTime(now.year, now.month, now.day);

                    int differenceInDays = justNow
                        .difference(justMsgDate)
                        .inDays;

                    if (differenceInDays == 0) {
                      timeString = timeOnly;
                    } else if (differenceInDays == 1) {
                      timeString = "chat_list.yesterday".tr();
                    } else {
                      timeString =
                          "${msgDate.day}/${msgDate.month}/${msgDate.year}";
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: hasUnreadMessages
                          ? theme.popupMenuTheme.color
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: otherUserImage.isNotEmpty
                            ? CachedNetworkImageProvider(otherUserImage)
                            : null,
                        child: otherUserImage.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 28,
                              )
                            : null,
                      ),
                      title: Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight: hasUnreadMessages
                              ? FontWeight.w900
                              : FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Builder(
                        builder: (context) {
                          String prefix = "";
                          if (lastSenderId == currentUserId) {
                            prefix = "chat_list.you_prefix".tr();
                          } else if (lastSenderId.isNotEmpty) {
                            final firstName = otherUserName.split(" ")[0];
                            prefix = "$firstName: ";
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "$prefix${chatData['lastMessage'] ?? ''}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: hasUnreadMessages
                                    ? theme.textTheme.titleMedium!.color
                                    : Colors.grey.shade600,
                                fontWeight: hasUnreadMessages
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),

                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (timeString.isNotEmpty)
                            Text(
                              timeString,
                              style: TextStyle(
                                color: hasUnreadMessages
                                    ? theme.primaryColor
                                    : Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: hasUnreadMessages
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          if (hasUnreadMessages) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: ThemeManager.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        if (hasUnreadMessages) {
                          FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .doc(chatDoc.id)
                              .update({'isRead': true});
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: otherUserId,
                              receiverName: otherUserName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
