import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import './screen/saved_devices_screen.dart';
import './utils/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

const devicesBox = 'devices';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(devicesBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'BLE POC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const CHANNEL = "plugins.amos.views/mappedin";
  // static const MAP_CHANNEL = "com.example.ble_poc/map_channel";
  static const platform = MethodChannel(CHANNEL);
  // static const map_platform = MethodChannel(MAP_CHANNEL);

  List<dynamic> devices = [];
  late Timer periodicTask;
  Map foundDevices = {};
  bool isScanning = false;
  var box = Hive.box(devicesBox);

  void openMap() async {
    try {
      platform.invokeMethod('goToSecondActivity');
      Timer.periodic(const Duration(seconds: 3), (Timer t) {
        print("Periodic task");
        platform.invokeMethod(
          "updatePosition",
          {
            "lat": 43.52165214,
            "long": -80.53675,
          },
        );
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

    void scanDevices() {
      // Start scanning
      flutterBlue.startScan(timeout: const Duration(seconds: 3));

      // Listen to scan results
      flutterBlue.scanResults.listen(
        (results) {
          for (ScanResult r in results) {
            if (r.device.name.startsWith('ID1_')) {
              final manufacturerData =
                  r.advertisementData.manufacturerData.values.first;
              final flags =
                  manufacturerData[1].toRadixString(2).padLeft(8, '0');
              final bool isLowBattery = flags[1] == '1';
              final bool batteryVoltagePresent = flags[0] == '1';
              int? batteryVoltage;
              if (batteryVoltagePresent) {
                batteryVoltage = 2000 + manufacturerData[2] * 10;
              }
              final device = {
                'id': r.device.id.toString(),
                'name': r.device.name,
                'rssi': r.rssi,
                'distance': estimateDistance(r.rssi),
                'connectable': r.advertisementData.connectable,
                'manufacturerData': r.advertisementData.manufacturerData,
                'isLowBattery': isLowBattery,
                'batteryVoltagePresent': batteryVoltagePresent,
                'batteryVoltage': batteryVoltage,
              };
              // DateTime timeNow = DateTime.now();
              // print(
              //     '${timeNow.hour}:${timeNow.minute}:${timeNow.second} - ${device}');
              foundDevices[r.device.id.toString()] = device;
            }
          }

          setState(() {
            devices = foundDevices.values.toList();
          });
        },
      );
    }

    void toggleScan() {
      setState(() {
        isScanning = !isScanning;
      });
      if (isScanning) {
        print("Scan started");
        const aboutThreeSec = Duration(milliseconds: 3200);
        periodicTask = Timer.periodic(
          aboutThreeSec,
          (Timer t) {
            scanDevices();
            flutterBlue.stopScan();
          },
        );
      } else {
        periodicTask.cancel();
        flutterBlue.stopScan();
        print("Scan stopped");
      }
    }

    Widget coordinateTile(coordinate) {
      if (coordinate == null) {
        return const SizedBox.shrink();
      }

      return ListTile(
        title: Text('Coordinate: ${coordinate['coordinate']}'),
      );
    }

    Widget batteryWidgetBuilder(bool isLowBattery) {
      return RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
          children: [
            TextSpan(
              text: isLowBattery ? "Low battery" : "Battery OK",
            ),
            WidgetSpan(
              child: isLowBattery
                  ?  const Icon(Icons.battery_alert, size: 16, color: Colors.red)
                  :  const Icon(
                      Icons.battery_charging_full,
                      size: 16,
                      color: Colors.green,
                    ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: openMap,
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    Map<String, double>? coordinate =
                        whereAmI(List.from(devices));
                    String message;
                    if (coordinate == null) {
                      message = "Need at least two beacons nearby";
                    } else {
                      message =
                          "You are at ${coordinate['x']}, ${coordinate['y']}";
                    }

                    Fluttertoast.showToast(
                      msg: message,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0,
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Saved Devices'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedDevicesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(devices[index]['name']),
            subtitle: Text('${devices[index]['id']}'),
            trailing: Column(
              children: [
                Text('${devices[index]['rssi'].toString()} dBm'),
                Text('${devices[index]['distance'].toString()} m'),
              ],
            ),
            children: <Widget>[
              ListTile(
                title: const Text('Manufacturer Data'),
                subtitle: Text('${devices[index]['manufacturerData']}'),
              ),
              ListTile(
                title: const Text('Connectable'),
                subtitle: Text('${devices[index]['connectable']}'),
              ),
              ListTile(
                title: const Text('Battery Voltage Present'),
                subtitle: Text(
                    '${devices[index]['batteryVoltagePresent']} - ${devices[index]['batteryVoltage']}mV'),
              ),
              ListTile(
                title: batteryWidgetBuilder(devices[index]['isLowBattery']),
              ),
              coordinateTile(
                  box.get(devices[index]['name'], defaultValue: null)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleScan,
        tooltip: isScanning ? 'Stop Scan' : 'Scan',
        child: isScanning
            ? const Icon(Icons.search_off)
            : const Icon(Icons.search),
      ),
    );
  }
}
