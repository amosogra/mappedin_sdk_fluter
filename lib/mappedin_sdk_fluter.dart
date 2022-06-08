// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'package:flutter/services.dart';
export 'package:mappedin_sdk_fluter/widget/mapdin_native_widget.dart';

class MapdinNativeWidgetController {
  MapdinNativeWidgetController.init(int id) : _channel = MethodChannel('plugins.amos.views/mappedin_$id');
  final MethodChannel? _channel;

  Future<String?> get platformVersion async {
    final String? version = await _channel?.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool?> updatePosition({double? lat, double? long}) async {
    return await _channel?.invokeMethod(
      "updatePosition",
      {
        "lat": lat??43.52165214,
        "long": long??-80.53675,
      },
    );
  }
}
