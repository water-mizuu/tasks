extension ZipExtension<T> on Iterable<T> {
  Iterable<(T, R)> zip<R>(Iterable<R> other) sync* {
    Iterator<T> iterator = this.iterator;
    Iterator<R> otherIterator = other.iterator;

    while (iterator.moveNext() && otherIterator.moveNext()) {
      yield (iterator.current, otherIterator.current);
    }
  }
}
