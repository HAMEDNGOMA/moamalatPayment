import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

/// A widget for inputting payment amounts in Libyan Dinars.
///
/// This widget provides a user-friendly interface for entering payment amounts
/// in LYD while automatically showing the converted dirham amount for reference.
///
/// Features:
/// - Real-time currency conversion display
/// - Input validation for numeric values
/// - Clear labeling with currency indicators
/// - Responsive layout design
class PaymentAmountInput extends StatelessWidget {
  /// Creates a payment amount input widget.
  ///
  /// The [initialAmount] is displayed as the default value.
  /// The [onAmountChanged] callback is called whenever the amount changes.
  const PaymentAmountInput({
    super.key,
    required this.initialAmount,
    required this.onAmountChanged,
  });

  /// The initial amount to display in the input field.
  final double initialAmount;

  /// Callback function called when the amount changes.
  ///
  /// The callback receives the new amount as a double value.
  final ValueChanged<double> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: initialAmount.toString(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      suffix: Text('LYD'),
                      border: OutlineInputBorder(),
                      helperText: 'Enter amount in Libyan Dinars',
                    ),
                    onChanged: (value) {
                      final newAmount = double.tryParse(value) ?? initialAmount;
                      onAmountChanged(newAmount);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Equivalent:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      Text(
                        '${CurrencyConverter.dinarToDirham(initialAmount)} dirham',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}