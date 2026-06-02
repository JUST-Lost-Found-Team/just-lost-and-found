import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/date_helper.dart';
import 'package:just_lost_and_found/features/posts/post_details.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);
    return Scaffold(
      //backgroundColor: const Color(0xFFD5D5D5),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "notifications.title".tr(),
          style: const TextStyle(
            // color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeManager.primaryBlue),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "notifications.empty".tr(),
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool isRead = data['isRead'] ?? false;
              final String postId = data['postId'] ?? '';
              final Timestamp? createdAt = data['createdAt'];

              String displayMessage = data['message'] ?? '';

              final int daysPassed = data['daysPassed'] ?? 5;

              if (data['type'] == 'lost') {
                displayMessage = "notifications.lost_prompt".tr(
                  namedArgs: {
                    'item': data['itemName'] ?? '',
                    'days': daysPassed.toString(),
                  },
                );
              } else if (data['type'] == 'found') {
                displayMessage = "notifications.found_prompt".tr(
                  namedArgs: {
                    'item': data['itemName'] ?? '',
                    'days': daysPassed.toString(),
                  },
                );
              }

              return GestureDetector(
                onTap: () async {
                  if (!isRead) {
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(doc.id)
                        .update({'isRead': true});
                  }

                  if (postId.isNotEmpty && context.mounted) {
                    final postDoc = await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .get();
                    if (postDoc.exists && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailsScreen(
                            post: postDoc.data() as Map<String, dynamic>,
                            postId: postId,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isRead
                        ? theme.brightness == Brightness.dark
                              ? theme.cardColor
                              : Colors.grey.shade200
                        : theme.popupMenuTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: isRead
                        ? null
                        : Border.all(
                            color: ThemeManager.primaryYellow,
                            width: 1.5,
                          ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? Colors.grey[200]
                          : ThemeManager.primaryBlue.withOpacity(0.1),
                      child: Icon(
                        Icons.notifications_active,
                        color: isRead
                            ? Colors.grey
                            : ThemeManager.primaryYellow,
                      ),
                    ),
                    title: Text(
                      displayMessage,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        //  color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      createdAt != null
                          ? DateHelper.getTimeAgo(createdAt)
                          : "notifications.just_now".tr(),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
