// ignore_for_file: discarded_futures

import "dart:math" as math;

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class MouseScroll extends StatefulWidget {
  const MouseScroll({
    required this.builder,
    this.controller,
    super.key,
    this.mobilePhysics = kMobilePhysics,
    this.duration = const Duration(milliseconds: 760),
    this.animationCurve = Curves.easeOutQuart,
  });
  final ScrollController? controller;
  final ScrollPhysics mobilePhysics;
  final Duration duration;
  final Curve animationCurve;
  final Widget Function(BuildContext, ScrollController, ScrollPhysics) builder;

  @override
  State<MouseScroll> createState() => _MouseScrollState();
}

class _MouseScrollState extends State<MouseScroll> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller case null) {
      scrollController.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MouseScroll oldWidget) {
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller case null) {
        scrollController.dispose();
      }
      scrollController = widget.controller ?? ScrollController();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScrollState>(
      create: (BuildContext context) => ScrollState(widget.mobilePhysics, scrollController, widget.duration),
      builder: (BuildContext context, _) {
        ScrollState scrollState = context.read<ScrollState>();
        ScrollController controller = scrollState.controller;
        var (ScrollPhysics physics, _) = context.select((ScrollState s) => (s.activePhysics, s.updateState));

        scrollState.handlePipelinedScroll?.call();
        return Listener(
          onPointerSignal: (PointerSignalEvent signalEvent) => //
              scrollState.handleDesktopScroll(signalEvent, widget.animationCurve),
          onPointerDown: (PointerDownEvent pointerEvent) => //
              scrollState.handleTouchScroll(pointerEvent),
          child: widget.builder(context, controller, physics),
        );
      },
    );
  }
}

const BouncingScrollPhysics kMobilePhysics = BouncingScrollPhysics();
const NeverScrollableScrollPhysics kDesktopPhysics = NeverScrollableScrollPhysics();

class ScrollState with ChangeNotifier {
  ScrollState(this.mobilePhysics, this.controller, this.duration);

  final ScrollPhysics mobilePhysics;
  final ScrollController controller;
  final Duration duration;

  late ScrollPhysics activePhysics = mobilePhysics;
  double _futurePosition = 0;
  bool updateState = false;

  bool _isPreviousDeltaPositive = false;
  double? _lastLock;

  Future<void>? currentAnimationEnd;

  /// Scroll that is pipelined to be handled after the current render is finished.
  /// This is used to ensure that the scroll is handled while transitioning from physics.
  void Function()? handlePipelinedScroll;

  static double calcMaxDelta(ScrollController controller, double delta) {
    double pixels = controller.position.pixels;

    return delta.sign > 0
        ? math.min(pixels + delta, controller.position.maxScrollExtent) - pixels
        : math.max(pixels + delta, controller.position.minScrollExtent) - pixels;
  }

  void handleDesktopScroll(
    PointerSignalEvent event,
    Curve animationCurve, {
    bool shouldReadLastDirection = true,
  }) {
    // Ensure desktop physics is being used.
    if (activePhysics == kMobilePhysics || _lastLock != null) {
      if (_lastLock != null) {
        updateState = !updateState;
      }
      if (event case PointerScrollEvent()) {
        double pixels = controller.position.pixels;

        /// If the scroll is at the top or bottom, don't allow the user to scroll further.
        if (pixels <= controller.position.minScrollExtent && event.scrollDelta.dy < 0 ||
            pixels >= controller.position.maxScrollExtent && event.scrollDelta.dy > 0) {
          return;
        }
        activePhysics = kDesktopPhysics;
        double computedDelta = calcMaxDelta(controller, event.scrollDelta.dy);
        bool isOutOfBounds = false || //
            pixels < controller.position.minScrollExtent || //
            pixels > controller.position.maxScrollExtent;

        if (!isOutOfBounds) {
          controller.animateTo(_lastLock ?? (pixels - computedDelta), duration: Duration.zero, curve: Curves.linear);
        }
        double deltaDifference = computedDelta - event.scrollDelta.dy;
        handlePipelinedScroll = () {
          handlePipelinedScroll = null;
          double currentPos = controller.position.pixels;
          double currentDelta = event.scrollDelta.dy;
          bool shouldLock = _lastLock != null
              ? (_lastLock == currentPos)
              : (pixels != currentPos + deltaDifference &&
                  (currentPos != controller.position.maxScrollExtent || currentDelta < 0) &&
                  (currentPos != controller.position.minScrollExtent || currentDelta > 0));

          if (!isOutOfBounds && shouldLock) {
            controller.animateTo(pixels, duration: Duration.zero, curve: Curves.linear);
            _lastLock = pixels;
            controller.position.moveTo(pixels).whenComplete(() {
              if (activePhysics == kDesktopPhysics) {
                activePhysics = kMobilePhysics;
                notifyListeners();
              }
            });
            return;
          } else {
            if (_lastLock != null || isOutOfBounds) {
              double jumpTarget = _lastLock != null //
                  ? pixels
                  : (currentPos - calcMaxDelta(controller, currentDelta));

              controller.animateTo(jumpTarget, duration: Duration.zero, curve: Curves.linear);
            }
            _lastLock = null;
            handleDesktopScroll(event, animationCurve, shouldReadLastDirection: false);
          }
        };
        notifyListeners();
      }
    } else if (event case PointerScrollEvent()) {
      bool isCurrentDeltaPositive = event.scrollDelta.dy > 0;

      _futurePosition = !shouldReadLastDirection || (isCurrentDeltaPositive ^ _isPreviousDeltaPositive)
          ? controller.position.pixels + event.scrollDelta.dy
          : _futurePosition + event.scrollDelta.dy;

      Future<void> animationEnd = currentAnimationEnd = controller.animateTo(
        _futurePosition,
        duration: duration,
        curve: animationCurve,
      );
      animationEnd.whenComplete(() {
        if (animationEnd == currentAnimationEnd && activePhysics == kDesktopPhysics) {
          activePhysics = mobilePhysics;
          notifyListeners();
        }
      });
      _isPreviousDeltaPositive = isCurrentDeltaPositive;
    }
  }

  void handleTouchScroll(PointerDownEvent event) {
    if (activePhysics == kDesktopPhysics) {
      activePhysics = mobilePhysics;
      notifyListeners();
    }
  }
}
