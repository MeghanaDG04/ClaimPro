/// Application-wide constants for the Insurance Claim Management App
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Insurance Claim Manager';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String companyName = 'Insurance Solutions Pvt. Ltd.';
  static const String companyEmail = 'support@insurancesolutions.com';
  static const String companyPhone = '+91 1800-XXX-XXXX';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int initialPage = 1;

  // Date/Time Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss";
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayDateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const int currencyDecimalPlaces = 2;

  // File Size Limits (in bytes)
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10 MB
  static const int maxTotalUploadSize = 50 * 1024 * 1024; // 50 MB

  // Allowed File Types
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  // Animation Durations (in milliseconds)
  static const int animationDurationFast = 150;
  static const int animationDurationNormal = 300;
  static const int animationDurationSlow = 500;
  static const int splashDuration = 2000;
  static const int snackBarDuration = 3000;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxClaimDescriptionLength = 1000;
  static const int maxNotesLength = 500;

  // Claim Limits
  static const double minClaimAmount = 100.0;
  static const double maxClaimAmount = 10000000.0; // 1 Crore
}
