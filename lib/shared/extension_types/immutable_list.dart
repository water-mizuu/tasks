
/// A wrapper around [List] that compile-time mutation impossible.
extension type const ImmutableList<T>(List<T> _) implements Iterable<T> {
  T operator [](int index) => _[index];
  int get length => _.length;
}
