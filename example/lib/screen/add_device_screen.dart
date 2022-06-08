import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddDeviceScreen extends StatefulWidget {
  final Function callback;
  final String name;
  final String coordinate;
  const AddDeviceScreen(
      {Key? key, required this.callback, this.name = "", this.coordinate = ""})
      : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _coordinateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _coordinateController.text = widget.coordinate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _coordinateController.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add device'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _coordinateController,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: const Icon(Icons.location_on),
                tooltip: 'Get current location',
                onPressed: () {
                  _determinePosition().then((position) {
                    _coordinateController.text =
                        '${position.latitude},${position.longitude}';
                  });
                },
              ),
              border: const OutlineInputBorder(),
              labelText: 'Coordinate',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.callback(_nameController.text, _coordinateController.text,
                  prevName: widget.name);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
