import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';

const devicesBox = 'devices';
const double rssD0 = -64.0;
const double n = 1.99;

double estimateDistance(num rssi) {
  return double.parse((pow(10, (rssD0 - rssi) / (10 * n)).toStringAsFixed(2)));
}

Map<String, double> getBeaconCoordinate(String name) {
  var box = Hive.box(devicesBox);
  var info = box.get(name);
  List coordinate = info['coordinate']
      .split(',')
      .map((string) => double.parse(string))
      .toList();
  Map<String, double> beaconCoordinate = {
    'longitude': coordinate[0],
    'latitude': coordinate[1],
  };

  return beaconCoordinate;
}

Map<String, double>? whereAmI(List devices) {
  if (devices.length <= 1) {
    return null;
  }

  devices.sort((a, b) => b['rssi'].compareTo(a['rssi']));

  var beacon1 = getBeaconCoordinate(devices[0]['name']);
  var beacon2 = getBeaconCoordinate(devices[1]['name']);
  if (devices.length == 2) {
    return {
      'x': (beacon1['longitude']! + beacon2['longitude']!) / 2.0,
      'y': (beacon1['latitude']! + beacon2['latitude']!) / 2.0,
    };
  }

  // Weighted Trilateration Position the nearest three beacons
  var beacon3 = getBeaconCoordinate(devices[0]['name']);
  double distance1 = estimateDistance(devices[0]['rssi']);
  double distance2 = estimateDistance(devices[1]['rssi']);
  double distance3 = estimateDistance(devices[2]['rssi']);

  double a = (-2 * beacon1['longitude']!) + (2 * beacon2['longitude']!);
  double b = (-2 * beacon1['latitude']!) + (2 * beacon2['latitude']!);
  num c = pow(distance1, 2) -
      pow(distance2, 2) -
      pow(beacon1['longitude']!, 2) +
      pow(beacon2['longitude']!, 2) -
      pow(beacon1['latitude']!, 2) +
      pow(beacon2['latitude']!, 2);
  double d = (-2 * beacon2['longitude']!) + (2 * beacon3['longitude']!);
  double e = (-2 * beacon2['latitude']!) + (2 * beacon3['latitude']!);
  num f = pow(distance2, 2) -
      pow(distance3, 2) -
      pow(beacon2['longitude']!, 2) +
      pow(beacon3['longitude']!, 2) -
      pow(beacon2['latitude']!, 2) +
      pow(beacon3['latitude']!, 2);

  double x = (c * e - f * b) / (e * a - b * d);
  double y = (c * d - a * f) / (b * d - a * e);

  var coordinates = {'x': x, 'y': y};
  return coordinates;
}
