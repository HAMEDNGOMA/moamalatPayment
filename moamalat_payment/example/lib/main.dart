/// Moamalat Payment Package Example Application
///
/// This example demonstrates various ways to integrate the Moamalat payment
/// package in Flutter applications, showcasing both SDK and WebView methods
/// with proper currency handling and user interface design.
///
/// Features demonstrated:
/// - Multiple payment method examples
/// - Currency conversion utilities
/// - User-friendly interfaces
/// - Error handling and feedback
/// - Production-ready code patterns

import 'package:flutter/material.dart';
import 'pages/payment_selection_page.dart';
import 'pages/direct_sdk_example_page.dart';
import 'pages/webview_example_page.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget providing the root of the example app.
///
/// This widget sets up the Material Design theme and navigation structure
/// for demonstrating various Moamalat payment integration approaches.
class MyApp extends StatelessWidget {
  /// Creates the main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moamalat Payment Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const ExampleSelectionPage(),
    );
  }
}

/// Example selection page for choosing different demonstration types.
///
/// This page serves as the main navigation hub for various payment integration
/// examples, allowing users to explore different approaches and features.
///
/// Features:
/// - Clean, Material Design interface
/// - Clear categorization of examples
/// - Descriptive information for each option
/// - Easy navigation to specific demos
class ExampleSelectionPage extends StatelessWidget {
  /// Creates an example selection page.
  const ExampleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moamalat Payment Examples'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.payment,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose an Example',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore different payment integration approaches',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment method examples
              _buildExampleCard(
                context,
                title: 'Payment Methods Demo',
                subtitle:
                    'Unified widget with auto-selection and manual options',
                icon: Icons.auto_awesome,
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const PaymentSelectionPage(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // WebView example
              _buildExampleCard(
                context,
                title: 'WebView Implementation',
                subtitle:
                    'Traditional WebView with currency conversion examples',
                icon: Icons.web,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const WebViewExamplePage(
                      title: 'WebView Payment Example',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Direct SDK example
              _buildExampleCard(
                context,
                title: 'Direct SDK Usage',
                subtitle: 'Advanced SDK service integration for custom flows',
                icon: Icons.code,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const DirectSdkExamplePage(),
                  ),
                ),
              ),

              const Spacer(),

              // Footer information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Each example demonstrates different aspects of the Moamalat payment package. '
                  'Choose the one that best matches your integration needs.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card for each example option.
  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
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
