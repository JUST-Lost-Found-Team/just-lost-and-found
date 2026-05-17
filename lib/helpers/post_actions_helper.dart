import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/edit_post_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class PostActionsHelper {
  static void markAsResolved(
    BuildContext context,
    String docId, {
    VoidCallback? onSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: ThemeManager.successGreen,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                "post_actions.mark_resolved_title".tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text("post_actions.mark_resolved_content".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "post_actions.cancel_btn".tr(),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(docId)
                      .update({'isResolved': true});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("post_actions.snack_resolved".tr()),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ThemeManager.successGreen,
                      ),
                    );

                    if (onSuccess != null) {
                      onSuccess();
                    }
                  }
                } catch (e) {
                  debugPrint("Error resolving post: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.successGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "post_actions.confirm_btn".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void deletePost(
    BuildContext context,
    String docId, {
    VoidCallback? onSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: ThemeManager.errorRed,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "post_actions.delete_title".tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text("post_actions.delete_content".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "post_actions.cancel_btn".tr(),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(docId)
                      .delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Post deleted successfully"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ThemeManager.errorRed,
                      ),
                    );

                    if (onSuccess != null) {
                      onSuccess();
                    }
                  }
                } catch (e) {
                  debugPrint("Error deleting post: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "post_actions.delete_btn".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void editPost(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(postData: data, postId: docId),
      ),
    );
  }
}
