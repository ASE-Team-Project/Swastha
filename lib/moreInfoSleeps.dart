import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class MoreInfoSleeps extends StatefulWidget {
  const MoreInfoSleeps({Key? key}) : super(key: key);
  @override
  State<MoreInfoSleeps> createState() => _MoreInfoSleepsState();
}

class _MoreInfoSleepsState extends State<MoreInfoSleeps> {
  String timeStamp = "";
  String value = "";
  int count = 0;
  late ZoomPanBehavior _zoomPanBehavior;

  List<PastSpo2> sleep = [];
  //
  // List<PastSpo2> result = <PastSpo2>[]; //Hash Map for the Graph
  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
        zoomMode: ZoomMode.x,
        enablePanning: true,
        maximumZoomLevel: 0.5,
        // Enables pinch zooming
        enablePinching: true);
    // TODO: implement initState
    super.initState();
    readData();
  }

  void readData() async {
    print("readDate");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString("id")!;
    print("id " + id);

    var ref = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("SLEEP_IN_BED");
    List x = [];
    List y = [];
    for (var i = 0; i <= 7; i++) {
      DateTime stopday = new DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day - i,
      );
      DateTime startday = new DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day - i - 1,
      );
      String start = startday.millisecondsSinceEpoch.toString();
      String stop = stopday.millisecondsSinceEpoch.toString();
      final result = await ref
          .where("timestamp", isGreaterThanOrEqualTo: start)
          .where("timestamp", isLessThanOrEqualTo: stop)
          .get();
      double time = 0;
      result.docs.forEach((doc) {
        time += double.parse(doc["value"]);
      });
      x.add(startday);
      y.add(time / 60);
      print("Sleep x: " + x[0].toString());
      print("Sleep y: " + y[0].toString());
    }

    for (int i = 0; i < x.length; i++) {
      // result.add(PastSpo2(x[i].toString(), y[i]));
      sleep.add(PastSpo2(x[i], y[i]));
      print("x " + x[i].toString());
      print("y " + y[i].toString());
      print("result:" + sleep[i].toString());
      setState(() {});
    }
    // print("result:" + x.toString());
    // print("result:" + y.toString());
  }

  String formatter(String label) {
    return label.split(" ")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0D22), //const Color(0xff181C1F),
        title: const Text(
          "Swastha",
          style: TextStyle(
            fontFamily: "FredokaOne",
            color: Colors.blueAccent,
            fontSize: 23.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 30.0,
          ),
          RotatedBox(
            quarterTurns: 3,
            child: const CircleAvatar(
              radius: 45.0,
              backgroundColor: Color(0xFFCED3DC),
              child: FaIcon(
                FontAwesomeIcons.shoePrints,
                color: Colors.red,
                size: 45.0,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Center(
            child: Text(
              "Sleep Duration",
              style: TextStyle(
                fontFamily: "Lobster",
                fontSize: 40.0,
                color: Color(0xFFCED3DC),
              ),
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              height: 300.0,
              decoration: const BoxDecoration(
                color: Color(0xFF1B1F3B), //Color(0xFF0A1128),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    "Last Week Stats",
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),

                  //Chart Part
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: SfCartesianChart(
                      zoomPanBehavior: _zoomPanBehavior,
                      borderColor: Color(0xFFFAA916),
                      backgroundColor: Color(0xFF0A0D22), //Color(0xFFEFEFF0),
                      // zoomPanBehavior: ZoomPanBehavior(
                      //   enablePanning: true,
                      // ),
                      //borderWidth: 15,
                      // primaryXAxis: CategoryAxis(
                      //     autoScrollingMode: AutoScrollingMode.start,),
                      primaryXAxis: CategoryAxis(
                        // autoScrollingDelta: 10,
                        autoScrollingMode: AutoScrollingMode.start,
                      ),
                      title: ChartTitle(
                        text: "Chart",
                      ),
                      legend: Legend(
                        isVisible: true,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries>[
                        ScatterSeries<PastSpo2, DateTime>(
                          dataSource: sleep,
                          color: Color(0xFF96031A),
                          xValueMapper: (PastSpo2 Spo2, _) => Spo2.date,
                          yValueMapper: (PastSpo2 Spo2, _) => Spo2.value_daily,
                          name: 'Sleep',
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PastSpo2 {
  final DateTime date;
  final double value_daily;

  PastSpo2(this.date, this.value_daily);
}
