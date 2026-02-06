/// API-related constants and endpoints
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = 'https://api.example.com/v1';
  static const String stagingUrl = 'https://staging-api.example.com/v1';
  static const String localUrl = 'http://localhost:3000/api/v1';

  // API Versioning
  static const String apiVersion = 'v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/users/change-password';

  // Claims Endpoints
  static const String claims = '/claims';
  static const String claimById = '/claims/{id}';
  static const String claimsByStatus = '/claims/status/{status}';
  static const String submitClaim = '/claims/{id}/submit';
  static const String approveClaim = '/claims/{id}/approve';
  static const String rejectClaim = '/claims/{id}/reject';

  // Bills Endpoints
  static const String bills = '/bills';
  static const String billById = '/bills/{id}';
  static const String billsByClaimId = '/claims/{claimId}/bills';
  static const String verifyBill = '/bills/{id}/verify';
  static const String uploadBillDocument = '/bills/{id}/documents';

  // Advance Endpoints
  static const String advances = '/advances';
  static const String advanceById = '/advances/{id}';
  static const String advancesByClaimId = '/claims/{claimId}/advances';
  static const String approveAdvance = '/advances/{id}/approve';
  static const String disburseAdvance = '/advances/{id}/disburse';

  // Settlement Endpoints
  static const String settlements = '/settlements';
  static const String settlementById = '/settlements/{id}';
  static const String settlementByClaimId = '/claims/{claimId}/settlement';
  static const String calculateSettlement = '/claims/{claimId}/calculate-settlement';

  // Document Endpoints
  static const String documents = '/documents';
  static const String uploadDocument = '/documents/upload';
  static const String documentById = '/documents/{id}';
  static const String downloadDocument = '/documents/{id}/download';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Reports Endpoints
  static const String reports = '/reports';
  static const String claimSummaryReport = '/reports/claim-summary';
  static const String settlementReport = '/reports/settlement';

  // Helper methods to build URLs with parameters
  static String getClaimById(String id) => claimById.replaceAll('{id}', id);
  static String getBillById(String id) => billById.replaceAll('{id}', id);
  static String getAdvanceById(String id) => advanceById.replaceAll('{id}', id);
  static String getSettlementById(String id) => settlementById.replaceAll('{id}', id);
  static String getDocumentById(String id) => documentById.replaceAll('{id}', id);
  static String getBillsByClaimId(String claimId) =>
      billsByClaimId.replaceAll('{claimId}', claimId);
  static String getAdvancesByClaimId(String claimId) =>
      advancesByClaimId.replaceAll('{claimId}', claimId);
  static String getSettlementByClaimId(String claimId) =>
      settlementByClaimId.replaceAll('{claimId}', claimId);

  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';
}
