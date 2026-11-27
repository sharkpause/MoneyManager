/// Discriminated union representing either a successful value or an error.
sealed class Result<T> {
  const Result();
}

/// Successful outcome carrying [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Failed outcome carrying a human-readable [message] and optional [cause].
final class Err<T> extends Result<T> {
  const Err(this.message, [this.cause]);

  final String message;
  final Object? cause;
}
