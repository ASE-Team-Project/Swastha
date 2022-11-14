import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'health.dart';

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HealthApp());
  //_HealthAppState obj = _HealthAppState();
  //DateTime previous = await fetchPreviousTime();
  DateTime previous = DateTime.now();
  // while(true){
  //   await fetchPreviousTime();
  //   const duration = Duration(seconds: 10);
  //   sleep(duration);
  // }
  while(true) {
    DateTime now = DateTime.now();
    List result = await HealthApp().obj.fetchDataEveryMinute(previous,now);
    previous = now;
    if(result.isNotEmpty){
      await insertData(result);
    }
    const duration = Duration(seconds: 10);
    sleep(duration);
  }
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: HomePage(),
      home: HealthApp(),
    );
  }
}