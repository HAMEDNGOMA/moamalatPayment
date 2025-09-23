/// Platform-specific imports for MoamalatPayment widget.
/// 
/// This file provides conditional imports to ensure WASM compatibility
/// while maintaining full functionality on supported platforms.

// Conditional imports based on platform
export 'moamalat_payment_stub.dart'
    if (dart.library.html) 'moamalat_payment_web.dart'
    if (dart.library.io) 'moamalat_payment.dart';
