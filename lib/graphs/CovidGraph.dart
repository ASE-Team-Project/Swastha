//import 'dart:html';

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CovidGraph extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

enum AppState {
  DATA_NOT_FETCHED,
  NO_DATA,
  DATA_READY,
}

class _HomePage extends State<CovidGraph> {
  AppState _state = AppState.DATA_NOT_FETCHED;
  List<CovidCases> datatot = [];
  //bool redraw = false;
  getCovidData() async {
    var currentDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);
    // var afterDate = '2022-11-09';
    var formatter = new DateFormat('yyyy-MM-dd');
    String afterDate = formatter.format(currentDate);
    var response = await Dio().get(
        'https://api.opencovid.ca/timeseries?stat=cases&stat=string&geo=can&loc=string&after=${afterDate}&fill=false&version=true&pt_names=short&hr_names=hruid&legacy=false&fmt=json');
    Map obj = jsonDecode(response.toString());
    List<CovidCases> result = <CovidCases>[];
    obj["data"]["cases"].forEach((point) {
      Map cases = {};
      result.add(CovidCases(point["date"].toString(),
          double.parse(point["value_daily"].toString())));
    });

    return result;

    // list = rest.map<Cases>
  }

  Future covidcases() async {
    datatot = await getCovidData();
    setState(() {
      _state = datatot.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    });
    datatot.forEach((element) {
      print(element.date);
      print(element.value_daily);
    });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Scaffold(
        body: Center(
      child: LoadingAnimationWidget.twistingDots(
        leftDotColor: const Color(0xFF1A1A3F),
        rightDotColor: const Color(0xFFEA3799),
        size: 200,
      ),
    ));
  }

  Widget _contentDataReady() {
    return SfCartesianChart(
      borderColor: Color(0xFFFAA916),
      backgroundColor: Color(0xFFEFEFF0),
      borderWidth: 15,
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(
        text: "Covid Cases for Current Week (Canada)",
      ),
      legend: Legend(
        isVisible: true,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        LineSeries<CovidCases, String>(
          dataSource: datatot,
          color: Color(0xFF96031A),
          xValueMapper: (CovidCases cases, _) => cases.date,
          yValueMapper: (CovidCases cases, _) => cases.value_daily,
          name: 'Cases',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA) return _contentNoData();
    return _contentNotFetched();
  }

  @override
  Widget build(BuildContext context) {
    if (_state != AppState.DATA_READY) {
      covidcases();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Covid19",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF96031A),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        brightness: Brightness.dark,
      ),
      body: Container(
        child: _content(),
      ),
    );
  }
}

class CovidCases {
  final String date;
  final double value_daily;

  CovidCases(this.date, this.value_daily);
}
