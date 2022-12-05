import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class MoreInfoHeart extends StatefulWidget {
  const MoreInfoHeart({Key? key}) : super(key: key);

  @override
  State<MoreInfoHeart> createState() => _MoreInfoHeartState();
}

class _MoreInfoHeartState extends State<MoreInfoHeart> {
  String timeStamp = "";
  String value = "";
  int count = 0;
  late ZoomPanBehavior _zoomPanBehavior;

  List<PastSpo2> heart = [];
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
        .collection("BLOOD_OXYGEN");

    DateTime past7days = new DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 7,
    );
    String past = past7days.millisecondsSinceEpoch.toString();
    final last7day = await ref.where("timestamp", isGreaterThan: past).get();
    List x = [];
    List y = [];
    DateTime plottime;

    last7day.docs.forEach((doc) {
      String date_from = doc["date_from"];
      String time = date_from.split("T")[1];
      date_from = date_from.split("T")[0];
      plottime = DateTime(
        int.parse(date_from.split("-")[0]),
        int.parse(date_from.split("-")[1]),
        int.parse(date_from.split("-")[2]),
        int.parse(time.split(":")[0]),
        int.parse(time.split(":")[1]),
        int.parse(time.split(":")[2].split("})")[0].split(".")[0]),
        int.parse(time.split(":")[2].split("})")[0].split(".")[0]),
      );
      // var formatter =  new pl;
      print("Plot time " + plottime.toString());
      x.add(plottime);
      y.add(double.parse(doc["value"]));

      // setState(() {
      //   value = double.parse(doc['value']).toString();
      //   timeStamp = double.parse(doc['date_to']).toString();
      //   count++;
      // });
    });

    for (int i = 0; i < x.length; i++) {
      // result.add(PastSpo2(x[i].toString(), y[i]));
      heart.add(PastSpo2(x[i], y[i]));
      print("x " + x[i].toString());
      print("y " + y[i].toString());
      print("result:" + heart[i].toString());
      setState(() {});
    }
    print("result:" + heart[0].toString());
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
          const CircleAvatar(
            radius: 45.0,
            backgroundColor: Color(0xFFCED3DC),
            child: FaIcon(
              FontAwesomeIcons.heartPulse,
              color: Colors.redAccent,
              size: 45.0,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Center(
            child: Text(
              "Heart Rate",
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
                          dataSource: heart,
                          color: Color(0xFF96031A),
                          xValueMapper: (PastSpo2 Spo2, _) => Spo2.date,
                          yValueMapper: (PastSpo2 Spo2, _) => Spo2.value_daily,
                          name: 'Heart',
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
