# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-10-06

### 🎉 Major Release - Native SDK Integration & Unified Architecture

This major release introduces **dual payment method support** with native Android SDK integration alongside the existing WebView implementation, featuring intelligent auto-selection and comprehensive developer experience improvements.

### ✨ Added

#### 🚀 **Native SDK Integration**
- **NEW**: `MoamalatSdkService` - Direct integration with native Moamalat Android SDK
- **NEW**: `MoamalatPaymentUnified` - Unified widget supporting both SDK and WebView methods
- **NEW**: `PaymentMethod` enum for explicit method selection (SDK, WebView)
- **NEW**: Automatic payment method selection (SDK on Android, WebView elsewhere)
- **NEW**: Platform capability detection and fallback mechanisms
- **NEW**: SDK availability checking with `MoamalatSdkService.isAvailable()`
- **NEW**: Native error handling and transaction callbacks for SDK

#### 🎯 **Smart Method Selection**
- **NEW**: Auto-selection logic that chooses optimal payment method per platform
- **NEW**: Manual override support for forced SDK or WebView usage
- **NEW**: Graceful fallback from SDK to WebView when SDK unavailable
- **NEW**: Platform-specific conditional exports for optimal performance

#### 🏗️ **Enhanced Architecture**
- **NEW**: Modular widget architecture with separate page components
- **NEW**: Reusable UI components following pub.dev best practices:
  - `PaymentAmountInput` - Currency input with real-time conversion
  - `PaymentMethodButton` - Consistent method selection buttons
  - `PaymentStatusCard` - Transaction result display
  - `SdkAvailabilityIndicator` - Real-time SDK status checking
- **NEW**: Separate page components for different demo types
- **NEW**: Clean navigation structure with Material Design 3

#### 📱 **Android Integration**
- **NEW**: Native Android plugin implementation with method channels
- **NEW**: PayButton SDK integration with full transaction callbacks
- **NEW**: Proper Android manifest configuration and dependency management
- **NEW**: MultiDex support for SDK compatibility
- **NEW**: JitPack repository integration for SDK dependencies

### 🚀 Improved

#### 📚 **Developer Experience**
- **IMPROVED**: Comprehensive example app refactoring with multiple demo types:
  - Payment Methods Demo (unified widget showcase)
  - WebView Implementation (traditional approach)
  - Direct SDK Usage (advanced integration)
- **IMPROVED**: Professional Material Design 3 theming
- **IMPROVED**: Intuitive navigation with descriptive cards and icons
- **IMPROVED**: Real-time currency conversion display
- **IMPROVED**: Interactive SDK availability checking

#### 🎨 **Code Quality & Documentation**
- **IMPROVED**: Complete code documentation following pub.dev standards
- **IMPROVED**: Comprehensive inline comments for all public APIs
- **IMPROVED**: Enhanced error model documentation with usage examples
- **IMPROVED**: Clear distinction between SDK and WebView amount handling
- **IMPROVED**: Removed all debug print statements (production-ready)

#### 💰 **Currency Handling**
- **IMPROVED**: Consistent CurrencyConverter usage throughout package
- **IMPROVED**: Clear documentation of amount formats for different methods:
  - Unified Widget: Always use dirham strings
  - SDK Service: Use LYD doubles (automatic conversion)
  - WebView Widget: Use dirham strings
- **IMPROVED**: Better error messages for amount validation
- **IMPROVED**: Enhanced display formatting with proper localization

#### 🔐 **Security & Error Handling**
- **IMPROVED**: Enhanced transaction parsing with robust type checking
- **IMPROVED**: Better error propagation from native SDK
- **IMPROVED**: Comprehensive validation for all payment parameters
- **IMPROVED**: Secure handling of different platform result formats

### 🔧 Fixed

#### 🐛 **Critical Fixes**
- **FIXED**: Amount formatting consistency across all payment methods
- **FIXED**: Currency conversion calculations now use CurrencyConverter exclusively
- **FIXED**: Transaction success model amount field changed from int to double
- **FIXED**: Platform-specific Map type handling in method channel results
- **FIXED**: Hex validation for merchant secret keys (supports both hex and string)

#### 🏗️ **Build & Configuration**
- **FIXED**: Android namespace configuration for plugin
- **FIXED**: Java toolchain compatibility issues
- **FIXED**: SDK dependency resolution with compileOnly pattern
- **FIXED**: Manifest merger conflicts with MultiDex configuration
- **FIXED**: Proper plugin registration and method channel setup

#### 📱 **Platform Compatibility**
- **FIXED**: NoClassDefFoundError for SDK classes in runtime
- **FIXED**: Platform channel result type casting issues
- **FIXED**: iOS compatibility with WebView-only fallback
- **FIXED**: Web/WASM compatibility maintained

### 🗑️ Removed

#### 🧹 **Code Cleanup**
- **REMOVED**: All debug print statements from production code
- **REMOVED**: Manual currency calculations (replaced with CurrencyConverter)
- **REMOVED**: Redundant example code in main.dart
- **REMOVED**: Legacy widget examples (moved to dedicated pages)

### 📦 **Dependencies & Configuration**

#### 🔄 **Updated Dependencies**
- **UPDATED**: Android compileSdkVersion to 34
- **UPDATED**: Android targetSdkVersion to 34
- **UPDATED**: Minimum Android SDK version to 19 (required for SDK)
- **ADDED**: Native SDK dependencies with proper version constraints
- **ADDED**: MultiDex support for Android applications

### 🌟 **Highlights**

This release represents a **major architectural evolution**:

- 🏆 **Dual Integration**: Both native SDK and WebView support in one package
- 🧠 **Smart Selection**: Automatic method selection with intelligent fallbacks
- 📱 **Native Performance**: Direct Android SDK integration for optimal UX
- 🌐 **Universal Compatibility**: Maintained support for all platforms
- 🎨 **Professional Examples**: Production-ready demo implementations
- 📖 **Clear Documentation**: Comprehensive guides for all integration approaches
- 💰 **Currency Clarity**: Crystal-clear amount handling for different methods

### 📈 **Migration Guide**

#### From v1.x.x to v2.0.0:

1. **Recommended Approach**: Switch to `MoamalatPaymentUnified`
   ```dart
   // OLD
   MoamalatPayment(...)

   // NEW (Recommended)
   MoamalatPaymentUnified(...)  // Auto-selects best method
   ```

2. **Amount Handling**: No changes needed - dirham strings work everywhere
   ```dart
   amount: "1000"  // Still correct for all widgets
   amount: CurrencyConverter.dinarToDirham(1.0)  // Still correct
   ```

3. **Android Setup**: Add SDK dependencies for optimal performance
   ```gradle
   dependencies {
       implementation 'com.github.payskyCompany:NUMO-PayButton-SDK-android:1.0.12'
   }
   ```

4. **Existing Code**: All existing `MoamalatPayment` usage continues to work

### 🔮 **What's Next**

Future releases will focus on:
- iOS native SDK integration (when available)
- Advanced customization options
- Enhanced analytics and reporting
- Additional payment method support

---

## [1.0.1] - 2024-09-23

### 📝 Documentation Improvements

#### **Enhanced Comments**
- **IMPROVED**: Added clear explanation for `merchantReference` parameter
- **IMPROVED**: Updated comments to explain transaction reference usage
- **IMPROVED**: Better developer understanding of parameter purpose

#### **Examples Updated**
- **UPDATED**: Main.dart example with improved comments
- **UPDATED**: README.md examples with clearer explanations
- **UPDATED**: All merchantReference instances now have descriptive comments

### 🔧 **Minor Fixes**
- **FIXED**: Comment clarity for transaction reference management
- **IMPROVED**: Developer experience with better parameter documentation

---

## [1.0.0] - 2024-09-23

### 🎉 Major Release - Complete Package Overhaul

This major release represents a complete transformation of the MoamalatPayment package with significant new features, WASM compatibility, and comprehensive improvements.

### ✨ Added

#### 💱 **Currency Conversion System**
- **NEW**: `CurrencyConverter` utility class for Libyan Dinar ↔ Dirham conversion
- **NEW**: `dinarToDirham()` - Convert dinar amounts to dirham strings
- **NEW**: `dinarStringToDirham()` - Convert dinar strings to dirham format
- **NEW**: `dirhamToDinar()` - Convert dirham back to dinar for display
- **NEW**: `isValidDinarAmount()` and `isValidDirhamAmount()` - Input validation
- **NEW**: `formatDinarAmount()` and `formatDirhamAmount()` - Display formatting
- **NEW**: Thousands separators and currency symbols in formatting

#### 🌐 **WASM Compatibility & Multi-Platform Support**
- **NEW**: Full WebAssembly (WASM) runtime compatibility
- **NEW**: `MoamalatPaymentWeb` - Web-specific implementation using HTML iframe
- **NEW**: `MoamalatPaymentStub` - Graceful fallback for unsupported platforms
- **NEW**: `MoamalatPaymentPlatform` - Conditional imports for platform detection
- **NEW**: Automatic platform selection (Android/iOS/Web/WASM)

#### 🎨 **User Experience Enhancements**
- **NEW**: Beautiful loading indicators with customizable messages
- **NEW**: Arabic language support with RTL text handling
- **NEW**: Smooth navigation transitions with proper WebView cleanup
- **NEW**: Enhanced error handling with user-friendly messages
- **NEW**: Professional loading screens with progress indicators

#### 🔒 **Security & Compliance**
- **NEW**: Enhanced HMAC-SHA256 transaction signing
- **NEW**: Improved secret key handling and validation
- **NEW**: Comprehensive input validation for all parameters
- **NEW**: Security best practices documentation

### 🚀 Improved

#### 📚 **Documentation**
- **IMPROVED**: Complete README.md overhaul with professional design
- **IMPROVED**: Comprehensive API documentation with examples
- **IMPROVED**: Real-world usage examples (e-commerce, gaming)
- **IMPROVED**: Platform-specific setup guides
- **IMPROVED**: Troubleshooting section with common issues
- **IMPROVED**: Security best practices guide
- **IMPROVED**: Multi-language examples (Arabic/English)

#### 🏗️ **Code Quality**
- **IMPROVED**: Complete code documentation following pub.dev standards
- **IMPROVED**: Enhanced error handling and edge case management
- **IMPROVED**: Type safety improvements with detailed model classes
- **IMPROVED**: Code organization and structure
- **IMPROVED**: Performance optimizations for WebView handling

#### 🛠️ **Developer Experience**
- **IMPROVED**: Comprehensive example application with live demonstrations
- **IMPROVED**: Currency conversion examples and best practices
- **IMPROVED**: Platform-specific implementation guides
- **IMPROVED**: Enhanced debugging and logging capabilities

### 🔧 Fixed

#### 🐛 **Bug Fixes**
- **FIXED**: WebView navigation back button smoothness issues
- **FIXED**: WebView overlay appearing during navigation transitions
- **FIXED**: Memory leaks in WebView disposal
- **FIXED**: PopScope navigation handling for Flutter 3.16+
- **FIXED**: Platform-specific build issues and compatibility

#### 🔄 **Compatibility**
- **FIXED**: Flutter 3.16+ compatibility with PopScope migration
- **FIXED**: Gradle plugin compatibility issues
- **FIXED**: iOS build configuration problems
- **FIXED**: Web deployment and WASM runtime issues

### 🗑️ Removed

#### 🧹 **Deprecated Features**
- **REMOVED**: Legacy WillPopScope implementation (replaced with PopScope)
- **REMOVED**: Redundant debug print statements
- **REMOVED**: Unused import statements and dependencies
- **REMOVED**: Generated files from version control

### 📦 **Package Management**

#### 🔄 **Dependencies**
- **UPDATED**: flutter_inappwebview to latest compatible version
- **UPDATED**: crypto package for enhanced security
- **UPDATED**: Flutter SDK compatibility to latest stable

#### 📁 **Repository**
- **IMPROVED**: Comprehensive .gitignore following Flutter best practices
- **IMPROVED**: Repository structure and organization
- **IMPROVED**: Removed generated files from version control
- **IMPROVED**: Added proper licensing and contribution guidelines

### 🌟 **Highlights**

This release transforms MoamalatPayment from a basic payment widget into a comprehensive, enterprise-ready payment solution:

- 🏆 **Enterprise Ready**: Professional-grade documentation and examples
- 🌍 **Multi-Platform**: Works seamlessly on Android, iOS, Web, and WASM
- 💱 **Libya-Focused**: Built-in Libyan Dinar currency handling
- 🔒 **Security First**: Enhanced security practices and validation
- 🎨 **User Friendly**: Beautiful UI with Arabic language support
- 🛠️ **Developer Friendly**: Comprehensive documentation and examples

### 📈 **Migration Guide**

For users upgrading from previous versions:

1. **Currency Amounts**: Use `CurrencyConverter.dinarToDirham()` for user-friendly dinar input
2. **Navigation**: PopScope is now used instead of WillPopScope (automatic)
3. **Platform Support**: Package now works on all platforms including Web/WASM
4. **Documentation**: Refer to the new comprehensive README for updated examples

---

## [0.0.5] - 2024-XX-XX

### Changed
- Update dependency
- Change file name

## [0.0.4] - 2024-XX-XX

### Added
- Add .yaml docs

## [0.0.3] - 2024-XX-XX

### Added
- Add doc comments

## [0.0.2+2] - 2024-XX-XX

### Changed
- Update name in Readme

## [0.0.2+1] - 2024-XX-XX

### Changed
- Update Readme and Add License

## [0.0.2] - 2024-XX-XX

### Fixed
- Fix Error with null data in onCompleteSucsses CallBack

## [0.0.1] - 2024-XX-XX

### Added
- First release, with simple example project