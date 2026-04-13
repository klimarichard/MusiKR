/// A discriminated union for domain operation results.
///
/// Use [Ok] for success, [Err] for failure.
/// Avoids throwing exceptions across the domain boundary.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final String message;
  final Object? cause;
  const Err(this.message, {this.cause});
}
