import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  /// Example:
  /// Just now
  /// 5 min ago
  /// 2 hours ago
  /// Yesterday
  /// Monday
  /// 25 Jun 2026
  static String timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "-";

    final date = timestamp.toDate();
    final now = DateTime.now();

    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return "Just now";
    }

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    }

    if (difference.inHours < 24) {
      return "${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago";
    }

    if (difference.inDays == 1) {
      return "Yesterday";
    }

    if (difference.inDays < 7) {
      return DateFormat("EEEE").format(date);
    }

    return DateFormat("dd MMM yyyy").format(date);
  }

  /// Example:
  /// 27 Jun 2026 • 2:35 PM
  static String fullDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";

    return DateFormat("dd MMM yyyy • hh:mm a").format(timestamp.toDate());
  }

  /// Example:
  /// 2:35 PM
  static String timeOnly(Timestamp? timestamp) {
    if (timestamp == null) return "-";

    return DateFormat("hh:mm a").format(timestamp.toDate());
  }

  /// Example:
  /// 27 Jun 2026
  static String dateOnly(Timestamp? timestamp) {
    if (timestamp == null) return "-";

    return DateFormat("dd MMM yyyy").format(timestamp.toDate());
  }
}
