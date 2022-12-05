import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'constants.dart';

class MoreInfo extends StatefulWidget {
  const MoreInfo({Key? key}) : super(key: key);

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  String timeStamp = "";
  String value = "";
  int count = 0;
  @override
  void initState() {
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
      print("x " + x[i].toString());
      print("y " + y[i].toString());
    }
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
              FontAwesomeIcons.droplet,
              color: Colors.redAccent,
              size: 45.0,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Center(
            child: Text(
              "Blood Oxygen Level",
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

                  //Data Cards
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 60.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFF8367C7),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Spo2",
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "27-11-22",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCED3DC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF38AECC),
                              radius: 28.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 22.0,
                                child: Center(
                                    child: Text(
                                  "98",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Data Cards
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 60.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFF8367C7),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Spo2",
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "27-11-22",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCED3DC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF38AECC),
                              radius: 28.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 22.0,
                                child: Center(
                                    child: Text(
                                  "98",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Data Cards
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 60.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFF8367C7),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Spo2",
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "27-11-22",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCED3DC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF38AECC),
                              radius: 28.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 22.0,
                                child: Center(
                                    child: Text(
                                  "98",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
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
