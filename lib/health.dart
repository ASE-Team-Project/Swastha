import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/health.dart';


class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
  _HealthAppState obj = _HealthAppState();
}

class _HealthAppState extends State<HealthApp> {
  List<HealthDataPoint> _healthDataList = [];
  int _nofSteps = 10;
  double _spo2_percentage = 10;
  double _heartrate = 10;
  double _mgdl = 10.0;
  bool run_once = true;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchDataEveryMinute(DateTime previous, DateTime now) async {
    print("Today Data");

    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_IN_BED,
      //HealthDataType.FLIGHTS_CLIMBED,
      HealthDataType.DISTANCE_DELTA,
      //HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      //HealthDataType.BASAL_ENERGY_BURNED
    ];

    // with coresponsing permissions
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      //HealthDataAccess.READ,
      //HealthDataAccess.READ,
      //HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    //final now = DateTime.now();
    //final minuteago = DateTime(now.year, now.month, now.day,now.hour, now.minute -1);
    // requesting access to the data types before reading them
    // note that strictly speaking, the [permissions] are not
    // needed, since we only want READ access.
    bool requested =
    await health.requestAuthorization(types, permissions: permissions);
    print('requested: $requested');

    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    List<HealthDataPoint> healthData = [];
    if (requested) {
      try {
        // fetch health data
        healthData =
        await health.getHealthDataFromTypes(previous, now, types);
        // save all the new data points (only the first 100)
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      healthData = HealthFactory.removeDuplicates(healthData);

      // print the results
      healthData.forEach((x) => print(x));
      List data = [];
      healthData.forEach((element) {
        data.add(element.toJson());
      });
      return data;
      // update the UI to display the results
      print("Fetched Data");
    } else {
      print("Authorization not granted");
      return [];
    }
  }
  Future printfunc() async{
    print("Print func running every 15 seconds");
    var duration = const Duration(seconds: 5);
    sleep(duration);
    print("Print func running every 15 seconds; After");

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("data fetched");
  }
}

Future insertData(List results) async{
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  int i =0;
  results.forEach((datapoint) {
    String s = "datapoint" + i.toString();
    i = i+1;
    ref.child(s).set(datapoint);
  });
}

Future fetchPreviousTime() async{
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child('/healthdata/kC9B9MKAspZh4t6dOr7D').get();
  if(snapshot.exists){
    print(snapshot.value);
  }
  else{
    print("data not found");
  }
}