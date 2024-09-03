import "package:flutter/material.dart";

class ChangeActiveTaskListIndexNotification extends Notification {
  const ChangeActiveTaskListIndexNotification(this.index);

  final int index;
}
