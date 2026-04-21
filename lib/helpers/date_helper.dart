import 'package:cloud_firestore/cloud_firestore.dart';

class DateHelper {
  static String getTimeAgo(dynamic createdAtData) {
    if (createdAtData == null) return "Just now";

    DateTime? postDate;

    if (createdAtData is Timestamp) {
      postDate = createdAtData.toDate();
    } else if (createdAtData is String) {
      postDate = DateTime.tryParse(createdAtData);
    }

    if (postDate == null) return "Just now";

    final diff = DateTime.now().difference(postDate);

    if (diff.inDays > 0) {
      return diff.inDays == 1 ? "1 day ago" : "${diff.inDays} days ago";
    }

    if (diff.inHours > 0) {
      return diff.inHours == 1 ? "1 hour ago" : "${diff.inHours} hours ago";
    }

    if (diff.inMinutes > 0) {
      return diff.inMinutes == 1
          ? "1 minute ago"
          : "${diff.inMinutes} minutes ago";
    }

    return "Just now";
  }
}
