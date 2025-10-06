package com.moamalat.moamalat_payment

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import io.paysky.paybutton.ui.PayButton
import io.paysky.paybutton.data.model.SuccessfulCardTransaction
import io.paysky.paybutton.data.model.SuccessfulWalletTransaction
import io.paysky.paybutton.exception.TransactionException
import io.paysky.paybutton.util.AppUtils
import io.paysky.paybutton.util.AllURLsStatus
import android.util.Log

/**
 * MoamalatPaymentPlugin
 *
 * Flutter plugin for integrating Moamalat Numo SDK into Flutter applications.
 * This plugin provides a bridge between Flutter and the native Android Moamalat SDK,
 * enabling secure payment processing with native performance.
 *
 * Features:
 * - Native Moamalat SDK integration
 * - Support for both card and wallet transactions
 * - Production and testing environment support
 * - Comprehensive error handling
 * - Transaction reference tracking
 */
class MoamalatPaymentPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    // Method channel for communication with Flutter
    private lateinit var channel: MethodChannel

    // Current activity reference
    private var activity: Activity? = null

    companion object {
        private const val TAG = "MoamalatPaymentPlugin"
        private const val CHANNEL_NAME = "moamalat_payment/sdk"

        // SDK version for compatibility tracking
        private const val PLUGIN_VERSION = "1.0.1"
        private const val SDK_VERSION = "1.0.12"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Plugin attached to engine")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "Method called: ${call.method}")

        when (call.method) {
            "startPayment" -> {
                handleStartPayment(call, result)
            }
            "isAvailable" -> {
                handleIsAvailable(result)
            }
            "getVersion" -> {
                handleGetVersion(result)
            }
            else -> {
                Log.w(TAG, "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    /**
     * Handles the startPayment method call from Flutter.
     *
     * This method validates the payment parameters, initializes the Moamalat SDK,
     * and processes the payment transaction.
     *
     * @param call MethodCall containing payment parameters
     * @param result Result callback to send response back to Flutter
     */
    private fun handleStartPayment(call: MethodCall, result: Result) {
        Log.d(TAG, "=== Starting Payment ===")

        val currentActivity = activity
        if (currentActivity == null) {
            Log.e(TAG, "Activity is null - cannot process payment")
            result.error("NO_ACTIVITY", "Activity not available for payment processing", null)
            return
        }

        try {
            // Extract and validate payment parameters
            val merchantId = call.argument<String>("merchantId")
            val terminalId = call.argument<String>("terminalId")
            val secureKey = call.argument<String>("secureKey")
            val amount = call.argument<Double>("amount")
            val merchantReference = call.argument<String>("merchantReference")
            val currencyCode = call.argument<String>("currencyCode") ?: "434"
            val isProduction = call.argument<Boolean>("isProduction") ?: false

            // Validate required parameters
            if (merchantId.isNullOrBlank()) {
                result.error("INVALID_ARGUMENTS", "merchantId is required and cannot be empty", null)
                return
            }

            if (terminalId.isNullOrBlank()) {
                result.error("INVALID_ARGUMENTS", "terminalId is required and cannot be empty", null)
                return
            }

            if (secureKey.isNullOrBlank()) {
                result.error("INVALID_ARGUMENTS", "secureKey is required and cannot be empty", null)
                return
            }

            if (amount == null || amount <= 0) {
                result.error("INVALID_ARGUMENTS", "amount is required and must be greater than 0", null)
                return
            }

            if (merchantReference.isNullOrBlank()) {
                result.error("INVALID_ARGUMENTS", "merchantReference is required and cannot be empty", null)
                return
            }

            Log.d(TAG, "Payment parameters validated successfully")
            Log.d(TAG, "MerchantId: $merchantId")
            Log.d(TAG, "TerminalId: $terminalId")
            Log.d(TAG, "Amount: $amount LYD")
            Log.d(TAG, "MerchantReference: $merchantReference")
            Log.d(TAG, "IsProduction: $isProduction")

            // Execute payment with validated parameters
            executePayment(
                currentActivity,
                merchantId,
                terminalId,
                secureKey,
                amount,
                merchantReference,
                currencyCode,
                isProduction,
                result
            )

        } catch (e: Exception) {
            Log.e(TAG, "Error processing payment parameters", e)
            result.error("PARAMETER_ERROR", "Failed to process payment parameters: ${e.message}", null)
        }
    }

    /**
     * Executes the actual payment using the Moamalat SDK.
     *
     * This method initializes the PayButton with the provided parameters,
     * sets up transaction callbacks, and initiates the payment flow.
     *
     * @param activity Current Android activity
     * @param merchantId Merchant identifier
     * @param terminalId Terminal identifier
     * @param secureKey Merchant secure key
     * @param amount Payment amount in LYD
     * @param merchantReference Transaction reference
     * @param currencyCode Currency code (default: 434 for LYD)
     * @param isProduction Environment flag
     * @param result Flutter result callback
     */
    private fun executePayment(
        activity: Activity,
        merchantId: String,
        terminalId: String,
        secureKey: String,
        amount: Double,
        merchantReference: String,
        currencyCode: String,
        isProduction: Boolean,
        result: Result
    ) {
        try {
            Log.d(TAG, "Initializing Moamalat SDK...")

            val payButton = PayButton(activity)

            // Configure payment parameters
            payButton.setMerchantId(merchantId)
            payButton.setTerminalId(terminalId)
            payButton.setAmount(amount)
            payButton.setCurrencyCode(434) // Always use 434 for LYD
            payButton.setMerchantSecureHash(secureKey)
            payButton.setTransactionReferenceNumber(AppUtils.generateRandomNumber())

            // Set environment (production vs staging)
            val urlStatus = if (isProduction) AllURLsStatus.PRODUCTION else AllURLsStatus.STAGINIG
            payButton.setProductionStatus(urlStatus)

            // Set language to Arabic
            payButton.setLang("ar")

            Log.d(TAG, "SDK configured, creating transaction...")

            // Create transaction with callbacks
            payButton.createTransaction(object : PayButton.PaymentTransactionCallback {
                override fun onCardTransactionSuccess(cardTransaction: SuccessfulCardTransaction) {
                    Log.d(TAG, "=== CARD TRANSACTION SUCCESS ===")
                    Log.d(TAG, "NetworkReference: ${cardTransaction.NetworkReference}")
                    Log.d(TAG, "AuthCode: ${cardTransaction.AuthCode}")
                    Log.d(TAG, "ActionCode: ${cardTransaction.ActionCode}")
                    Log.d(TAG, "ReceiptNumber: ${cardTransaction.ReceiptNumber}")

                    // Parse amount safely
                    val amountDouble = parseAmount(cardTransaction.amount)
                    Log.d(TAG, "Amount parsed: $amountDouble")

                    val resultMap = mapOf(
                        "success" to true,
                        "type" to "card",
                        "networkReference" to (cardTransaction.NetworkReference ?: ""),
                        "authCode" to (cardTransaction.AuthCode ?: ""),
                        "actionCode" to (cardTransaction.ActionCode ?: ""),
                        "receiptNumber" to (cardTransaction.ReceiptNumber ?: ""),
                        "amount" to amountDouble,
                        "merchantReference" to merchantReference
                    )

                    Log.d(TAG, "Sending success result to Flutter: $resultMap")
                    result.success(resultMap)
                }

                override fun onWalletTransactionSuccess(walletTransaction: SuccessfulWalletTransaction) {
                    Log.d(TAG, "=== WALLET TRANSACTION SUCCESS ===")
                    Log.d(TAG, "NetworkReference: ${walletTransaction.NetworkReference}")

                    // Parse amount safely
                    val amountDouble = parseAmount(walletTransaction.amount)
                    Log.d(TAG, "Amount parsed: $amountDouble")

                    val resultMap = mapOf(
                        "success" to true,
                        "type" to "wallet",
                        "networkReference" to (walletTransaction.NetworkReference ?: ""),
                        "amount" to amountDouble,
                        "merchantReference" to merchantReference
                    )

                    Log.d(TAG, "Sending success result to Flutter: $resultMap")
                    result.success(resultMap)
                }

                override fun onError(error: TransactionException) {
                    Log.e(TAG, "=== TRANSACTION ERROR ===")
                    Log.e(TAG, "Error message: ${error.message}")
                    Log.e(TAG, "Error code: ${error.errorCode}")

                    val errorMap = mapOf(
                        "success" to false,
                        "error" to (error.message ?: "Payment failed"),
                        "errorCode" to error.errorCode,
                        "merchantReference" to merchantReference,
                        "amount" to amount.toString()
                    )

                    result.success(errorMap)
                }
            })

        } catch (e: Exception) {
            Log.e(TAG, "SDK execution error", e)
            result.error("SDK_ERROR", "Moamalat SDK error: ${e.message}", null)
        }
    }

    /**
     * Safely parses amount from the SDK response.
     *
     * The Moamalat SDK may return amounts in different formats (String or Number),
     * so this method handles the parsing safely.
     *
     * @param amount Amount object from SDK response
     * @return Parsed double value, or 0.0 if parsing fails
     */
    private fun parseAmount(amount: Any?): Double {
        return when (amount) {
            is String -> amount.toDoubleOrNull() ?: 0.0
            is Number -> amount.toDouble()
            else -> 0.0
        }
    }

    /**
     * Handles the isAvailable method call.
     *
     * Checks if the Moamalat SDK is properly configured and available for use.
     *
     * @param result Flutter result callback
     */
    private fun handleIsAvailable(result: Result) {
        try {
            // Try to create a PayButton instance to test SDK availability
            val currentActivity = activity
            if (currentActivity != null) {
                PayButton(currentActivity)
                Log.d(TAG, "SDK is available")
                result.success(true)
            } else {
                Log.w(TAG, "Activity not available")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e(TAG, "SDK not available", e)
            result.success(false)
        }
    }

    /**
     * Handles the getVersion method call.
     *
     * Returns version information for debugging and compatibility checking.
     *
     * @param result Flutter result callback
     */
    private fun handleGetVersion(result: Result) {
        val versionInfo = mapOf(
            "pluginVersion" to PLUGIN_VERSION,
            "sdkVersion" to SDK_VERSION,
            "platform" to "android"
        )

        Log.d(TAG, "Version info: $versionInfo")
        result.success(versionInfo)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Plugin detached from engine")
        channel.setMethodCallHandler(null)
    }

    // ActivityAware implementation
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "Plugin attached to activity")
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "Plugin detached from activity for config changes")
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "Plugin reattached to activity for config changes")
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "Plugin detached from activity")
        activity = null
    }
}