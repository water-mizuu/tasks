extension MapPairsExtension<K, V> on Map<K, V> {
  Iterable<(K, V)> get pairs sync* {
    for (var MapEntry<K, V>(:K key, :V value) in entries) {
      yield (key, value);
    }
  }
}
