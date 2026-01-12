// Safe math utilities to prevent NaN, Infinity, and division by zero crashes.
// All calculations use these functions to ensure defensive-by-design arithmetic.

/// Safely convert any double to a valid finite number.
/// Returns 0 if the value is NaN, Infinity, or not finite.
double safeDouble(double value) {
  if (value.isNaN || value.isInfinite || !value.isFinite) {
    return 0.0;
  }
  return value;
}

/// Safely divide two integers, returning a double.
/// Returns 0.0 if denominator is 0.
double safeDivide(int numerator, int denominator) {
  if (denominator == 0) return 0.0;
  final result = numerator / denominator;
  return safeDouble(result);
}

/// Safely divide two doubles, returning a double.
/// Returns 0.0 if denominator is 0.
double safeDivideDouble(double numerator, double denominator) {
  if (denominator == 0.0) return 0.0;
  final result = numerator / denominator;
  return safeDouble(result);
}

/// Safely calculate a percentage (0-100) from numerator and denominator.
/// Returns 0.0 if denominator is 0.
double safePercentage(int numerator, int denominator) {
  if (denominator == 0) return 0.0;
  final result = (numerator / denominator) * 100.0;
  return safeDouble(result);
}

/// Safely round a double to an integer.
/// Returns 0 if the value is NaN or Infinity.
int safeRound(double value) {
  final safe = safeDouble(value);
  if (!safe.isFinite) return 0;
  return safe.round();
}

/// Safely convert a percentage (0-100) to a normalized value (0.0-1.0).
/// Returns 0.0 if value is NaN or Infinity.
double percentToNormalized(int percentage) {
  if (percentage < 0 || percentage > 100) return 0.0;
  final result = percentage / 100.0;
  return safeDouble(result);
}
