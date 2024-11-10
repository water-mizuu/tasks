import "dart:io";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:overlay_support/overlay_support.dart";
import "package:scroll_animator/scroll_animator.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:tasks/back_end/database/database_helper.dart";
import "package:tasks/widgets/screens/main/main.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await DatabaseHelper.init();
  runApp(const Application());
}

///
class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        // By default, MaterialApp and CupertinoApp map ScrollIntent to
        // ScrollAction, which applies a fixed ease-in-out curve and 100ms
        // duration. To use custom scroll animations with dynamic parameters,
        // which this package provides, map ScrollIntent to
        // AnimatedScrollAction in the actions property as shown here.
        actions: <Type, Action<Intent>>{
          ...WidgetsApp.defaultActions,
          ScrollIntent: AnimatedScrollAction(),
        },
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: AnimatedPrimaryScrollController(
          child: Builder(
            builder: (BuildContext context) {
              return Navigator(
                pages: const <Page<Object>>[
                  MaterialPage<Object>(child: Home()),
                ],
                onDidRemovePage: (Page<Object?> page) {},
              );
            },
          ),
        ),
      ),
    );
  }
}
