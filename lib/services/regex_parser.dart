class NotificationParser {
  // Regex to extract amount following ₹ or Rs or INR
  // Example matches: "₹100" -> "100", "Rs. 250.50" -> "250.50"
  static final RegExp _amountRegex = RegExp(
    r'(?:₹|Rs\.?|INR)\s*([0-9,]+\.?[0-9]*)',
    caseSensitive: false,
  );

  // Specific keywords to verify it's an incoming payment notification
  static final RegExp _receivedKeywords = RegExp(
    r'received|paid you|payment of|credited',
    caseSensitive: false,
  );

  // List of allowed UPI apps package names to prevent reading other apps' notifications
  static const List<String> allowedPackages = [
    'net.one97.paytm', // Paytm
    'com.phonepe.app', // PhonePe
    'com.phonepe.app.business', // PhonePe Business
    'com.google.android.apps.nbu.paisa.user', // Google Pay
    'com.google.android.apps.nbu.paisa.merchant', // Google Pay Business
    'in.org.npci.upiapp', // BHIM
    'com.bharatpe.app', // BharatPe
    'com.naviapp', // Navi
  ];

  static bool isTargetApp(String? packageName) {
    if (packageName == null) return false;
    return allowedPackages.contains(packageName);
  }

  static String? extractReceivedAmount(String? title, String? body) {
    // Combine text for easier search (fallback to empty string if null)
    final String fullText = '${title ?? ""} ${body ?? ""}';

    // Must contain a keyword indicating money received. Otherwise it might be a promo or money sent
    if (!_receivedKeywords.hasMatch(fullText)) {
      return null;
    }

    // Extract the amount value
    final match = _amountRegex.firstMatch(fullText);
    if (match != null && match.groupCount >= 1) {
      return _cleanAmount(match.group(1));
    }

    return null;
  }

  static String? _cleanAmount(String? rawAmount) {
    if (rawAmount == null) return null;
    return rawAmount.replaceAll(
      ',',
      '',
    ); // Remove thousands separator for correct TTS speaking
  }
}
