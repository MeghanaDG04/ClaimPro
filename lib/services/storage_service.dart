import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/claim_model.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _claimsKey = 'claims_data';
  static const String _draftClaimKey = 'draft_claim';
  static const String _themeModeKey = 'theme_mode';
  static const String _isLoggedInKey = 'is_logged_in';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // User persistence methods
  static Future<void> saveUser(UserModel user) async {
    try {
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw StorageException('Failed to save user: $e');
    }
  }

  static UserModel? getUser() {
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    try {
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw StorageException('Failed to clear user: $e');
    }
  }

  static bool isLoggedIn() {
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Claims persistence methods
  static Future<void> saveClaims(List<ClaimModel> claims) async {
    try {
      final claimsJson = claims.map((c) => c.toJson()).toList();
      await prefs.setString(_claimsKey, jsonEncode(claimsJson));
    } catch (e) {
      throw StorageException('Failed to save claims: $e');
    }
  }

  static List<ClaimModel> getClaims() {
    final claimsJson = prefs.getString(_claimsKey);
    if (claimsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(claimsJson);
      return decoded.map((c) => ClaimModel.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  static ClaimModel? getClaimById(String id) {
    final claims = getClaims();
    try {
      return claims.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveClaim(ClaimModel claim) async {
    final claims = getClaims();
    final index = claims.indexWhere((c) => c.id == claim.id);
    if (index >= 0) {
      claims[index] = claim;
    } else {
      claims.add(claim);
    }
    await saveClaims(claims);
  }

  static Future<void> deleteClaim(String id) async {
    final claims = getClaims();
    claims.removeWhere((c) => c.id == id);
    await saveClaims(claims);
  }

  // Draft claim persistence methods
  static Future<void> saveDraft(ClaimModel draft) async {
    try {
      await prefs.setString(_draftClaimKey, jsonEncode(draft.toJson()));
    } catch (e) {
      throw StorageException('Failed to save draft: $e');
    }
  }

  static ClaimModel? getDraft() {
    final draftJson = prefs.getString(_draftClaimKey);
    if (draftJson == null) return null;
    try {
      return ClaimModel.fromJson(jsonDecode(draftJson));
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearDraft() async {
    try {
      await prefs.remove(_draftClaimKey);
    } catch (e) {
      throw StorageException('Failed to clear draft: $e');
    }
  }

  static bool hasDraft() {
    return prefs.getString(_draftClaimKey) != null;
  }

  // Theme persistence methods
  static Future<void> saveThemeMode(bool isDark) async {
    await prefs.setBool(_themeModeKey, isDark);
  }

  static bool getThemeMode() {
    return prefs.getBool(_themeModeKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
