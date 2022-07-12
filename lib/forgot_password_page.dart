// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, use_build_context_synchronously
//@dart=2.9
import 'package:chat_application/login_page.dart';
import 'package:chat_application/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: 60,
          ),
          Text(
            "Reset Link will be sent to your email id!",
            style: TextStyle(
                color: Color.fromARGB(255, 41, 2, 62),
                fontSize: 21,
                fontFamily: 'Roboto-Bold'),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
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
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Container(
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
                  style: TextStyle(fontSize: 20, fontFamily: 'Roboto-Bold'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your email",
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60, right: 60),
            child: SizedBox(
              height: 40,
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 41, 2, 62),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    resetPassword();
                  },
                  child: Text(
                    "Send Email",
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
      )),
    );
  }

  void resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      showSnackBar(context,
          "Password reset email has been sent! please go to gmail and reset your password");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(context, "User not found for this email");
      }
    }
  }
}
