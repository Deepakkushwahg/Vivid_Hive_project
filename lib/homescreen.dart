// ignore_for_file: prefer_const_constructors, duplicate_ignore, implementation_imports, avoid_print, prefer_typing_uninitialized_variables, no_logic_in_create_state, prefer_const_constructors_in_immutables, use_build_context_synchronously, unnecessary_new, non_constant_identifier_names, override_on_non_overriding_member, must_be_immutable, import_of_legacy_library_into_null_safe
//@dart=2.9
import 'dart:io';

import 'package:chat_application/chatting_page.dart';
import 'package:chat_application/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_page.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  final storage = new FlutterSecureStorage();
  Map<String, dynamic> userInfo;
  String roomId;

  @override
  void initState() {
    getUserData();
    setStatus("Online");
    super.initState();
  }

  @override
  void getUserData() async {
    await firebase
        .collection("users")
        .doc(auth.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        userInfo = value.data();
      });
    });
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void setStatus(String status) async {
    await firebase.collection('users').doc(auth.currentUser.uid).update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null || auth.currentUser.uid == null) {
      return Scaffold(
          body: Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ));
    }
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Vivid Hive",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)),
          ),
          backgroundColor: Color.fromARGB(255, 52, 11, 0),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              Container(
                color: Color.fromARGB(255, 52, 11, 0),
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                margin: EdgeInsets.all(10),
                // ignore: prefer_const_literals_to_create_immutables
                child: Column(children: [
                  Text(
                    userInfo['Name'],
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(userInfo['Phone'],
                      style: TextStyle(color: Colors.white)),
                  Text(userInfo['Email'], style: TextStyle(color: Colors.white))
                ]),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text("Log out"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  try {
                    setStatus(" ");
                    await auth.signOut();
                    await storage.delete(key: "uid");
                    showSnackBar(context, "Logout successfully");
                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (route) => false);
                  } catch (e) {
                    print("singout failed due to ${e.toString()}");
                    showSnackBar(
                        context, "singout failed due to ${e.toString()}");
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialogScreen(context);
                },
              ),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firebase.collection("users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  // ignore: missing_return
                  itemBuilder: (context, i) {
                    QueryDocumentSnapshot x = snapshot.data.docs[i];

                    return ListTile(
                      leading: CircleAvatar(
                        // ignore: sort_child_properties_last
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromARGB(255, 52, 11, 0),
                      ),
                      title: Text(
                        x['Name'],
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        setState(() {
                          roomId = chatRoomId(userInfo['uid'], x['uid']);
                        });
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChatScreen(
                            chatRoomId: roomId,
                            userInfo: x,
                          );
                        }));
                      },
                    );
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  final deleteAccountController = TextEditingController();
  void showDialogScreen(BuildContext context) async {
    AlertDialog alertDialog = AlertDialog(
      content: Text(
          "Are you sure, you want to delete your account permanently, if yes then plese type 'delete'"),
      actions: [
        SizedBox(
          width: 120,
          height: 48,
          child: Center(
            child: TextField(
              controller: deleteAccountController,
              decoration: InputDecoration(
                  hintText: "delete",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ),
        TextButton(
            onPressed: () {
              if (deleteAccountController.text == 'delete') {
                deleteAccount();
              } else {
                showSnackBar(context, "Please type delete");
              }
            },
            child: Text(
              "Delete Permanent",
              style: TextStyle(color: Colors.red),
            ))
      ],
    );

    showDialog(context: context, builder: (context) => alertDialog);
  }

  void deleteAccount() async {
    try {
      await firebase.collection("chatroom").doc(roomId).delete();
      await firebase.collection("users").doc(userInfo['uid']).delete();
      storage.delete(key: "uid");
      auth.currentUser.delete();
      await auth.signOut();
      showSnackBar(context, "Account deleted");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } catch (e) {
      print(e.toString());
    }
  }
}
