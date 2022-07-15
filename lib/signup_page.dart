// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously, avoid_print, unnecessary_new
//@dart=2.9
import 'package:chat_application/login_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isVisible = true;
  final storage = new FlutterSecureStorage();
  var firebase = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var validateEmail;
  var validateName;
  var validPhone;
  var validPassword;
  var validConfirmPassword;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(60),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create your account",
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 2, 62),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 2, 62),
                          fontSize: 20,
                          fontFamily: 'Roboto-Bold'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromARGB(255, 41, 2, 62), width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          cursorColor: Color.fromARGB(255, 41, 2, 62),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorHeight: 28,
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Roboto-Bold'),
                          decoration: InputDecoration(
                            errorText: validateEmail,
                            border: InputBorder.none,
                            hintText: "Enter your email",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Name",
                      style: TextStyle(
                          color: Color.fromARGB(255, 25, 1, 38),
                          fontSize: 20,
                          fontFamily: 'Roboto-Bold'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromARGB(255, 41, 2, 62), width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          cursorColor: Color.fromARGB(255, 41, 2, 62),
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          cursorHeight: 28,
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Roboto-Bold'),
                          decoration: InputDecoration(
                            errorText: validateName,
                            border: InputBorder.none,
                            hintText: "Enter your name",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Phone number",
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 2, 62),
                          fontSize: 20,
                          fontFamily: 'Roboto-Bold'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromARGB(255, 41, 2, 62), width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          cursorColor: Color.fromARGB(255, 41, 2, 62),
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          cursorHeight: 28,
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Roboto-Bold'),
                          decoration: InputDecoration(
                            errorText: validPhone,
                            border: InputBorder.none,
                            hintText: "Enter your phone number",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Password",
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 2, 62),
                          fontSize: 20,
                          fontFamily: 'Roboto-Bold'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromARGB(255, 41, 2, 62), width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          cursorColor: Color.fromARGB(255, 41, 2, 62),
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: isVisible,
                          cursorHeight: 28,
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Roboto-Bold'),
                          decoration: InputDecoration(
                            errorText: validPassword,
                            icon: Icon(
                              Icons.lock_rounded,
                              color: Colors.black54,
                            ),
                            border: InputBorder.none,
                            suffixIcon: (isVisible)
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.visibility_off,
                                      color: Colors.black54,
                                    ))
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });
                                    },
                                    icon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isVisible = !isVisible;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.visibility,
                                          color: Colors.black54,
                                        ))),
                            hintText: "Enter your Password",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 2, 62),
                          fontSize: 20,
                          fontFamily: 'Roboto-Bold'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromARGB(255, 41, 2, 62), width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          cursorColor: Color.fromARGB(255, 41, 2, 62),
                          controller: confirmPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: isVisible,
                          cursorHeight: 28,
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Roboto-Bold'),
                          decoration: InputDecoration(
                            errorText: validConfirmPassword,
                            icon: Icon(
                              Icons.lock_rounded,
                              color: Colors.black54,
                            ),
                            border: InputBorder.none,
                            suffixIcon: (isVisible)
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.visibility_off,
                                      color: Colors.black54,
                                    ))
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });
                                    },
                                    icon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isVisible = !isVisible;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.visibility,
                                          color: Colors.black54,
                                        ))),
                            hintText: "Enter your password again",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      height: 40,
                      width: double.maxFinite,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 41, 2, 62),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            if (!emailController.text
                                .toString()
                                .contains("@")) {
                              setState(() {
                                validateEmail =
                                    "This field must be contain '@'";
                              });
                            } else if (nameController.text.isEmpty) {
                              setState(() {
                                validateName = "This field is required";
                                validateEmail = null;
                              });
                            } else if (phoneController.text.length != 10) {
                              setState(() {
                                validPhone = "Please enter valid phone number";
                                validateName = null;
                              });
                            } else if (passwordController.text.length < 8) {
                              setState(() {
                                validPassword =
                                    "Password should be contain at least 8 characters";
                                validPhone = null;
                              });
                            } else if (passwordController.text !=
                                confirmPasswordController.text) {
                              setState(() {
                                validConfirmPassword = "Password must be same";
                                validPassword = null;
                              });
                            } else {
                              setState(() {
                                validPassword = null;
                                validPhone = null;
                                validateEmail = null;
                                validateName = null;
                                validConfirmPassword = null;
                                isLoading = true;
                              });
                              RegisterAccount();
                            }
                          },
                          child: Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                ),
              ),
            )),
          ),
        ),
        Positioned(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center())
      ],
    );
  }

  void RegisterAccount() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      print(userCredential);
      if (userCredential.user != null) {
        await firebase.collection("users").doc(auth.currentUser.uid).set({
          "Name": nameController.text,
          "Phone": phoneController.text,
          "Email": emailController.text,
          "status": " ",
          "uid": auth.currentUser.uid,
        });
      }
      storage.write(key: "DOC", value: "0");
      showSnackBar(context, "Register successfully! Please login....");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        showSnackBar(context, "Password provided is to weak");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, "Account already exists");
      }
    }
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Color.fromARGB(255, 41, 2, 62),
    content: Text(
      message,
      style: TextStyle(
          fontSize: 20, fontFamily: "Roboto-Bold", color: Colors.white),
    ),
    duration: Duration(seconds: 5),
  ));
}
