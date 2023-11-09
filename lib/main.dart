import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:tasks/widgets/screens/main/main.dart";

void main() async {
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
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Navigator(
        pages: const <Page<Object>>[
          MaterialPage<Object>(child: Home()),
        ],
        onPopPage: (Route<Object?> route, Object? b) {
          return route.didPop(b);
        },
      ),
    );
  }
}
