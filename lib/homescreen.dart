// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, prefer_const_constructors, avoid_print, prefer_typing_uninitialized_variables, no_logic_in_create_state, sized_box_for_whitespace, unnecessary_new, non_constant_identifier_names, use_build_context_synchronously
//@dart=2.9
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_application/chatting_page.dart';
import 'package:chat_application/search_users.dart';
import 'package:chat_application/signup_page.dart';
import 'package:chat_application/view_photo.dart';
import 'login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = new FlutterSecureStorage();
  final firebase = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  Map<String, dynamic> userInfo;
  String roomId;
  List usersList = [];
  final ImagePicker picker = ImagePicker();
  var imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    getUserData();
    getUsersData();
    setStatus("Online");
    super.initState();
  }

  void getUserData() async {
    await firebase
        .collection("users")
        .doc(auth.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        userInfo = value.data();
        imageUrl = userInfo['imageFile'];
        isLoading = false;
      });
    });
  }

  Future<void> getProfileImage(ImageSource source) async {
    setState(() {
      isLoading = true;
    });
    await picker.pickImage(source: source).then((xFile) {
      if (xFile != null) {
        final imageFile = File(xFile.path);
        uploadProfileImage(imageFile);
      } else {
        showSnackBar(context, "image not picked");
      }
    });
  }

  Future<void> uploadProfileImage(File imageFile) async {
    String fileName = auth.currentUser.uid.toString();
    int status = 1;

    var ref = FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile).catchError((error) async {
      status = 0;
      showSnackBar(context, "Retry");
    });

    if (status == 1) {
      String url = await uploadTask.ref.getDownloadURL();
      await firebase
          .collection('users')
          .doc(auth.currentUser.uid)
          .update({"imageFile": url});

      print(url);
      getUserData();
    }
  }

  void bottomsheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 120,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(
                    "Choose Profile photo",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            getProfileImage(ImageSource.camera);
                          },
                          icon: Icon(Icons.camera_alt),
                          label: Text("Camera")),
                      TextButton.icon(
                          onPressed: () {
                            getProfileImage(ImageSource.gallery);
                          },
                          icon: Icon(Icons.photo),
                          label: Text("Gallery")),
                      TextButton.icon(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await firebase
                                .collection("users")
                                .doc(auth.currentUser.uid)
                                .update({"imageFile": " "});
                            getUserData();
                            await FirebaseStorage.instance
                                .ref()
                                .child('profileImages')
                                .child("${auth.currentUser.uid.toString()}.jpg")
                                .delete();
                          },
                          icon: Icon(Icons.person_sharp),
                          label: Text("Default image"))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1-$user2";
    } else {
      return "$user2-$user1";
    }
  }

  Future<void> setStatus(String status) async {
    await firebase.collection('users').doc(auth.currentUser.uid).update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null || auth.currentUser.uid == null) {
      return WillPopScope(
        onWillPop: () async {
          print("change status and close app");
          await setStatus(" ");
          exit(0);
        },
        child: Scaffold(
            body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        )),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        print("change status and close app");
        await setStatus(" ");
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
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchUsers(
                                usersList: usersList, roomId: roomId)));
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ))
            ],
          ),
          drawer: Drawer(
              child: Stack(
            children: [
              ListView(
                children: [
                  Container(
                    color: Color.fromARGB(255, 52, 11, 0),
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    margin: EdgeInsets.all(10),
                    // ignore: prefer_const_literals_to_create_immutables
                    child: Column(children: [
                      Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPhoto(
                                            img: userInfo['img'],
                                            imageUrl: userInfo['imageFile'],
                                          )));
                            },
                            child: CircleAvatar(
                              backgroundImage: (imageUrl == " ")
                                  ? AssetImage(userInfo['img'])
                                  : NetworkImage(imageUrl),
                              radius: 80.0,
                            ),
                          ),
                          Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.add_a_photo_sharp,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  bottomsheet(context);
                                },
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        userInfo['Name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(userInfo['Phone'],
                          style: TextStyle(color: Colors.white)),
                      Text(userInfo['Email'],
                          style: TextStyle(color: Colors.white))
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
              Positioned(
                  child: (isLoading)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Center())
            ],
          )),
          body: (usersList != null)
              ? ListView.builder(
                  itemCount: usersList.length,
                  // ignore: missing_return
                  itemBuilder: (context, i) {
                    return Column(
                      children: [
                        Divider(
                          height: 8.0,
                        ),
                        ListTile(
                          leading: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPhoto(
                                            img: usersList[i]['img'],
                                            imageUrl: usersList[i]['imageFile'],
                                          )));
                            },
                            child: CircleAvatar(
                              radius: 28,
                              // ignore: sort_child_properties_last
                              backgroundImage:
                                  (usersList[i]['imageFile'] == " ")
                                      ? AssetImage(usersList[i]['img'])
                                      : NetworkImage(usersList[i]['imageFile']),
                            ),
                          ),
                          title: Text(
                            usersList[i]['Name'],
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            setState(() {
                              roomId = chatRoomId(
                                  userInfo['uid'], usersList[i]['uid']);
                            });
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatScreen(
                                chatRoomId: roomId,
                                userInfo: usersList[i],
                              );
                            }));
                          },
                        )
                      ],
                    );
                  })
              : Center(child: CircularProgressIndicator())),
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
      getUsersData();
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

  Future<void> getUsersData() async {
    try {
      final CollectionReference profileList = firebase.collection("users");
      await profileList.get().then((snapshots) {
        for (var element in snapshots.docs) {
          usersList.add(element.data());
        }
      });
      for (var i = 0; i < usersList.length; i++) {
        if (usersList[i]['uid'] == auth.currentUser.uid) {
          usersList.removeAt(i);
          break;
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
