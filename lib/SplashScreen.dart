import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swastha/dashboard.dart';
import 'Widgets/ProgressWidget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'health.dart';
import 'dart:io';
import "package:compute/compute.dart";
import 'package:flutter_isolate/flutter_isolate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late SharedPreferences preferences;
  bool isLoggedIn = false;
  bool isLoading = false;
  late User currentUser;
  String uuid = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //isSignedIn();
  }


  Future isSignedIn() async {
    setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      uuid = preferences.getString("id")!;
      HealthApp healthapp = new HealthApp();
      await healthapp.obj.fetchPermissions();
      //flutterCompute(fetchHealth, healthapp);
      fetchHealth(healthapp);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    }
    else{
      controlSignIn();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D22),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const Text(
            //   "Swastha",
            //   style: TextStyle(
            //     fontSize: 60.0,
            //     fontFamily: 'FredokaOne',
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blueAccent,
            //   ),
            // ),

            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 62.0,
                fontFamily: 'FredokaOne',
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              child: AnimatedTextKit(
                totalRepeatCount: 1,
                // isRepeatingAnimation: true,
                animatedTexts: [
                  WavyAnimatedText('Swastha'),
                ],
              ),
            ),

            const SizedBox(
              height: 30.0,
            ),
            GestureDetector(
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 45.0),
                color: Colors.indigo,
                child: ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.orange,
                    size: 30.0,
                  ),
                  title: Text(
                    "Google Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SourceSansPro',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              onTap: isSignedIn,
            ),
            //Circular Progressbar
            Padding(
              padding: EdgeInsets.all(2.0),
              child: isLoading ? circularProgress() : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Future controlSignIn() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    User? firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    //SignIn Successful
    if (firebaseUser != null) {
      //Check if the user is already signed up
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      //checking whether user info exists or not
      if (documentSnapshots.isEmpty) {
        //Save data of the new users to fireStore
        FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .set({
          "id": firebaseUser.uid,
          "email": firebaseUser.email,
          "username": firebaseUser.displayName,
          "photoUrl": firebaseUser.photoURL,
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
        });
        //write Data to local
        currentUser = firebaseUser;
        await preferences.setString("id", currentUser.uid);
        await preferences.setString("username", currentUser.displayName!);
        await preferences.setString("email", currentUser.email!);
        await preferences.setString("photoUrl", currentUser.photoURL!);
      }
      //Save data locally
      else {
        //write Data to local
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString(
            "username", documentSnapshots[0]["username"]);
        await preferences.setString("email", documentSnapshots[0]["email"]);
        await preferences.setString(
            "photoUrl", documentSnapshots[0]["photoUrl"]);
      }
      setState(() {
        uuid = currentUser.uid;
      });
      HealthApp healthapp = new HealthApp();
      await healthapp.obj.fetchPermissions();
      //flutterCompute(fetchHealth, healthapp);
      fetchHealth(healthapp);

      Fluttertoast.showToast(msg: "SignIn Successful");
      setState(() {
        isLoading = false;
      });
      //Redirecting to a new page
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    }
    //SignIn failed
    else {
      Fluttertoast.showToast(msg: "SignIn Failed!! Try Again.");
      setState(() {
        isLoading = false;
      });
    }
  }
}
