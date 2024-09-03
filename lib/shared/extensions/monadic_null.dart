extension MonadicNull<T extends Object> on T? {
  R? map<R>(R Function(T value) f) {
    return switch (this) {
      T value => f(value),
      null => null,
    };
  }
}
