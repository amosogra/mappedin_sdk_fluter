
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mappedin_sdk_fluter/mappedin_sdk_fluter.dart';

typedef MapdinNativeWidgetCreatedCallback = void Function(MapdinNativeWidgetController controller);

class MapdinNativeWidget extends StatefulWidget {
  const MapdinNativeWidget({
    Key? key,
    this.onMapdinNativeWidgetCreated,
  }) : super(key: key);

  final MapdinNativeWidgetCreatedCallback? onMapdinNativeWidgetCreated;

  @override
  State<StatefulWidget> createState() => _MapdinNativeWidgetState();
}

class _MapdinNativeWidgetState extends State<MapdinNativeWidget> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.amos.views/mappedin',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return const Text('iOS platform version is not implemented yet.');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onMapdinNativeWidgetCreated == null) {
      return;
    }
    widget.onMapdinNativeWidgetCreated!(MapdinNativeWidgetController.init(id));
  }
}
