/// Enumeration for payment method types supported by the Moamalat payment package.
///
/// This enum allows developers to choose between different payment processing methods
/// based on their requirements and platform capabilities.
///
/// ## Available Methods
/// - [PaymentMethod.sdk]: Uses native Moamalat SDK for optimal performance and integration
/// - [PaymentMethod.webview]: Uses WebView-based payment gateway for broader compatibility
///
/// ## Usage Example
/// ```dart
/// MoamalatPayment(
///   paymentMethod: PaymentMethod.sdk, // or PaymentMethod.webview
///   merchantId: "your_merchant_id",
///   // ... other parameters
/// )
/// ```
enum PaymentMethod {
  /// Native SDK payment method.
  ///
  /// **Advantages:**
  /// - Better performance and user experience
  /// - Native UI components that match platform design
  /// - More reliable transaction processing
  /// - Better error handling and debugging
  /// - Reduced memory footprint
  ///
  /// **Requirements:**
  /// - Android platform only (iOS SDK not available)
  /// - Requires proper SDK setup in Android native code
  /// - minSdkVersion 19 or higher
  ///
  /// **When to Use:**
  /// - Production applications
  /// - When performance is critical
  /// - When you need better user experience
  /// - When you have Android-specific requirements
  sdk,

  /// WebView-based payment method.
  ///
  /// **Advantages:**
  /// - Cross-platform compatibility (Android, iOS, Web)
  /// - No native SDK setup required
  /// - Easier to implement and maintain
  /// - Consistent behavior across platforms
  ///
  /// **Disadvantages:**
  /// - Higher memory usage
  /// - Potential WebView compatibility issues
  /// - Slower loading times
  /// - Limited customization options
  ///
  /// **When to Use:**
  /// - Cross-platform applications
  /// - Rapid prototyping
  /// - When native SDK is not available for your platform
  /// - When you need consistent behavior across platforms
  webview,
}

/// Extension methods for [PaymentMethod] to provide additional functionality.
extension PaymentMethodExtension on PaymentMethod {
  /// Returns a human-readable string representation of the payment method.
  ///
  /// Examples:
  /// - `PaymentMethod.sdk.displayName` returns `"Native SDK"`
  /// - `PaymentMethod.webview.displayName` returns `"WebView"`
  String get displayName {
    switch (this) {
      case PaymentMethod.sdk:
        return 'Native SDK';
      case PaymentMethod.webview:
        return 'WebView';
    }
  }

  /// Returns a technical identifier for the payment method.
  ///
  /// Useful for logging, analytics, and debugging purposes.
  ///
  /// Examples:
  /// - `PaymentMethod.sdk.identifier` returns `"sdk"`
  /// - `PaymentMethod.webview.identifier` returns `"webview"`
  String get identifier {
    switch (this) {
      case PaymentMethod.sdk:
        return 'sdk';
      case PaymentMethod.webview:
        return 'webview';
    }
  }

  /// Checks if the payment method is available on the current platform.
  ///
  /// Returns:
  /// - For SDK: `true` only on Android platform
  /// - For WebView: `true` on all platforms
  ///
  /// Example:
  /// ```dart
  /// if (PaymentMethod.sdk.isAvailable) {
  ///   // Use SDK method
  /// } else {
  ///   // Fallback to WebView
  /// }
  /// ```
  bool get isAvailable {
    switch (this) {
      case PaymentMethod.sdk:
        // SDK is only available on Android
        return _isAndroid();
      case PaymentMethod.webview:
        // WebView is available on all platforms
        return true;
    }
  }

  /// Returns a description of the payment method for documentation purposes.
  String get description {
    switch (this) {
      case PaymentMethod.sdk:
        return 'Native Moamalat SDK integration providing optimal performance and user experience on Android';
      case PaymentMethod.webview:
        return 'WebView-based payment gateway providing cross-platform compatibility';
    }
  }
}

/// Helper function to detect Android platform.
///
/// Returns `true` if running on Android, `false` otherwise.
/// This is used internally to determine SDK availability.
bool _isAndroid() {
  try {
    // Use dart:io to detect platform if available
    // This will be true for mobile/desktop platforms
    return const bool.fromEnvironment('dart.library.io') &&
           !const bool.fromEnvironment('dart.library.html');
  } catch (e) {
    // Fallback for web or unsupported platforms
    return false;
  }
}