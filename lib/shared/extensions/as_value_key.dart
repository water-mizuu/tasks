import "package:flutter/material.dart";

extension AsValueKeyExtension<T> on T {
  ValueKey<T> asValueKey() => ValueKey<T>(this);
}
