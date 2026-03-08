class FormValidations {
  static String? validateRequiredMin3(String value, {String fieldName = "Field"}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "$fieldName is required";
    if (trimmed.length < 3) return "$fieldName must be at least 3 characters";
    return null;
  }

  static String? validateName(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "Name is required";
    if (trimmed.length < 3) return "Name must be at least 3 characters";
    return null;
  }

  static String? validateEmail(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "Email is required";
    final RegExp emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailRegex.hasMatch(trimmed)) return "Enter a valid email address";
    return null;
  }

  static String? validatePassword(String value, {int minLength = 8}) {
    if (value.isEmpty) return "Password is required";
    if (value.length < minLength) {
      return "Password must be at least $minLength characters";
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return "Confirm password is required";
    if (confirm != password) return "Passwords do not match";
    return null;
  }

  static String? validateRequired(String value, {String fieldName = "Field"}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "$fieldName is required";
    return null;
  }

  static String? validateRequiredNumber(String value, {String fieldName = "Field"}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "$fieldName is required";
    final num? parsed = num.tryParse(trimmed);
    if (parsed == null) return "$fieldName must be a number";
    if (parsed <= 0) return "$fieldName must be greater than 0";
    return null;
  }

  static String? validateRequiredMinMax(
    String value, {
    required String fieldName,
    int min = 1,
    int? max,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "$fieldName is required";
    if (trimmed.length < min) {
      return "$fieldName must be at least $min characters";
    }
    if (max != null && trimmed.length > max) {
      return "$fieldName cannot exceed $max characters";
    }
    return null;
  }

  static String? validateOptionalMaxLength(
    String value, {
    required String fieldName,
    required int max,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > max) {
      return "$fieldName cannot exceed $max characters";
    }
    return null;
  }

  static String? validateOptionalMinMax(
    String value, {
    required String fieldName,
    int min = 1,
    int? max,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length < min) {
      return "$fieldName must be at least $min characters";
    }
    if (max != null && trimmed.length > max) {
      return "$fieldName cannot exceed $max characters";
    }
    return null;
  }

  static String? validateOptionalEmail(
    String value, {
    int maxLength = 80,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > maxLength) {
      return "Email address cannot exceed $maxLength characters";
    }
    final RegExp emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailRegex.hasMatch(trimmed)) return "Enter a valid email address";
    return null;
  }

  static String? validatePhoneNumber(
    String value, {
    String fieldName = "Phone number",
    int minDigits = 10,
    int maxDigits = 15,
    bool required = true,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return required ? "$fieldName is required" : null;
    }

    final RegExp phoneRegex = RegExp(r'^[\d+\-\s()]+$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return "Enter a valid ${fieldName.toLowerCase()}";
    }

    final String digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < minDigits) {
      return "$fieldName must be at least $minDigits digits";
    }
    if (digitsOnly.length > maxDigits) {
      return "$fieldName cannot exceed $maxDigits digits";
    }
    return null;
  }

  static String? validateTaxNumber(
    String value, {
    String fieldName = "Tax Number (NTN / GST)",
    int minLength = 3,
    int maxLength = 30,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "$fieldName is required";
    if (trimmed.length < minLength) return "$fieldName is too short";
    if (trimmed.length > maxLength) {
      return "$fieldName cannot exceed $maxLength characters";
    }
    final RegExp taxRegex = RegExp(r'^[a-zA-Z0-9\-/]+$');
    if (!taxRegex.hasMatch(trimmed)) {
      return "$fieldName can contain letters, numbers, - and / only";
    }
    return null;
  }

  // Common reusable validators used across forms.
  static String? validateCommonName(
    String value, {
    String fieldName = "Name",
    int minLength = 3,
    int maxLength = 60,
  }) {
    return validateRequiredMinMax(
      value,
      fieldName: fieldName,
      min: minLength,
      max: maxLength,
    );
  }

  static String? validateCommonPhoneNumber(
    String value, {
    String fieldName = "Phone number",
    bool required = true,
    int minDigits = 10,
    int maxDigits = 15,
  }) {
    return validatePhoneNumber(
      value,
      fieldName: fieldName,
      required: required,
      minDigits: minDigits,
      maxDigits: maxDigits,
    );
  }

  static String? validateCommonEmail(
    String value, {
    bool required = false,
    int maxLength = 80,
  }) {
    final String trimmed = value.trim();
    if (required) {
      if (trimmed.isEmpty) return "Email is required";
      if (trimmed.length > maxLength) {
        return "Email address cannot exceed $maxLength characters";
      }
      final RegExp emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
      if (!emailRegex.hasMatch(trimmed)) return "Enter a valid email address";
      return null;
    }
    return validateOptionalEmail(value, maxLength: maxLength);
  }

  static String? validateCommonTaxNumber(
    String value, {
    String fieldName = "Tax Number (NTN / GST)",
    int minLength = 3,
    int maxLength = 30,
  }) {
    return validateTaxNumber(
      value,
      fieldName: fieldName,
      minLength: minLength,
      maxLength: maxLength,
    );
  }

  static String? validateCommonAddress(
    String value, {
    String fieldName = "Address",
    int minLength = 3,
    int maxLength = 160,
  }) {
    return validateRequiredMinMax(
      value,
      fieldName: fieldName,
      min: minLength,
      max: maxLength,
    );
  }

  static String? validateCommonNotes(
    String value, {
    String fieldName = "Notes",
    int maxLength = 300,
  }) {
    return validateOptionalMaxLength(
      value,
      fieldName: fieldName,
      max: maxLength,
    );
  }

  static String? validateCommonAmount(
    String value, {
    String fieldName = "Amount",
    int maxChars = 15,
    bool required = true,
    bool allowZero = false,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return required ? "$fieldName is required" : null;
    }
    if (trimmed.length > maxChars) {
      return "$fieldName cannot exceed $maxChars characters";
    }
    final num? parsed = num.tryParse(trimmed);
    if (parsed == null) return "$fieldName must be a number";
    if (!allowZero && parsed <= 0) return "$fieldName must be greater than 0";
    if (allowZero && parsed < 0) return "$fieldName cannot be negative";
    return null;
  }

  static String? validateCommonQuantity(
    String value, {
    String fieldName = "Quantity",
    int maxChars = 7,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return "$fieldName is required";
    if (trimmed.length > maxChars) {
      return "$fieldName cannot exceed $maxChars digits";
    }
    final int? parsed = int.tryParse(trimmed);
    if (parsed == null) return "$fieldName must be a whole number";
    if (parsed <= 0) return "$fieldName must be greater than 0";
    return null;
  }
}
