import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

/// A widget that displays payment transaction status and details.
///
/// This widget provides a visual representation of payment results,
/// showing success or failure states with appropriate styling and information.
///
/// Features:
/// - Success and failure state styling
/// - Transaction reference display
/// - Comprehensive status information
/// - Material Design theming
/// - Accessibility support
class PaymentStatusCard extends StatelessWidget {
  /// Creates a payment status card.
  ///
  /// Either [transaction] (for success) or [errorMessage] (for failure)
  /// should be provided, but not both.
  const PaymentStatusCard({
    super.key,
    this.transaction,
    this.errorMessage,
    this.paymentMethod,
    this.amount,
  }) : assert(
          (transaction != null) != (errorMessage != null),
          'Either transaction or errorMessage must be provided, but not both',
        );

  /// The successful transaction details, if payment succeeded.
  final TransactionSucsses? transaction;

  /// The error message, if payment failed.
  final String? errorMessage;

  /// The payment method used for the transaction.
  final String? paymentMethod;

  /// The payment amount for display purposes.
  final String? amount;

  /// Whether this represents a successful transaction.
  bool get isSuccess => transaction != null;

  @override
  Widget build(BuildContext context) {
    final statusColor = isSuccess ? Colors.green : Colors.red;
    final backgroundColor = isSuccess ? Colors.green[50] : Colors.red[50];

    return Card(
      color: backgroundColor,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isSuccess ? 'Payment Successful' : 'Payment Failed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor[800],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Main content
            if (isSuccess) _buildSuccessContent(context) else _buildErrorContent(context),
          ],
        ),
      ),
    );
  }

  /// Builds the content for successful transactions.
  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (amount != null) ...[
          _buildInfoRow(
            context,
            'Amount',
            CurrencyConverter.formatDinarAmount(
              CurrencyConverter.dirhamToDinar(amount!),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (paymentMethod != null) ...[
          _buildInfoRow(context, 'Method', paymentMethod!),
          const SizedBox(height: 8),
        ],
        if (transaction?.systemReference != null) ...[
          _buildInfoRow(context, 'Reference', transaction!.systemReference!),
          const SizedBox(height: 8),
        ],
        if (transaction?.paidThrough != null) ...[
          _buildInfoRow(context, 'Payment Type', transaction!.paidThrough!),
          const SizedBox(height: 8),
        ],
        if (transaction?.txnDate != null)
          _buildInfoRow(context, 'Date', transaction!.txnDate!),
      ],
    );
  }

  /// Builds the content for failed transactions.
  Widget _buildErrorContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          errorMessage!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[700],
              ),
        ),
        if (amount != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            'Attempted Amount',
            CurrencyConverter.formatDinarAmount(
              CurrencyConverter.dirhamToDinar(amount!),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a single information row with label and value.
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}