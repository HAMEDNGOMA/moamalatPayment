import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

/// A widget that displays the availability status of the native Moamalat SDK.
///
/// This widget checks and displays whether the native Android SDK is properly
/// configured and available for use. It provides visual feedback to help
/// developers understand which payment methods are available.
///
/// Features:
/// - Real-time SDK availability checking
/// - Visual status indicators (icons and colors)
/// - Informative status messages
/// - Loading state handling
/// - Error state handling
class SdkAvailabilityIndicator extends StatelessWidget {
  /// Creates an SDK availability indicator widget.
  ///
  /// The widget automatically checks SDK availability when built.
  const SdkAvailabilityIndicator({super.key});

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
              'SDK Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<bool>(
              future: MoamalatSdkService.isAvailable(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(context);
                }

                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error.toString());
                }

                final isAvailable = snapshot.data ?? false;
                return _buildAvailabilityState(context, isAvailable);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the loading state while checking SDK availability.
  Widget _buildLoadingState(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Checking SDK availability...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Builds the error state when SDK check fails.
  Widget _buildErrorState(BuildContext context, String error) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.orange[600],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unable to check SDK status',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
              ),
              Text(
                'Error: $error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the availability state with proper status indication.
  Widget _buildAvailabilityState(BuildContext context, bool isAvailable) {
    final statusColor = isAvailable ? Colors.green : Colors.orange;
    final statusIcon = isAvailable ? Icons.check_circle : Icons.info;
    final statusText = isAvailable
        ? 'Native SDK is available'
        : 'Native SDK not available';
    final detailText = isAvailable
        ? 'Payments will use the native Android SDK for optimal performance'
        : 'Payments will use WebView method as fallback';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor[700],
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                detailText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}