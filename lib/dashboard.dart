import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swastha/profile.dart';
import 'constants.dart';
import 'health.dart';
import 'package:health/health.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    photoUrl = preferences.getString("photoUrl")!;

    setState(() {});
  }
  Future<void> _pullRefresh() async {
    HealthApp healthobj = new HealthApp();
    healthobj.obj.fetchPermissions();
    fetchHealth(healthobj);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D22), //Color(0xff181C1F),
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
                  //Weight Card
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    height: 250.0,
                    width: 160.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: const Color(
                          0xFF7A85F8), //Color(0xFF1D1E33), //0xFF0A0E21
                    ),
                    child: Column(
                      children: const [
                        SizedBox(
                          height: 20.0,
                        ),
                        CircleAvatar(
                          radius: 35.0,
                          backgroundColor: Color(0xFF292C31),
                          child: FaIcon(
                            FontAwesomeIcons.weightHanging,
                            size: 30.0,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "Weight",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Righteous',
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "70 KG",
                          style: TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Righteous',
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      // Steps Walked
                      HorizontalCard(
                        cardColor: const Color(0xFF6161FF),
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
                              children: const [
                                Text(
                                  "5,000",
                                  style: kHorizontalCardText,
                                ),
                                Text(
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
                        cardColor: const Color(0xFFBA7BF9),
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
                              children: const [
                                Text(
                                  "2,000",
                                  style: kHorizontalCardText,
                                ),
                                Text(
                                  "Kcal burnt",
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
              //Weekly Progress Card
              Container(
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
                              "Your Weekly Progress",
                              style: kHorizontalCardText,
                            ),
                            Text(
                              "Your Weekly Reports",
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
                            backgroundColor: Color(0xFF78ADFD),
                            radius: 35.0,
                            child: Text(
                              "80%",
                              style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),);
  }
}

class HorizontalCard extends StatelessWidget {
  final Color cardColor;
  final Widget? child;

  HorizontalCard({required this.cardColor, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.0,
      width: 190.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: cardColor, //Color(0xFF1D1E33),
      ),
      child: child,
    );
  }
}
