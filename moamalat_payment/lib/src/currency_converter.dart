/// Currency conversion utilities for Libyan Dinar (LYD) to Dirham conversion.
///
/// This utility class provides methods to convert between Libyan Dinar and Dirham
/// for use with the Moamalat payment gateway, which requires amounts in the smallest
/// currency unit (dirham).
///
/// ## Conversion Rate
/// - 1 Libyan Dinar (LYD) = 1000 Libyan Dirham
///
/// ## Usage Examples
/// ```dart
/// // Convert from dinar to dirham string
/// String dirhamAmount = CurrencyConverter.dinarToDirham(10.5); // "10500"
///
/// // Convert from dinar string to dirham string
/// String dirhamAmount = CurrencyConverter.dinarStringToDirham("10.500"); // "10500"
///
/// // Convert from dirham back to dinar
/// double dinarAmount = CurrencyConverter.dirhamToDinar("10500"); // 10.5
///
/// // Validate dirham amount format
/// bool isValid = CurrencyConverter.isValidDirhamAmount("10500"); // true
/// ```
class CurrencyConverter {
  /// Conversion rate: 1 Libyan Dinar = 1000 Libyan Dirham
  static const int _conversionRate = 1000;

  /// Converts Libyan Dinar amount to Dirham string format.
  ///
  /// Takes a double value representing Libyan Dinars and converts it to
  /// a string representation of Dirham (smallest currency unit) suitable
  /// for use with the Moamalat payment gateway.
  ///
  /// **Examples:**
  /// - `1.0` LYD → `"1000"` dirham
  /// - `10.5` LYD → `"10500"` dirham
  /// - `0.001` LYD → `"1"` dirham
  /// - `0.0` LYD → `"0"` dirham
  ///
  /// [dinarAmount] The amount in Libyan Dinars (can have decimal places)
  /// Returns a string representation of the equivalent dirham amount
  ///
  /// Throws [ArgumentError] if the dinar amount is negative
  static String dinarToDirham(double dinarAmount) {
    if (dinarAmount < 0) {
      throw ArgumentError('Dinar amount cannot be negative: $dinarAmount');
    }

    // Convert to dirham by multiplying by conversion rate
    int dirhamAmount = (dinarAmount * _conversionRate).round();
    return dirhamAmount.toString();
  }

  /// Converts Libyan Dinar string amount to Dirham string format.
  ///
  /// Takes a string value representing Libyan Dinars and converts it to
  /// a string representation of Dirham suitable for payment processing.
  ///
  /// **Examples:**
  /// - `"1"` LYD → `"1000"` dirham
  /// - `"10.5"` LYD → `"10500"` dirham
  /// - `"0.001"` LYD → `"1"` dirham
  /// - `"1.234"` LYD → `"1234"` dirham
  ///
  /// [dinarAmountString] String representation of Libyan Dinar amount
  /// Returns a string representation of the equivalent dirham amount
  ///
  /// Throws [ArgumentError] if the string cannot be parsed as a valid number
  /// Throws [ArgumentError] if the parsed amount is negative
  static String dinarStringToDirham(String dinarAmountString) {
    try {
      double dinarAmount = double.parse(dinarAmountString);
      return dinarToDirham(dinarAmount);
    } on FormatException {
      throw ArgumentError('Invalid dinar amount format: $dinarAmountString');
    }
  }

  /// Converts Dirham string amount back to Libyan Dinar.
  ///
  /// Takes a string representing dirham amount and converts it back to
  /// Libyan Dinar as a double value. Useful for displaying amounts to users.
  ///
  /// **Examples:**
  /// - `"1000"` dirham → `1.0` LYD
  /// - `"10500"` dirham → `10.5` LYD
  /// - `"1"` dirham → `0.001` LYD
  /// - `"0"` dirham → `0.0` LYD
  ///
  /// [dirhamAmountString] String representation of dirham amount
  /// Returns the equivalent amount in Libyan Dinars
  ///
  /// Throws [ArgumentError] if the string cannot be parsed as a valid integer
  /// Throws [ArgumentError] if the parsed amount is negative
  static double dirhamToDinar(String dirhamAmountString) {
    try {
      double dirhamAmount = double.parse(dirhamAmountString);
      if (dirhamAmount < 0) {
        throw ArgumentError('Dirham amount cannot be negative: $dirhamAmount');
      }
      return dirhamAmount / _conversionRate;
    } on FormatException {
      throw ArgumentError('Invalid dirham amount format: $dirhamAmountString');
    }
  }

  /// Validates if a string represents a valid dirham amount.
  ///
  /// Checks if the provided string can be parsed as a valid non-negative
  /// integer representing dirham amount.
  ///
  /// **Examples:**
  /// - `"1000"` → `true`
  /// - `"0"` → `true`
  /// - `"10.5"` → `false` (contains decimal)
  /// - `"-100"` → `false` (negative)
  /// - `"abc"` → `false` (not a number)
  ///
  /// [dirhamAmountString] String to validate
  /// Returns `true` if valid dirham amount, `false` otherwise
  static bool isValidDirhamAmount(String dirhamAmountString) {
    try {
      int dirhamAmount = int.parse(dirhamAmountString);
      return dirhamAmount >= 0;
    } on FormatException {
      return false;
    }
  }

  /// Validates if a string represents a valid dinar amount.
  ///
  /// Checks if the provided string can be parsed as a valid non-negative
  /// number representing dinar amount.
  ///
  /// **Examples:**
  /// - `"1.0"` → `true`
  /// - `"10.5"` → `true`
  /// - `"0"` → `true`
  /// - `"-1.5"` → `false` (negative)
  /// - `"abc"` → `false` (not a number)
  ///
  /// [dinarAmountString] String to validate
  /// Returns `true` if valid dinar amount, `false` otherwise
  static bool isValidDinarAmount(String dinarAmountString) {
    try {
      double dinarAmount = double.parse(dinarAmountString);
      return dinarAmount >= 0;
    } on FormatException {
      return false;
    }
  }

  /// Formats a dinar amount for display purposes.
  ///
  /// Takes a double dinar amount and formats it as a user-friendly string
  /// with appropriate decimal places and currency symbol.
  ///
  /// **Examples:**
  /// - `1.0` → `"1.00 LYD"`
  /// - `10.5` → `"10.50 LYD"`
  /// - `0.001` → `"0.001 LYD"`
  ///
  /// [dinarAmount] The amount in Libyan Dinars
  /// [showCurrency] Whether to include the currency symbol (default: true)
  /// Returns formatted string representation
  static String formatDinarAmount(double dinarAmount,
      {bool showCurrency = true}) {
    if (dinarAmount < 0) {
      throw ArgumentError('Dinar amount cannot be negative: $dinarAmount');
    }

    String formatted;
    if (dinarAmount == dinarAmount.truncate()) {
      // Whole number, show 2 decimal places
      formatted = dinarAmount.toStringAsFixed(2);
    } else if (dinarAmount * 1000 == (dinarAmount * 1000).truncate()) {
      // Has up to 3 decimal places
      formatted = dinarAmount.toStringAsFixed(3);
    } else {
      // More than 3 decimal places, round to 3
      formatted = dinarAmount.toStringAsFixed(3);
    }

    return showCurrency ? '$formatted LYD' : formatted;
  }

  /// Formats a dirham amount for display purposes.
  ///
  /// Takes a string dirham amount and formats it as a user-friendly string
  /// with thousands separators.
  ///
  /// **Examples:**
  /// - `"1000"` → `"1,000 dirham"`
  /// - `"10500"` → `"10,500 dirham"`
  /// - `"1"` → `"1 dirham"`
  ///
  /// [dirhamAmountString] String representation of dirham amount
  /// [showCurrency] Whether to include the currency unit (default: true)
  /// Returns formatted string representation
  ///
  /// Throws [ArgumentError] if the string is not a valid dirham amount
  static String formatDirhamAmount(String dirhamAmountString,
      {bool showCurrency = true}) {
    if (!isValidDirhamAmount(dirhamAmountString)) {
      throw ArgumentError('Invalid dirham amount: $dirhamAmountString');
    }

    int amount = int.parse(dirhamAmountString);
    String formatted = _addThousandsSeparator(amount.toString());

    return showCurrency ? '$formatted dirham' : formatted;
  }

  /// Adds thousands separators to a number string.
  ///
  /// Internal helper method to format large numbers with commas.
  ///
  /// [numberString] String representation of a number
  /// Returns formatted string with thousands separators
  static String _addThousandsSeparator(String numberString) {
    if (numberString.length <= 3) return numberString;

    String result = '';
    int count = 0;

    for (int i = numberString.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = numberString[i] + result;
      count++;
    }

    return result;
  }

  /// Gets the conversion rate between Dinar and Dirham.
  ///
  /// Returns the number of dirham in one dinar.
  /// This is a constant value but provided as a method for API consistency.
  ///
  /// Returns: `1000` (1 LYD = 1000 dirham)
  static int get conversionRate => _conversionRate;
}
