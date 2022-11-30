import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swastha/moreInfo.dart';
import 'package:swastha/moreInfoHeart.dart';
import 'package:swastha/moreInfoSleeps.dart';
import 'package:swastha/moreInfoSpo2.dart';
import 'package:swastha/moreInfoSteps.dart';
import 'profile.dart';
import 'constants.dart';
import 'health.dart';
import 'package:health/health.dart';
import 'graphs/CovidGraph.dart';
import 'Widgets/ProgressWidget.dart';

// void main() {
//   runApp(const Dash());
// }

// class Dash extends StatelessWidget {
//   const Dash({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0D22), //Color(0xff181C1F),
//       appBar: AppBar(
//         backgroundColor: Color(0xFF0A0D22), //const Color(0xff181C1F),
//         title: const Text(
//           "Swastha",
//           style: TextStyle(
//             fontFamily: "FredokaOne",
//             color: Colors.blueAccent,
//             fontSize: 23.0,
//           ),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
//             child: CircleAvatar(
//               radius: 25.0,
//             ),
//           )
//         ],
//       ),
//       body: Dashboard(),
//     );
//   }
// }

class Dashboard extends StatefulWidget {
  // const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late SharedPreferences preferences;
  String photoUrl = "";
  String id = "";
  String calorie = "";
  String steps = "";
  String heartRate = "";
  String sleepDuration = "";
  double weight = 0.0;
  String bmi = "";
  String sp02 = "";
  String userName = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
    // getCalorie();
    // fetchCalorie();
    // getMyFknCalorie();
  }

  // getMyFknCalorie() {
  //   FirebaseFirestore.instance.collection('data').doc('id')
  // }

  readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    photoUrl = preferences.getString("photoUrl")!;
    id = preferences.getString("id")!;
    userName = preferences.getString("username")!;

    setState(() {});

    //fetching data for calorie burnt
    var calorieRef = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("ACTIVE_ENERGY_BURNED");
    final calorieData =
        await calorieRef.orderBy('date_from', descending: true).limit(1).get();
    calorieData.docs.forEach((doc) {
      double value = double.parse(doc["value"]);
      value = value / 1000;
      //double val = value * 1000;
      setState(() {
        calorie = value.toStringAsFixed(1);
      });
      print("From Dashboard:" + calorie);
    });

    //fetching data for Steps Walked
    var stepsRef = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("STEPS");
    final stepData =
        await stepsRef.orderBy('date_from', descending: true).limit(1).get();
    stepData.docs.forEach((doc) {
      // int value = int.parse(doc["value"]);
      //double val = value * 1000;
      setState(() {
        steps = doc["value"];
      });
      print("From Dashboard:" + calorie);
    });

    //fetching data for Heart Rate
    var ref = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("HEART_RATE");
    final heartdata =
        await ref.orderBy('date_from', descending: true).limit(1).get();

    heartdata.docs.forEach((doc) {
      double value = double.parse(doc["value"]);
      //double val = value * 1000;
      setState(() {
        heartRate = value.toStringAsFixed(0);
      });
      print("Heart Beat:" + heartRate);
    });

    //fetching data for Sleep Duration
    var sleepRef = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("SLEEP_IN_BED");
    final sleepData =
        await sleepRef.orderBy('date_from', descending: true).limit(1).get();
    sleepData.docs.forEach((doc) {
      double value = double.parse(doc["value"]);
      print("sleepValue " + value.toString());
      //double val = value * 1000;
      double sleepInHours = value / 60.0;
      double sleepInMinutes = value % 60;
      print("Hours $sleepInHours");
      print("Minutes $sleepInMinutes");
      setState(() {
        sleepDuration = sleepInHours.toStringAsFixed(0) +
            " hrs " +
            (sleepInMinutes != 0
                ? sleepInMinutes.toStringAsFixed(0) + " min"
                : "");
      });
    });

    //fetching data for Weight Duration
    var weightRef = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("WEIGHT");
    final weightData =
        await weightRef.orderBy('date_from', descending: true).limit(1).get();
    weightData.docs.forEach((doc) {
      double value = double.parse(doc["value"]);
      print("weightValue " + value.toString());
      //double val = value * 1000;

      setState(() {
        weight = value;
      });
    });

    //fetching data for Height
    var heightRef = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("HEIGHT");
    final heightData =
        await heightRef.orderBy('date_from', descending: true).limit(1).get();
    heightData.docs.forEach((doc) {
      double height = double.parse(doc["value"]);
      print("heightValue " + height.toString());
      double val = weight / (height * height);
      setState(() {
        bmi = val.toStringAsFixed(1);
      });
      print("BMI Value1:" + val.toString());
      print("BMI Value2:" + bmi);
    });

    //fetching data for Spo2
    var spo2Ref = FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("BLOOD_OXYGEN");
    final spo2Data =
        await spo2Ref.orderBy('date_from', descending: true).limit(1).get();
    spo2Data.docs.forEach((doc) {
      double value = double.parse(doc["value"]);
      print("Spo2Value " + value.toString());

      setState(() {
        sp02 = value.toStringAsFixed(1);
      });
      // print("BMI Value1:" + val.toString());
      // print("BMI Value2:" + bmi);
    });
  }

  // fetchCalorie() {
  //   StreamBuilder<QuerySnapshot>(
  //       stream: FirebaseFirestore.instance
  //           .collection("data")
  //           .doc(id)
  //           .collection(id)
  //           // .orderBy("timestamp", descending: true)
  //           // .limit(10)
  //           .snapshots(),
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           print("Snapshot is empty");
  //         } else {
  //           calorie = snapshot.data!.docs[2]["value"];
  //           // final values = snapshot.data!.docs.reversed;
  //           //
  //           // for (var value in values) {
  //           //   final message = value.data();
  //           //   print("from dashboard:" + message.toString());
  //           // }
  //
  //           return Text("");
  //         }
  //
  //         setState(() {
  //           calorie = snapshot.data!.docs[0]["value"];
  //         });
  //         return Text("");
  //       });
  // }

  // Future<dynamic> getCalorie() async {
  //   dynamic val = "";
  //   final CollectionReference ref =
  //       FirebaseFirestore.instance.collection("data").doc(id).collection(id);
  //   // QuerySnapshot snapshot =
  //   //     await ref.orderBy("timestamp", descending: true).limit(1).get();
  //   await ref
  //       .orderBy('timestamp', descending: true)
  //       .limit(1)
  //       .get()
  //       .then((value) async {
  //     val = value;
  //   });
  //
  //   setState(() {
  //     calorie = val["value"].toString();
  //   });
  //   print("From Dashboard:" + calorie);
  // }
  //Pull to Refresh
  Future<void> _pullRefresh() async {
    HealthApp healthobj = new HealthApp();
    healthobj.obj.fetchPermissions();
    await fetchHealth(healthobj);
    readDataFromLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          kBackgroundColor, //const Color(0xFF0A0D22), //Color(0xff181C1F),
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
        actions: [
          GestureDetector(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              child: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(photoUrl),
                backgroundColor: Colors.transparent,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: Text(
                    "Hi! $userName",
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontFamily: 'FredokaOne',
                      color: Color(0xFFC3CEDA), //Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Center(
                  child: Text(
                    "Summary Report",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontFamily: 'FredokaOne',
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15.0,
                ),

                // Features Card
                Row(
                  children: [
                    //Heart Rate Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MoreInfoHeart()));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 250.0,
                        width: 160.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.0),
                          color: kWeightCardColor,
                          //const Color(0xFF7A85F8), //Color(0xFF1D1E33), //0xFF0A0E21
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            const CircleAvatar(
                              radius: 35.0,
                              backgroundColor: Color(0xFF292C31),
                              child: FaIcon(
                                FontAwesomeIcons.heartPulse,
                                size: 30.0,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            // const Text(
                            //   "Heart Rate",
                            //   style: TextStyle(
                            //     fontSize: 22.0,
                            //     fontWeight: FontWeight.w900,
                            //     fontFamily: 'Righteous',
                            //   ),
                            // ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            heartRate == ""
                                ? circularProgressWhite()
                                : Text(
                                    heartRate,
                                    style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Righteous',
                                    ),
                                  ),
                            const Text(
                              "bpm",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        // Steps Walked
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MoreInfoSteps()));
                          },
                          child: HorizontalCard(
                            cardColor: kStepWalkedCardColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const RotatedBox(
                                  quarterTurns: 3,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Colors.indigo, //Color(0xFF2E8BC0),
                                    radius: 30.0,
                                    child: FaIcon(
                                      FontAwesomeIcons.shoePrints,
                                      color: Colors.red,
                                      size: 30.0,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    steps == ""
                                        ? circularProgressWhite()
                                        : Text(
                                            steps,
                                            style: kHorizontalCardText,
                                          ),
                                    const Text(
                                      "Steps Walked",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),

                        //Calorie Burnt
                        HorizontalCard(
                          cardColor: kCalorieBurntCardColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.purple,
                                child: FaIcon(
                                  FontAwesomeIcons.fire,
                                  color: Colors.orange,
                                  size: 30.0,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  calorie == ""
                                      ? circularProgressWhite()
                                      : Text(
                                          calorie,
                                          style: kHorizontalCardText,
                                        ),
                                  Text(
                                    "kcal burnt",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                //Blood Oxygen Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MoreInfoSpo2()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 120.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFFF78764),
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
                                  "Spo2 Level",
                                  style: kHorizontalCardText,
                                ),
                                sp02 == ""
                                    ? circularProgressWhite()
                                    : Text(
                                        sp02,
                                        style: const TextStyle(
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30.0,
                              child: FaIcon(
                                FontAwesomeIcons.droplet,
                                color: Colors.redAccent,
                                size: 50.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                //BMI Card
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => CovidGraph()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 120.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFF4F518C),
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
                                  "Body Mass Index",
                                  style: kHorizontalCardText,
                                ),
                                bmi == ""
                                    ? circularProgressWhite()
                                    : Text(
                                        bmi,
                                        style: const TextStyle(
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30.0,
                              child: FaIcon(
                                FontAwesomeIcons.person,
                                size: 50.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),

                //Sleeping Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MoreInfoSleeps()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 120.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFFDC965A),
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
                                  "Sleep Duration",
                                  style: kHorizontalCardText,
                                ),
                                sleepDuration == ""
                                    ? circularProgressWhite()
                                    : Text(
                                        sleepDuration,
                                        style: const TextStyle(
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 50.0,
                              child: FaIcon(
                                FontAwesomeIcons.bed,
                                size: 45.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                //Weekly covid Progress Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CovidGraph()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    height: 150.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xFF78ADFD),
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
                              children: const [
                                Text(
                                  "Weekly Covid Reports",
                                  style: kHorizontalCardText,
                                ),
                                Text(
                                  "Click to see the graph",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 50.0,
                              child: CircleAvatar(
                                backgroundColor:
                                    Colors.white, //Color(0xFF78ADFD),
                                radius: 35.0,
                                child: FaIcon(
                                  FontAwesomeIcons.virusCovid,
                                  size: 45.0,
                                ),
                                // Text(
                                //   "80%",
                                //   style: TextStyle(
                                //       fontSize: 25.0,
                                //       fontWeight: FontWeight.bold,
                                //       color: Colors.white),
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HorizontalCard extends StatelessWidget {
  final Color cardColor;
  final Widget? child;
  final double? height;
  final double? width;

  HorizontalCard(
      {required this.cardColor, this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 110.0,
      width: width ?? 190.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: cardColor, //Color(0xFF1D1E33),
      ),
      child: child,
    );
  }
}
