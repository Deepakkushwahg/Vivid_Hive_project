//@dart=2.9
// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, prefer_typing_uninitialized_variables, use_build_context_synchronously, duplicate_ignore, unnecessary_new, avoid_print
import 'package:chat_application/forgot_password_page.dart';
import 'package:chat_application/homescreen.dart';
import 'package:chat_application/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isVisible = true;
  bool isLoading = false;
  bool isChecked = false;
  var firebase = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final storage = new FlutterSecureStorage();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loadUserPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Image.asset(
                      "lib/images/logo.png",
                      width: 280,
                      height: 280,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Email",
                          style: TextStyle(
                              color: Color.fromARGB(255, 41, 2, 62),
                              fontSize: 20,
                              fontFamily: 'Roboto-Bold'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60, right: 60),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromARGB(255, 41, 2, 62),
                                width: 2)),
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
                              border: InputBorder.none,
                              hintText: "Enter your email",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                              color: Color.fromARGB(255, 41, 2, 62),
                              fontSize: 20,
                              fontFamily: 'Roboto-Bold'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60, right: 60),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromARGB(255, 41, 2, 62),
                                width: 2)),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 45),
                      child: Row(
                        children: [
                          Checkbox(
                              activeColor: Color.fromARGB(255, 41, 2, 62),
                              value: isChecked,
                              onChanged: (value) {
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setBool("remember_me", value);
                                  prefs.setString(
                                      "email", emailController.text);
                                  prefs.setString(
                                      "password", passwordController.text);
                                });
                                setState(() {
                                  isChecked = value;
                                });
                              }),
                          Text("Remember me"),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen()));
                              },
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 41, 2, 62),
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60, right: 60),
                      child: SizedBox(
                        height: 40,
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 41, 2, 62),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              userLogin();
                            },
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Row(
                        children: [
                          Text("Don't have account?"),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUpScreen()));
                              },
                              child: Text(
                                "Create a new account",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 41, 2, 62),
                                ),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
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

  void userLogin() async {
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      await storage.write(key: "uid", value: userCredential.user.uid);
      await Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
      showSnackBar(context, "Login successfully");
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        showSnackBar(context, "User not found for this email");
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, "Wrong password");
      }
    }
  }

  void loadUserPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email") ?? "";
      var remeberMe = prefs.getBool("remember_me") ?? false;
      print(remeberMe);
      print(email);
      if (remeberMe) {
        setState(() {
          isChecked = true;
        });
        emailController.text = email ?? "";
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

// Color.fromARGB(255, 52, 11, 0)
