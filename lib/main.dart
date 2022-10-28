import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() => runApp(HealthApp());

class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_NOT_ADDED,
  STEPS_READY,
  BLOOD_OXYGEN_READY,
  HEART_RATE_READY,
}

class _HealthAppState extends State<HealthApp> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 10;
  double _spo2_percentage = 10;
  double _heartrate = 10;
  double _mgdl = 10.0;
  bool run_once = true;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WORKOUT,
      // Uncomment these lines on iOS - only available on iOS
      // HealthDataType.AUDIOGRAM
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
      // HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 5));
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
    await Permission.location.request();

    if (requested) {
      try {
        // fetch health data
        List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(yesterday, now, types);
        // save all the new data points (only the first 100)
        _healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      // print the results
      _healthDataList.forEach((x) => print(x));

      // update the UI to display the results
      setState(() {
        _state =
        _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  /// Add some random health data.
  Future addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WORKOUT, // Requires Google Fit on Android
      // Uncomment these lines on iOS - only available on iOS
      // HealthDataType.AUDIOGRAM,
    ];
    final rights = [
      HealthDataAccess.WRITE,
      HealthDataAccess.WRITE,
      HealthDataAccess.WRITE,
      HealthDataAccess.WRITE,
      // HealthDataAccess.WRITE
    ];
    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      // HealthDataAccess.READ_WRITE,
    ];
    late bool perm;
    bool? hasPermissions =
    await HealthFactory.hasPermissions(types, permissions: rights);
    if (hasPermissions == false) {
      perm = await health.requestAuthorization(types, permissions: permissions);
    }

    // Store a count of steps taken
    _nofSteps = Random().nextInt(10);
    _spo2_percentage = Random().nextDouble();
    _heartrate = Random().nextDouble();
    bool success = await health.writeHealthData(
        _nofSteps.toDouble(), HealthDataType.STEPS, earlier, now);

    // Store a height
    success &=
    await health.writeHealthData(1.93, HealthDataType.HEIGHT, earlier, now);

    // Store a Blood Glucose measurement
    _mgdl = Random().nextInt(10) * 1.0;
    success &= await health.writeHealthData(
        _mgdl, HealthDataType.BLOOD_GLUCOSE, now, now);

    // Store a workout eg. running
    success &= await health.writeWorkoutData(
      HealthWorkoutActivityType.RUNNING, earlier, now,
      // The following are optional parameters
      // and the UNITS are functional on iOS ONLY!
      totalEnergyBurned: 230,
      totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      totalDistance: 1234,
      totalDistanceUnit: HealthDataUnit.FOOT,
    );

    // Store an Audiogram
    // Uncomment these on iOS - only available on iOS
    // const frequencies = [125.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0];
    // const leftEarSensitivities = [49.0, 54.0, 89.0, 52.0, 77.0, 35.0];
    // const rightEarSensitivities = [76.0, 66.0, 90.0, 22.0, 85.0, 44.5];

    // success &= await health.writeAudiogram(
    //   frequencies,
    //   leftEarSensitivities,
    //   rightEarSensitivities,
    //   now,
    //   now,
    //   metadata: {
    //     "HKExternalUUID": "uniqueID",
    //     "HKDeviceName": "bluetooth headphone",
    //   },
    // );

    setState(() {
      _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    });
  }

  /// Fetch steps from the health plugin and show them in the app.
  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      setState(() {
        _nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Future fetchBloodOxygenData() async {
    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested =
    await health.requestAuthorization([HealthDataType.BLOOD_OXYGEN]);
    List<HealthDataPoint> blood_oxygen_data = [];
    if (requested) {
      try {
        final type = [
          HealthDataType.BLOOD_OXYGEN,
        ];
        blood_oxygen_data =
        await health.getHealthDataFromTypes(midnight, now, type);

        print(blood_oxygen_data.toString());
        // blood_oxygen_data.addAll((blood_oxygen_data.length < 100)
        //     ? blood_oxygen_data
        //     : blood_oxygen_data.sublist(0, 100));
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      // filter out duplicates
      if (blood_oxygen_data != Null) {
        blood_oxygen_data = HealthFactory.removeDuplicates(blood_oxygen_data);
        double spo2 = double.parse(
            blood_oxygen_data[blood_oxygen_data.length - 1].value.toString());
        spo2 = double.parse(spo2.toStringAsFixed(1));
        print('Blood Oxygen SpO2 $spo2 %');
        setState(() {
          _spo2_percentage = (spo2 == null) ? 0 : spo2;
          _state =
          (spo2 == null) ? AppState.NO_DATA : AppState.BLOOD_OXYGEN_READY;
        });
      }
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Future fetchHeartBeatData() async {
    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested =
    await health.requestAuthorization([HealthDataType.HEART_RATE]);
    List<HealthDataPoint> heart_rate_data = [];

    if (requested) {
      try {
        final type = [
          HealthDataType.HEART_RATE,
        ];
        heart_rate_data =
        await health.getHealthDataFromTypes(midnight, now, type);
        print(heart_rate_data.toString());
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
      if (heart_rate_data != Null) {
        heart_rate_data = HealthFactory.removeDuplicates(heart_rate_data);
        double heart_rate = double.parse(
            heart_rate_data[heart_rate_data.length - 1].value.toString());
        heart_rate = double.parse(heart_rate.toStringAsFixed(1));
        print('Heart Rate: $heart_rate BPM');

        setState(() {
          _heartrate = (heart_rate == null) ? 0 : heart_rate;
          _state = (heart_rate == null)
              ? AppState.NO_DATA
              : AppState.HEART_RATE_READY;
        });
      }
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {
    return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          if (p.value is AudiogramHealthValue) {
            return ListTile(
              title: Text("${p.typeString}: ${p.value}"),
              trailing: Text('${p.unitString}'),
              subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
            );
          }
          if (p.value is WorkoutHealthValue) {
            return ListTile(
              title: Text(
                  "${p.typeString}: ${(p.value as WorkoutHealthValue).totalEnergyBurned} ${(p.value as WorkoutHealthValue).totalEnergyBurnedUnit?.typeToString()}"),
              trailing: Text(
                  '${(p.value as WorkoutHealthValue).workoutActivityType.typeToString()}'),
              subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
            );
          }
          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text('${p.unitString}'),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Column(
      children: [
        Text('Press the download button to fetch data.'),
        Text('Press the plus button to insert some random data.'),
        Text('Press the walking button to get total step count.'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _authorizationNotGranted() {
    return Text('Authorization not given. '
        'For Android please check your OAUTH2 client ID is correct in Google Developer Console. '
        'For iOS check your permissions in Apple Health.');
  }

  Widget _dataAdded() {
    return Text('Data points inserted successfully!');
  }

  Widget _stepsFetched() {
    return Text('Total number of steps: $_nofSteps');
  }

  Widget _bloodOxygenFetched() {
    return Text('Blood Oxygen SpO2 level: $_spo2_percentage %');
  }

  Widget _heartRateFetched() {
    return Text('Heart Rate: $_heartrate bpm');
  }

  Widget _dataNotAdded() {
    return Text('Failed to add data');
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA)
      return _contentFetchingData();
    else if (_state == AppState.AUTH_NOT_GRANTED)
      return _authorizationNotGranted();
    else if (_state == AppState.DATA_ADDED)
      return _dataAdded();
    else if (_state == AppState.STEPS_READY)
      return _stepsFetched();
    else if (_state == AppState.BLOOD_OXYGEN_READY)
      return _bloodOxygenFetched();
    else if (_state == AppState.HEART_RATE_READY)
      return _heartRateFetched();
    else if (_state == AppState.DATA_NOT_ADDED) return _dataNotAdded();

    return _contentNotFetched();
  }

  @override
  Widget build(BuildContext context) {

    if(run_once){
      fetchBloodOxygenData();
      fetchHeartBeatData();
    }
    double heartbeat = _heartrate;
    double Sp02 = _spo2_percentage;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFFF5758),
        body: SafeArea(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://www.shivambhosale.com/img/shivam2.jpeg'),
              ),
              Text(
                "Shivam Bhosale",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color(0xFFFFFFFC)),
              ),
              SizedBox(
                height: 20.0,
                width: 150.0,
                child: Divider(
                  color: Colors.white,
                ),
              ),
              Card(
                color: Colors.white,
                shadowColor: Colors.black,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                // padding: EdgeInsets.all(10.0), Unlike Containers Cards do not have padding property.
                // Instead of that we can use the padding class to encompass the row widget.
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.monitor_heart,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text("BPM:$heartbeat",
                        style: TextStyle(fontSize: 30, color: Colors.black)),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shadowColor: Colors.black,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                // padding: EdgeInsets.all(10.0), Unlike Containers Cards do not have padding property.
                // Instead of that we can use the padding class to encompass the row widget.
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.bloodtype,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text("SpO2:$Sp02",
                        style: TextStyle(fontSize: 30, color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:health/health.dart';
// import 'dart:async';

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Color(0xFFFF5758),
//         body: SafeArea(
//           child: Column(
//             children: [
//               CircleAvatar(
//                 radius: 50,
//                 backgroundImage: NetworkImage(
//                     'https://www.shivambhosale.com/img/shivam2.jpeg'),
//               ),
//               Text(
//                 "Shivam Bhosale",
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 30,
//                     color: Color(0xFFFFFFFC)),
//               ),
//               SizedBox(
//                 height: 20.0,
//                 width: 150.0,
//                 child: Divider(
//                   color: Colors.white,
//                 ),
//               ),
//               Card(
//                 color: Colors.white,
//                 shadowColor: Colors.black,
//                 margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                 // padding: EdgeInsets.all(10.0), Unlike Containers Cards do not have padding property.
//                 // Instead of that we can use the padding class to encompass the row widget.
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ListTile(
//                     leading: Icon(
//                       Icons.monitor_heart,
//                       color: Colors.black,
//                       size: 30,
//                     ),
//                     title: Text("BPM: $",
//                         style: TextStyle(fontSize: 30, color: Colors.black)),
//                   ),
//                 ),
//               ),
//               Card(
//                 color: Colors.white,
//                 shadowColor: Colors.black,
//                 margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                 // padding: EdgeInsets.all(10.0), Unlike Containers Cards do not have padding property.
//                 // Instead of that we can use the padding class to encompass the row widget.
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ListTile(
//                     leading: Icon(
//                       Icons.bloodtype,
//                       color: Colors.black,
//                       size: 30,
//                     ),
//                     title: Text("SpO2: 98",
//                         style: TextStyle(fontSize: 30, color: Colors.black)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//
// Widget build(BuildContext context) {
//   return MaterialApp(
//     home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Health Example'),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.file_download),
//               onPressed: () {
//                 fetchData();
//               },
//             ),
//             IconButton(
//               onPressed: () {
//                 addData();
//               },
//               icon: Icon(Icons.add),
//             ),
//             IconButton(
//               onPressed: () {
//                 fetchBloodOxygenData();
//                 fetchHeartBeatData();
//                 // fetchStepData();
//               },
//               icon: Icon(Icons.nordic_walking),
//             )
//           ],
//         ),
//         body: Center(
//           child: _content(),
//         )),
//   );
// }
// }
