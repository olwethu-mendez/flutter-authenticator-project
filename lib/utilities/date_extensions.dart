import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime? {
  /// Converts DateTime to "21 Dec 2025" or returns "N/A" if null
  String toReadableDate() {
    if (this == null) return "N/A";
    
    // .toLocal() ensures it matches the user's timezone
    return DateFormat('dd MMM yyyy').format(this!.toLocal());
  }

  /// Converts DateTime to "21/12/2025"
  String toNumericDate() {
    if (this == null) return "N/A";
    return DateFormat('dd/MM/yyyy').format(this!.toLocal());
  }

  /// Converts DateTime to time ago format
  String timeAgo() {
    if (this == null) return "N/A";
    
    final date = this!.toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()} years ago";
    } else if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} months ago";
    } else if (difference.inDays > 7) {
      return "${(difference.inDays / 7).floor()} weeks ago";
    } else if (difference.inDays >= 1) {
      return "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago";
    } else {
      return "Just now";
    }
  }
}