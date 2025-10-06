import 'package:flutter/material.dart';

/// A customizable button widget for selecting payment methods.
///
/// This widget provides a consistent interface for displaying payment method
/// options with icons, titles, subtitles, and tap functionality.
///
/// Features:
/// - Consistent Material Design styling
/// - Icon support for visual identification
/// - Subtitle text for additional context
/// - Hover and pressed states
/// - Accessibility support
class PaymentMethodButton extends StatelessWidget {
  /// Creates a payment method button.
  ///
  /// All parameters are required to ensure proper display and functionality.
  const PaymentMethodButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  /// The main title text displayed on the button.
  final String title;

  /// Additional descriptive text shown below the title.
  final String subtitle;

  /// The icon displayed on the left side of the button.
  final IconData icon;

  /// Callback function called when the button is pressed.
  final VoidCallback onPressed;

  /// Optional color for the icon. If not provided, uses theme primary color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}