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
  /// - Android platform: minSdkVersion 19 or higher
  /// - iOS platform: iOS 11.0 or higher
  /// - Requires proper SDK setup in native code
  /// - Platform-specific SDK dependencies
  ///
  /// **When to Use:**
  /// - Production applications
  /// - When performance is critical
  /// - When you need better user experience
  /// - When you want native platform integration
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
  /// - For SDK: `true` on Android and iOS platforms
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
        // SDK is available on Android and iOS
        return _isMobile();
      case PaymentMethod.webview:
        // WebView is available on all platforms
        return true;
    }
  }

  /// Returns a description of the payment method for documentation purposes.
  String get description {
    switch (this) {
      case PaymentMethod.sdk:
        return 'Native Moamalat SDK integration providing optimal performance and user experience on Android and iOS';
      case PaymentMethod.webview:
        return 'WebView-based payment gateway providing cross-platform compatibility';
    }
  }
}

/// Helper function to detect mobile platforms (Android and iOS).
///
/// Returns `true` if running on Android or iOS, `false` otherwise.
/// This is used internally to determine SDK availability.
bool _isMobile() {
  try {
    // For native mobile platforms, we can detect dart:io but not dart:html
    if (const bool.fromEnvironment('dart.library.io') &&
        !const bool.fromEnvironment('dart.library.html')) {
      // We're on a native platform (mobile or desktop)
      // For now, assume mobile platforms since desktop SDK isn't supported
      return true;
    }
    return false;
  } catch (e) {
    // Fallback for unsupported platforms
    return false;
  }
}

/// Helper function to detect Android platform specifically.
///
/// Returns `true` if running on Android, `false` otherwise.
/// This can be used for Android-specific functionality.
bool _isAndroid() {
  // For simplicity, we'll use the same detection as mobile
  // In a real implementation, you might use Platform.isAndroid from dart:io
  // but that requires conditional imports
  return _isMobile();
}

/// Helper function to detect iOS platform specifically.
///
/// Returns `true` if running on iOS, `false` otherwise.
/// This can be used for iOS-specific functionality.
bool _isIOS() {
  // For simplicity, we'll use the same detection as mobile
  // In a real implementation, you might use Platform.isIOS from dart:io
  // but that requires conditional imports
  return _isMobile();
}