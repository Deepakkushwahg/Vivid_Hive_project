// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, prefer_const_constructors, avoid_print, prefer_typing_uninitialized_variables, no_logic_in_create_state
//@dart=2.9
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  var userInfo;
  final String chatRoomId;

  ChatScreen({Key key, this.chatRoomId, this.userInfo});

  @override
  State<ChatScreen> createState() => _ChatScreenState(chatRoomId, userInfo);
}

class _ChatScreenState extends State<ChatScreen> {
  var userInfo;
  String chatRoomId;
  _ChatScreenState(this.chatRoomId, this.userInfo);
  final TextEditingController _message = TextEditingController();
  final firebase = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  File imageFile;
  var moreItems = ["DeleteAll"];

  Future<void> getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future<void> uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await firebase
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": auth.currentUser.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile).catchError((error) async {
      await firebase
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await firebase
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": auth.currentUser.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await firebase
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (userInfo == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 52, 11, 0),
          title: ListTile(
            title: Text(
              userInfo['Name'],
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            subtitle: Text(
              userInfo['status'],
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          actions: [
            PopupMenuButton(
                icon: Icon(
                  Icons.more_vert_sharp,
                  color: Colors.white,
                ),
                onSelected: (value) {
                  setState(() {
                    if (value == "DeleteAll") {
                      deleteAllChats();
                    }
                  });
                },
                itemBuilder: (BuildContext context) {
                  return moreItems.map((String selecteditem) {
                    return PopupMenuItem(
                      value: selecteditem,
                      child: Text(selecteditem),
                    );
                  }).toList();
                }),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
                child: Image(
              image: AssetImage("lib/images/vivid_hive.jpeg"),
            )),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height / 1.25,
                        width: size.width,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: firebase
                              .collection('chatroom')
                              .doc(widget.chatRoomId)
                              .collection('chats')
                              .orderBy("time", descending: false)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.data != null) {
                              return ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> map =
                                      snapshot.data.docs[index].data()
                                          as Map<String, dynamic>;
                                  return messages(size, map, context);
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  getImage();
                                },
                                icon: Icon(Icons.photo)),
                            Container(
                              height: size.height / 17,
                              width: size.width / 1.5,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  border: Border.all(
                                      color: Color.fromARGB(255, 52, 11, 0),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: IntrinsicHeight(
                                  child: TextField(
                                    maxLines: 2,
                                    cursorColor: Color.fromARGB(255, 52, 11, 0),
                                    cursorHeight: 22,
                                    controller: _message,
                                    decoration: InputDecoration.collapsed(
                                        hintText: "Send Message",
                                        border: InputBorder.none),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.send),
                                onPressed: onSendMessage),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['sendby'] == auth.currentUser.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Text(
                map['message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sendby'] == auth.currentUser.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Image.network(
                        map['message'],
                        fit: BoxFit.cover,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }

  void deleteAllChats() async {
    final batch = firebase.batch();
    var _collection = firebase
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats');
    var snapshots = await _collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({this.imageUrl, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
