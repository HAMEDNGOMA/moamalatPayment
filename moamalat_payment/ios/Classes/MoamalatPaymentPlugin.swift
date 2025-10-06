import Flutter
import UIKit
import PayButtonNumo

/// iOS implementation of the Moamalat payment plugin.
///
/// This class provides native iOS SDK integration for the Moamalat payment gateway,
/// allowing Flutter apps to use the PayButtonNumo iOS SDK for optimal performance
/// and native user experience on iOS devices.
///
/// ## Features
/// - Direct integration with PayButtonNumo iOS SDK
/// - Native iOS payment UI and user experience
/// - Comprehensive error handling and transaction callbacks
/// - Support for card and wallet transactions
/// - Secure payment processing with merchant authentication
///
/// ## Usage
/// This class is automatically instantiated by the Flutter engine and should not
/// be created directly. Use the Flutter-side `MoamalatSdkService` class instead.
public class MoamalatPaymentPlugin: NSObject, FlutterPlugin {

    /// The Flutter method channel for communication between Dart and iOS
    private var channel: FlutterMethodChannel?

    /// The current view controller presenting the plugin
    private weak var viewController: UIViewController?

    /// The current payment view controller instance
    private var paymentViewController: PaymentViewController?

    /// Registers the plugin with the Flutter engine
    ///
    /// This method is called automatically by Flutter during plugin registration.
    /// It sets up the method channel and establishes communication between
    /// the Dart side and native iOS code.
    ///
    /// - Parameter registrar: The Flutter plugin registrar
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "moamalat_payment/sdk", binaryMessenger: registrar.messenger())
        let instance = MoamalatPaymentPlugin()
        instance.channel = channel
        instance.viewController = UIApplication.shared.delegate?.window??.rootViewController
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles method calls from the Flutter side
    ///
    /// This method receives and processes method calls from the Dart side,
    /// including payment initiation, SDK availability checking, and version queries.
    ///
    /// - Parameters:
    ///   - call: The Flutter method call containing method name and arguments
    ///   - result: The callback to return results back to Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startPayment":
            handleStartPayment(call: call, result: result)
        case "isAvailable":
            handleIsAvailable(result: result)
        case "getVersion":
            handleGetVersion(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Handles payment initiation requests from Flutter
    ///
    /// This method processes payment start requests by extracting the necessary
    /// parameters and initializing the PayButtonNumo SDK with the provided
    /// merchant credentials and transaction details.
    ///
    /// - Parameters:
    ///   - call: The method call containing payment parameters
    ///   - result: The callback to return payment results
    private func handleStartPayment(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments provided",
                              details: nil))
            return
        }

        // Extract and validate required parameters
        guard let merchantId = arguments["merchantId"] as? String,
              let terminalId = arguments["terminalId"] as? String,
              let secureKey = arguments["secureKey"] as? String,
              let amount = arguments["amount"] as? Double,
              let merchantReference = arguments["merchantReference"] as? String else {
            result(FlutterError(code: "MISSING_PARAMETERS",
                              message: "Required payment parameters are missing",
                              details: nil))
            return
        }

        // Optional parameters with defaults
        let currencyCode = arguments["currencyCode"] as? String ?? "434"
        let isProduction = arguments["isProduction"] as? Bool ?? false

        // Validate merchant credentials
        if merchantId.isEmpty || terminalId.isEmpty || secureKey.isEmpty {
            result(FlutterError(code: "INVALID_CREDENTIALS",
                              message: "Merchant credentials cannot be empty",
                              details: nil))
            return
        }

        // Validate amount
        if amount <= 0 {
            result(FlutterError(code: "INVALID_AMOUNT",
                              message: "Payment amount must be greater than zero",
                              details: nil))
            return
        }

        // Initialize and configure payment
        DispatchQueue.main.async { [weak self] in
            self?.initiatePayment(
                merchantId: merchantId,
                terminalId: terminalId,
                secureKey: secureKey,
                amount: amount,
                merchantReference: merchantReference,
                currencyCode: currencyCode,
                isProduction: isProduction,
                result: result
            )
        }
    }

    /// Initiates the actual payment process using PayButtonNumo SDK
    ///
    /// This method creates and configures a PaymentViewController with the
    /// provided parameters, sets up the delegate for handling callbacks,
    /// and presents the payment interface to the user.
    ///
    /// - Parameters:
    ///   - merchantId: The merchant identifier
    ///   - terminalId: The terminal identifier
    ///   - secureKey: The merchant secure key
    ///   - amount: The payment amount in LYD
    ///   - merchantReference: The unique transaction reference
    ///   - currencyCode: The currency code (default: 434 for LYD)
    ///   - isProduction: Whether to use production environment
    ///   - result: The Flutter result callback
    private func initiatePayment(
        merchantId: String,
        terminalId: String,
        secureKey: String,
        amount: Double,
        merchantReference: String,
        currencyCode: String,
        isProduction: Bool,
        result: @escaping FlutterResult
    ) {
        // Create payment view controller
        let paymentVC = PaymentViewController()
        self.paymentViewController = paymentVC

        // Configure payment parameters
        paymentVC.mId = merchantId
        paymentVC.tId = terminalId
        paymentVC.Key = secureKey
        paymentVC.amount = String(format: "%.3f", amount) // Format to 3 decimal places
        paymentVC.refnumber = merchantReference
        paymentVC.Currency = currencyCode

        // Set environment (testing vs production)
        paymentVC.AppStatus = isProduction ? NumoUrlTypes.Numo_Live : NumoUrlTypes.Numo_Testing

        // Set up delegate to handle payment callbacks
        paymentVC.delegate = PaymentDelegate(result: result, plugin: self)

        // Present payment interface
        guard let viewController = self.viewController else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER",
                              message: "Unable to present payment interface",
                              details: nil))
            return
        }

        // Present the payment view controller
        paymentVC.pushViewController()
    }

    /// Handles SDK availability check requests
    ///
    /// This method returns whether the iOS SDK is available and properly
    /// configured on the current device. The iOS SDK is considered available
    /// if the PayButtonNumo framework is properly linked and accessible.
    ///
    /// - Parameter result: The Flutter result callback
    private func handleIsAvailable(result: @escaping FlutterResult) {
        // Check if PayButtonNumo classes are available
        let isAvailable = NSClassFromString("PayButtonNumo.PaymentViewController") != nil
        result(isAvailable)
    }

    /// Handles version information requests
    ///
    /// This method returns version information about the plugin and SDK
    /// for debugging and compatibility checking purposes.
    ///
    /// - Parameter result: The Flutter result callback
    private func handleGetVersion(result: @escaping FlutterResult) {
        let versionInfo: [String: Any] = [
            "pluginVersion": "2.0.0",
            "sdkName": "PayButtonNumo",
            "platform": "iOS",
            "minimumIOSVersion": "11.0"
        ]
        result(versionInfo)
    }
}

/// Delegate class for handling PayButtonNumo payment callbacks
///
/// This class implements the payment delegate protocol to receive
/// transaction results from the PayButtonNumo SDK and forward them
/// back to the Flutter side through the method channel.
private class PaymentDelegate: NSObject, PaymentDelegate {

    /// The Flutter result callback to return payment results
    private let result: FlutterResult

    /// Reference to the plugin instance for cleanup
    private weak var plugin: MoamalatPaymentPlugin?

    /// Initializes the payment delegate
    ///
    /// - Parameters:
    ///   - result: The Flutter result callback
    ///   - plugin: The plugin instance for cleanup
    init(result: @escaping FlutterResult, plugin: MoamalatPaymentPlugin) {
        self.result = result
        self.plugin = plugin
        super.init()
    }

    /// Called when the payment process is completed
    ///
    /// This method is called by the PayButtonNumo SDK when a payment
    /// transaction is completed, either successfully or with an error.
    /// It processes the receipt and returns the appropriate result to Flutter.
    ///
    /// - Parameter receipt: The payment receipt containing transaction details
    func finishSdkPayment(_ receipt: Receipt) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Clean up payment view controller reference
            self.plugin?.paymentViewController = nil

            if receipt.Success {
                // Payment successful - format success response
                let successResponse: [String: Any] = [
                    "success": true,
                    "networkReference": receipt.NetworkReference ?? "",
                    "merchantReference": receipt.MerchantReference ?? "",
                    "amount": receipt.Amount ?? 0.0,
                    "type": receipt.PaidThrough ?? "unknown",
                    "authCode": receipt.AuthCode ?? "",
                    "txnDate": receipt.TxnDate ?? "",
                    "systemReference": receipt.SystemReference ?? "",
                    "currency": receipt.Currency ?? "434"
                ]
                self.result(successResponse)
            } else {
                // Payment failed - format error response
                let errorResponse: [String: Any] = [
                    "success": false,
                    "error": receipt.ErrorMessage ?? "Payment failed",
                    "merchantReference": receipt.MerchantReference ?? "",
                    "amount": receipt.Amount ?? 0.0
                ]
                self.result(errorResponse)
            }
        }
    }

    /// Called when the payment process is cancelled by the user
    ///
    /// This method handles user cancellation of the payment process
    /// and returns an appropriate error to Flutter.
    func cancelSdkPayment() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Clean up payment view controller reference
            self.plugin?.paymentViewController = nil

            // Return cancellation error
            let errorResponse: [String: Any] = [
                "success": false,
                "error": "Payment cancelled by user",
                "merchantReference": "",
                "amount": 0.0
            ]
            self.result(errorResponse)
        }
    }
}