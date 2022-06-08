import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './add_device_screen.dart';

const devicesBox = 'devices';

class SavedDevicesScreen extends StatefulWidget {
  const SavedDevicesScreen({Key? key}) : super(key: key);

  @override
  State<SavedDevicesScreen> createState() => _SavedDevicesScreenState();
}

class _SavedDevicesScreenState extends State<SavedDevicesScreen> {
  var box = Hive.box(devicesBox);

  void addOrEditDevice(name, coordinate, {String prevName = ""}) {
    if (prevName.isNotEmpty && prevName != name) {
      box.delete(prevName);
    }
    final Map prevValue = box.get(name, defaultValue: {});
    box.put(name, {
      ...prevValue,
      'coordinate': coordinate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Devices'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(devicesBox).listenable(),
        builder: (context, Box box, widget) {
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final String name = box.keys.toList()[index];
              final String coordinate =
                  box.values.toList()[index]['coordinate'];
              return ListTile(
                title: Text(name),
                subtitle: Text(coordinate),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDeviceScreen(
                              callback: addOrEditDevice,
                              name: name,
                              coordinate: coordinate,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        box.delete(name);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDeviceScreen(
                callback: addOrEditDevice,
              ),
            ),
          );
        },
        tooltip: 'Add/Edit device',
        child: const Icon(Icons.add_box_rounded),
      ),
    );
  }
}
