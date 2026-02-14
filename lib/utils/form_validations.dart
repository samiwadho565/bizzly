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
}
