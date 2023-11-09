import "package:flutter/material.dart";

class Responsive extends StatelessWidget {
  const Responsive({
    required this.desktopBuilder,
    required this.mobileBuilder,
    super.key,
  });

  final Widget Function(BuildContext) desktopBuilder;
  final Widget Function(BuildContext) mobileBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return switch (constraints.maxWidth) {
          <= 800 => mobileBuilder(context),
          _ => desktopBuilder(context),
        };
      },
    );
  }
}
