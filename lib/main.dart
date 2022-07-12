// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, import_of_legacy_library_into_null_safe, unused_local_variable, unnecessary_new
//@dart=2.9
import 'package:chat_application/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_page.dart';

final storage = new FlutterSecureStorage();
Widget currentPage = LoginPage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final firebase = FirebaseFirestore.instance;
  String uid = await storage.read(key: "uid");
  if (uid == null) {
    currentPage = LoginPage();
  } else {
    currentPage = HomeScreen();
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: currentPage,
  ));
}
