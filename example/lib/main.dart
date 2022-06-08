import 'package:flutter/material.dart';
import 'package:mappedin_sdk_fluter/mappedin_sdk_fluter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            Expanded(
              child: MapdinNativeWidget(
                onMapdinNativeWidgetCreated: _onMapdinNativeWidgetCreated,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMapdinNativeWidgetCreated(MapdinNativeWidgetController controller) async {
    controller.updatePosition(lat: 43.52165214, long: -80.53675);
    if (mounted) {
      var platformVersion = (await controller.platformVersion) ?? "Ooopps!";
      setState(() {
        _platformVersion = platformVersion;
      });
    }
  }
}
