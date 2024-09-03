import "package:flutter/material.dart";

extension MaybeLocalToGlobal on RenderBox {
  Offset? maybeLocalToGlobal(Offset? point, {RenderBox? ancestor}) {
    if (point == null) {
      return null;
    }

    try {
      return localToGlobal(point, ancestor: ancestor);
    } on Object catch (_) {
      return null;
    }
  }
}
