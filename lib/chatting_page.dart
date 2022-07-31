// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, prefer_const_constructors, avoid_print, prefer_typing_uninitialized_variables, no_logic_in_create_state, sized_box_for_whitespace, unnecessary_new, non_constant_identifier_names
//@dart=2.9
import 'dart:io';

import 'package:chat_application/view_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final storage = new FlutterSecureStorage();
  final firebase = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  File imageFile;
  var moreItems = ["DeleteAll Chats"];
  String isMe;
  ScrollController scrollController = ScrollController();

  @override
  void reassemble() {
    auth.currentUser.reload();
    super.reassemble();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isMe = auth.currentUser.uid.toString();
    });
  }

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
      "sendby": isMe,
      "message": "",
      "type": "img",
      "docId": fileName,
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
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    String docId = Uuid().v1();
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": isMe,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
        "docId": docId
      };

      _message.clear();
      await firebase
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(docId)
          .set(messages);
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
    // ignore: missing_return
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 52, 11, 0),
          titleSpacing: 0.0,
          title: ListTile(
            leading: CircleAvatar(
              // ignore: sort_child_properties_last
              backgroundImage: (userInfo['imageFile'] == " ")
                  ? AssetImage(userInfo['img'])
                  : NetworkImage(userInfo['imageFile']),
            ),
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
                    if (value == "DeleteAll Chats") {
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
              child: Column(
                children: [
                  Expanded(
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
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length + 1,
                            itemBuilder: (context, index) {
                              if (index == snapshot.data.docs.length) {
                                return Container(
                                  height: 60,
                                );
                              }
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
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              getImage();
                            },
                            icon: Icon(Icons.photo)),
                        Flexible(
                          child: TextFormField(
                            controller: _message,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 52, 11, 0),
                                    width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              hintText: 'Type a message',
                            ),
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.send,
                              size: 32,
                            ),
                            onPressed: onSendMessage),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? ((map['time'] as Timestamp) != null)
            ? Container(
                width: size.width,
                alignment: map['sendby'] == isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: InkWell(
                  onLongPress: () {
                    showDeleteDialog(context, map);
                  },
                  child: Padding(
                    padding: (map['sendby'] == isMe)
                        ? const EdgeInsets.only(left: 50)
                        : EdgeInsets.only(right: 50),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            map['message'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 6,
                            height: 3,
                          ),
                          Text(
                            "${(map['time'] as Timestamp).toDate().hour}:${(map['time'] as Timestamp).toDate().minute},  ${(map['time'] as Timestamp).toDate().day}-${(map['time'] as Timestamp).toDate().month}-${(map['time'] as Timestamp).toDate().year}",
                            style: TextStyle(fontSize: 7),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              )
        : ((map['time'] as Timestamp) != null)
            ? Container(
                height: size.height / 2.5,
                width: size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                alignment: map['sendby'] == isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: InkWell(
                    onLongPress: () {
                      showDeleteDialog(context, map);
                    },
                    onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ViewPhoto(
                              imageUrl: map['message'],
                            ),
                          ),
                        ),
                    child: Container(
                      height: size.height / 2.5,
                      width: size.width / 2,
                      color: Colors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: size.height / 2.7,
                            width: size.width / 2.1,
                            decoration: BoxDecoration(border: Border.all()),
                            alignment:
                                map['message'] != "" ? null : Alignment.center,
                            child: map['message'] != ""
                                ? Image.network(
                                    map['message'],
                                    fit: BoxFit.fill,
                                  )
                                : CircularProgressIndicator(),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "${(map['time'] as Timestamp).toDate().hour}:${(map['time'] as Timestamp).toDate().minute},  ${(map['time'] as Timestamp).toDate().day}-${(map['time'] as Timestamp).toDate().month}-${(map['time'] as Timestamp).toDate().year}",
                            style: TextStyle(fontSize: 7),
                          )
                        ],
                      ),
                    )),
              )
            : Center(
                child: CircularProgressIndicator(),
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
      if (doc['type'] == "img") {
        FirebaseStorage.instance
            .ref()
            .child('images')
            .child("${doc['docId']}.jpg")
            .delete();
      }
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void showDeleteDialog(BuildContext context, Map<String, dynamic> map) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Delete Message?",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 52, 11, 0),
            content: Text(
              "Are you sure? you want to delete this message",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (map['type'] == "img") {
                      FirebaseStorage.instance
                          .ref()
                          .child('images')
                          .child("${map['docId']}.jpg")
                          .delete();
                    }
                    firebase
                        .collection('chatroom')
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .doc(map['docId'])
                        .delete();
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(fontSize: 20),
                  ))
            ],
          );
        });
  }
}
