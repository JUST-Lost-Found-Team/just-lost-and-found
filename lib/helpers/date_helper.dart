import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class DateHelper {
  static String getTimeAgo(dynamic createdAtData) {
    if (createdAtData == null) return "date_helper.just_now".tr();

    DateTime? postDate;

    if (createdAtData is Timestamp) {
      postDate = createdAtData.toDate();
    } else if (createdAtData is String) {
      postDate = DateTime.tryParse(createdAtData);
    }

    if (postDate == null) return "date_helper.just_now".tr();

    final diff = DateTime.now().difference(postDate);

    if (diff.inDays > 0) {
      return diff.inDays == 1
          ? "date_helper.one_day_ago".tr()
          : "date_helper.days_ago".tr(args: [diff.inDays.toString()]);
    }

    if (diff.inHours > 0) {
      return diff.inHours == 1
          ? "date_helper.one_hour_ago".tr()
          : "date_helper.hours_ago".tr(args: [diff.inHours.toString()]);
    }
    if (diff.inMinutes > 0) {
      return diff.inMinutes == 1
          ? "date_helper.one_minute_ago".tr()
          : "date_helper.minutes_ago".tr(args: [diff.inMinutes.toString()]);
    }

    return "date_helper.just_now".tr();
  }
}
