import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  late SharedPreferences preferences;
  bool requested = false;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();
  Future fetchPermissions() async{

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
    //requested =  await health.requestAuthorization(types, permissions: permissions);
    await Permission.activityRecognition.request();
  }
  /// Fetch data points from the health plugin and show them in the app.
  Future fetchDataEveryMinute(DateTime previous, DateTime now) async {
    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      //HealthDataType.BODY_MASS_INDEX,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.ACTIVE_ENERGY_BURNED,
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
      //HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    //final now = DateTime.now();
    //final minuteago = DateTime(now.year, now.month, now.day,now.hour, now.minute -1);
    // requesting access to the data types before reading them
    // note that strictly speaking, the [permissions] are not
    // needed, since we only want READ access.
    List<HealthDataPoint> healthData = [];
    requested = await health.requestAuthorization(types, permissions: permissions);
    if (requested) {
      try {
        // fetch health data
        healthData = await health.getHealthDataFromTypes(previous, now, types);
        // save all the new data points (only the first 100)
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      healthData = HealthFactory.removeDuplicates(healthData);

      // print the results
      List data = [];
      healthData.forEach((element) {
        Map s = element.toJson();
        s["value"] = s["value"]["numericValue"];
        s.remove("platform_type");
        s.remove("source_name");
        s.remove("source_id");
        s.remove("device_id");
        data.add(s);
      });
    return data;
      // update the UI to display the results
    }
    else {
      print("Authorisation not granted");
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("data fetched");
  }
}

Future insertData(List results, String uuid) async {
  print("UUID is : " + uuid);
  await Firebase.initializeApp();
  if (uuid != "") {
    // final DatabaseReference ref = FirebaseDatabase.instance.ref();
    final DocumentReference ref = FirebaseFirestore.instance
        .collection("data")
        .doc(uuid);
    final documentdata = await ref.get();
    String previoustime = "";
    try{
      previoustime = documentdata["timestamp"];
    }
    catch (e){
      previoustime = "";
    }
    results.forEach((final datapoint) {
      bool requiredtypes = false;
      final HashMap<String,dynamic> x = HashMap<String,dynamic>.from(datapoint);
      x["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
      switch(datapoint["data_type"]) {
        case "ACTIVE_ENERGY_BURNED":{
          ref.collection("ACTIVE_ENERGY_BURNED").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          break;
        }
        case "DISTANCE_DELTA":{
          ref.collection("DISTANCE_DELTA").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          break;
        }
        case "HEART_RATE":{
          ref.collection("HEART_RATE").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "STEPS":{
          ref.collection("STEPS").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "WEIGHT":{
          ref.collection("WEIGHT").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "HEIGHT":{
          ref.collection("HEIGHT").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "BODY_MASS_INDEX":{
          ref.collection("BODY_MASS_INDEX").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "SLEEP_ASLEEP":{
          ref.collection("SLEEP_ASLEEP").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "SLEEP_AWAKE":{
          ref.collection("SLEEP_AWAKE").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "SLEEP_IN_BED":{
          ref.collection("SLEEP_IN_BED").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
        case "BLOOD_OXYGEN":{
          ref.collection("BLOOD_OXYGEN").doc(DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()).set(x);
          requiredtypes = true;
          break;
        }
      }
      if(requiredtypes) {
        print("Required Types");
        var timestamp = {"timestamp": DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()};
        if (previoustime != "") {
          ref.update(timestamp);
        }
        else {
          ref.set(timestamp);
        }
      }
    });
  }
}

@pragma('vm:entry-point')
Future fetchHealth(HealthApp healthapp) async {
  final preferences = await SharedPreferences.getInstance();
  if(preferences.get("fetchrunning") == "false"){
    preferences.setString("fetchrunning", "true");
    //Health
    String uuid = preferences.getString("id")!;

    DateTime previous = await fetchPreviousTime(uuid);
    print("Previous time: " + previous.toString());
    DateTime now = DateTime.now();
    List result = await healthapp.obj.fetchDataEveryMinute(previous, now);
    if (result.isNotEmpty) {
      await insertData(result, uuid);
    }
    preferences.setString("fetchrunning", "false");
  }
  else{
    print("Already Running");
  }
}
Future<DateTime> fetchPreviousTime(String uuid) async {
  await Firebase.initializeApp();
  DateTime past7days =  new DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 7
  );
  if (uuid != "") {
    final ref = await FirebaseFirestore.instance
        .collection("data")
        .doc(uuid).get();
    String previoustime = "";
    try{
      previoustime = ref["timestamp"];
    }
    catch (e){
      return past7days;
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(previoustime));
  }
  else {
    return past7days;
  }
}
