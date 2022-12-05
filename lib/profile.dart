import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Profile extends StatefulWidget {
  final String? currentUserId;

  Profile({super.key, this.currentUserId});

  @override
  State<Profile> createState() => _ProfileState();

  _ProfileState obj = _ProfileState();
}

class _ProfileState extends State<Profile> {
  late SharedPreferences preferences;
  String id = "";
  String username = "";
  String photoUrl = "";
  String email = "";

  TextEditingController? usernameTextEditingController;

  File? imageFileAvatar;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    username = preferences.getString("username")!;
    photoUrl = preferences.getString("photoUrl")!;
    email = preferences.getString("email")!;

    usernameTextEditingController = TextEditingController(text: username);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D22), //const Color(0xff181C1F),
        title: const Text(
          "Swastha",
          style: TextStyle(
            fontFamily: "FredokaOne",
            color: Colors.blueAccent,
            fontSize: 23.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 60.0,
              ),
              //Profile picture
              Container(
                child: Center(
                  child: Stack(
                    children: [
                      (photoUrl != '')
                          ? Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    // strokeWidth: 2.0,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.indigo),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(20.0),
                                ),
                                imageUrl: photoUrl,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125.0)),
                              clipBehavior: Clip.hardEdge,
                            )
                          :
                          //if user has no image in their Mail
                          Material(
                              child: Image.asset(
                                'images/avatar.png',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(125.0),
                              clipBehavior: Clip.hardEdge, //to make it circular
                            )
                    ],
                  ),
                ),
              ),
              // CircleAvatar(
              //   radius: 80.0,
              //   backgroundImage: NetworkImage(photoUrl),
              //   backgroundColor: Colors.transparent,
              // ),
              const SizedBox(
                height: 60.0,
              ),
              textCard(iconData: FontAwesomeIcons.user, text: username),
              textCard(iconData: FontAwesomeIcons.envelope, text: email),
              const SizedBox(
                height: 15.0,
              ),
              TextButton(
                onPressed: logoutUser,
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),

              // Stack(
              //   children: [
              //     (imageFileAvatar == null)?
              //
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MyApp()), (route) => false);
  }
}

class textCard extends StatelessWidget {
  final IconData iconData;
  final String text;

  const textCard({super.key, required this.iconData, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: const Color(0xFF1D1E33),
      ),
      child: ListTile(
        leading: FaIcon(
          iconData,
          size: 20.0,
        ),
        title: Text(
          text,
          style: const TextStyle(fontSize: 19.0),
        ),
      ),
    );
  }
}
