import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'constants.dart';
import 'health.dart';
import 'package:health/health.dart';
import 'graphs/CovidGraph.dart';
import "package:async_task/async_task.dart";

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
  final HealthApp healthobj = new HealthApp();
  late SharedPreferences preferences;
  String photoUrl = "";
  String id = "";
  String calorie = "";
  String steps = "";
  String heartRate = "";
  String sleepDuration = "";
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

    setState(() {});

    //fetching data for calorie burnt
    FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("ACTIVE_ENERGY_BURNED")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double value = double.parse(doc["value"]);
        //double val = value * 1000;
        setState(() {
          calorie = value.toStringAsFixed(1);
        });
        print("From Dashboard:" + calorie);
      });
    });

    //fetching data for Steps Walked
    FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("STEPS")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // int value = int.parse(doc["value"]);
        //double val = value * 1000;
        setState(() {
          steps = doc["value"];
        });
        print("From Dashboard:" + calorie);
      });
    });

    //fetching data for Heart Rate
    FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("HEART_RATE")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double value = double.parse(doc["value"]);
        //double val = value * 1000;
        setState(() {
          heartRate = value.toStringAsFixed(0);
        });
        print("From Dashboard:" + calorie);
      });
    });

    //fetching data for Sleep Duration
    FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .collection("SLEEP_IN_BED")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
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
  Future<void> _pullRefresh() async {
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
      body:RefreshIndicator(
    onRefresh: _pullRefresh,
    child:  ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 30.0,
              ),
              const Center(
                child: Text(
                  "Hi! Khondoker Aminuzzaman",
                  style: TextStyle(
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
                  Container(
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
                        Text(
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

                  Column(
                    children: [
                      // Steps Walked
                      HorizontalCard(
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
                                Text(
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
                                Text(
                                  calorie,
                                  style: kHorizontalCardText,
                                ),
                                Text(
                                  "cal burnt",
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
              //Row of Sleep and BMI Card
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     //BMI Card
              //     HorizontalCard(
              //       cardColor: kCalorieBurntCardColor,
              //       width: kBMICardWidth,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //           const CircleAvatar(
              //             radius: 30.0,
              //             backgroundColor: Colors.purple,
              //             child: FaIcon(
              //               FontAwesomeIcons.fire,
              //               color: Colors.orange,
              //               size: 30.0,
              //             ),
              //           ),
              //           Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Text(
              //                 calorie,
              //                 style: kHorizontalCardText,
              //               ),
              //               const Text(
              //                 "cal burnt",
              //                 style: TextStyle(
              //                     fontSize: 18.0, fontWeight: FontWeight.bold),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //
              //     //Sleep Card
              //     HorizontalCard(
              //       cardColor: kCalorieBurntCardColor,
              //       width: kSleepCardWidth,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //           const CircleAvatar(
              //             radius: 30.0,
              //             backgroundColor: Colors.purple,
              //             child: FaIcon(
              //               FontAwesomeIcons.bed,
              //               color: Colors.orange,
              //               size: 30.0,
              //             ),
              //           ),
              //           Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Text(
              //                 calorie,
              //                 style: kHorizontalCardText,
              //               ),
              //               const Text(
              //                 "cal burnt",
              //                 style: TextStyle(
              //                     fontSize: 18.0, fontWeight: FontWeight.bold),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              //Sleeping Card
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
                  height: 150.0,
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
                              Text(
                                "" + sleepDuration,
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
              //Weekly Progress Card
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
    ));
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
