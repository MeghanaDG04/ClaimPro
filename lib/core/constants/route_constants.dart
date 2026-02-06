/// Route path constants for navigation
class RouteConstants {
  RouteConstants._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main Routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';

  // Claim Routes
  static const String claims = '/claims';
  static const String createClaim = '/claims/create';
  static const String editClaim = '/claims/edit';
  static const String claimDetails = '/claims/details';

  // Bill Routes
  static const String bills = '/bills';
  static const String addBill = '/bills/add';
  static const String editBill = '/bills/edit';
  static const String billDetails = '/bills/details';

  // Advance Routes
  static const String advances = '/advances';
  static const String requestAdvance = '/advances/request';
  static const String advanceDetails = '/advances/details';

  // Settlement Routes
  static const String settlement = '/settlement';
  static const String settlementDetails = '/settlement/details';

  // Profile & Settings
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Reports
  static const String reports = '/reports';
  static const String claimReport = '/reports/claim';

  // Helper method to build route with parameters
  static String claimDetailsWithId(String id) => '$claimDetails/$id';
  static String editClaimWithId(String id) => '$editClaim/$id';
  static String billDetailsWithId(String id) => '$billDetails/$id';
  static String editBillWithId(String id) => '$editBill/$id';
  static String advanceDetailsWithId(String id) => '$advanceDetails/$id';
}
