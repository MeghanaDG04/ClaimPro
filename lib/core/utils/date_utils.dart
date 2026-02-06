import 'package:intl/intl.dart';

class AppDateUtils {
  static const String defaultFormat = 'dd/MM/yyyy';
  static const String apiFormat = 'yyyy-MM-dd';
  static const String displayFormat = 'dd MMM yyyy';
  static const String fullFormat = 'dd MMMM yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';

  static String formatDate(DateTime? date, [String format = defaultFormat]) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  static String formatToApi(DateTime? date) {
    return formatDate(date, apiFormat);
  }

  static String formatToDisplay(DateTime? date) {
    return formatDate(date, displayFormat);
  }

  static String formatToFull(DateTime? date) {
    return formatDate(date, fullFormat);
  }

  static String formatDateTime(DateTime? dateTime) {
    return formatDate(dateTime, dateTimeFormat);
  }

  static String formatTime(DateTime? dateTime) {
    return formatDate(dateTime, timeFormat);
  }

  static String formatMonthYear(DateTime? date) {
    return formatDate(date, monthYearFormat);
  }

  static DateTime? parseDate(String? dateStr, [String format = defaultFormat]) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return DateFormat(format).parseStrict(dateStr.trim());
    } catch (_) {
      return null;
    }
  }

  static DateTime? parseApiDate(String? dateStr) {
    return parseDate(dateStr, apiFormat);
  }

  static DateTime? tryParseAny(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;

    final formats = [
      apiFormat,
      defaultFormat,
      'dd-MM-yyyy',
      'MM/dd/yyyy',
      'yyyy/MM/dd',
      displayFormat,
      fullFormat,
    ];

    for (final format in formats) {
      final parsed = parseDate(dateStr, format);
      if (parsed != null) return parsed;
    }
    return DateTime.tryParse(dateStr);
  }

  static int calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;

    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  static String getAgeString(DateTime? dateOfBirth) {
    final age = calculateAge(dateOfBirth);
    return '$age ${age == 1 ? 'year' : 'years'}';
  }

  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  static int daysFromNow(DateTime date) {
    return daysBetween(DateTime.now(), date);
  }

  static int daysAgo(DateTime date) {
    return daysBetween(date, DateTime.now());
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isThisWeek(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return !date.isBefore(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)) &&
        !date.isAfter(DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59));
  }

  static bool isThisMonth(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime? date) {
    if (date == null) return false;
    return date.year == DateTime.now().year;
  }

  static String getRelativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return _getFutureRelativeTime(difference.abs());
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  static String _getFutureRelativeTime(Duration difference) {
    if (difference.inSeconds < 60) {
      return 'In a moment';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'In $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'In $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'Tomorrow';
      return 'In $days days';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'In $months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'In $years ${years == 1 ? 'year' : 'years'}';
    }
  }

  static bool isDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  static bool isValidDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return false;
    return !endDate.isBefore(startDate);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  static List<DateTime> getDateRange(DateTime startDate, DateTime endDate) {
    final dates = <DateTime>[];
    var current = startOfDay(startDate);
    final end = startOfDay(endDate);

    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }
}
