class ValidationUtils {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _indianPhoneRegex = RegExp(
    r'^[6-9]\d{9}$',
  );

  static final RegExp _policyNumberRegex = RegExp(
    r'^[A-Z]{2,4}\d{8,12}$',
  );

  static final RegExp _uhidRegex = RegExp(
    r'^[A-Z0-9]{6,15}$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,32}$',
  );

  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final phoneToValidate = cleaned.startsWith('91') && cleaned.length == 12
        ? cleaned.substring(2)
        : cleaned;
    if (!_indianPhoneRegex.hasMatch(phoneToValidate)) {
      return 'Please enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  static String? validateOptionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validatePhone(value);
  }

  static String? validateNumeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, [String fieldName = 'This field']) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    return null;
  }

  static String? validateNumberRange(
    String? value, {
    required double min,
    required double max,
    String fieldName = 'This field',
  }) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  static String? validateAmount(
    String? value, {
    double? minAmount,
    double? maxAmount,
    String fieldName = 'Amount',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[,\s₹]'), '');
    final amount = double.tryParse(cleaned);

    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount < 0) {
      return '$fieldName cannot be negative';
    }
    if (minAmount != null && amount < minAmount) {
      return '$fieldName must be at least ₹${minAmount.toStringAsFixed(2)}';
    }
    if (maxAmount != null && amount > maxAmount) {
      return '$fieldName cannot exceed ₹${maxAmount.toStringAsFixed(2)}';
    }
    return null;
  }

  static String? validateDate(String? value, [String fieldName = 'Date']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (DateTime.tryParse(value) == null) {
      return 'Please enter a valid date';
    }
    return null;
  }

  static String? validateFutureDate(String? value, [String fieldName = 'Date']) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    return null;
  }

  static String? validatePastDate(String? value, [String fieldName = 'Date']) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isAfter(DateTime.now())) {
      return '$fieldName must be in the past';
    }
    return null;
  }

  static String? validateDateRange(
    String? value, {
    DateTime? minDate,
    DateTime? maxDate,
    String fieldName = 'Date',
  }) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (minDate != null && date.isBefore(minDate)) {
      return '$fieldName cannot be before ${_formatDate(minDate)}';
    }
    if (maxDate != null && date.isAfter(maxDate)) {
      return '$fieldName cannot be after ${_formatDate(maxDate)}';
    }
    return null;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String? validatePolicyNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Policy number is required';
    }
    final cleaned = value.trim().toUpperCase().replaceAll(RegExp(r'[\s\-/]'), '');
    if (!_policyNumberRegex.hasMatch(cleaned)) {
      return 'Please enter a valid policy number (e.g., ABC12345678)';
    }
    return null;
  }

  static String? validateOptionalPolicyNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validatePolicyNumber(value);
  }

  static String? validateUHID(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UHID/Patient ID is required';
    }
    final cleaned = value.trim().toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
    if (!_uhidRegex.hasMatch(cleaned)) {
      return 'Please enter a valid UHID (6-15 alphanumeric characters)';
    }
    return null;
  }

  static String? validateOptionalUHID(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validateUHID(value);
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 32) {
      return 'Password cannot exceed 32 characters';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, [String fieldName = 'This field']) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
