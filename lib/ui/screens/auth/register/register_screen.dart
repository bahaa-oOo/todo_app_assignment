import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/ui/screens/home/home.dart';
import 'package:todo_app/ui/utils/constants.dart';
import 'package:todo_app/ui/utils/dialog_utils.dart';

import '../../../../model/user_dm.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "register";

  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = "";
  String password = "";
  String username = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .25,
              ),
              TextFormField(
                onChanged: (text) {
                  username = text;
                },
                decoration: const InputDecoration(
                  label: Text(
                    "user name",
                  ),
                ),
              ),
              TextFormField(
                onChanged: (text) {
                  email = text;
                },
                decoration: const InputDecoration(
                  label: Text(
                    "Email",
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                onChanged: (text) {
                  password = text;
                },
                decoration: const InputDecoration(
                  label: Text(
                    "Password",
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .2,
              ),
              ElevatedButton(
                  onPressed: () {
                    signUp();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          "Create account",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward)
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void signUp() async {
    try {
      showLoading(context);
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserDM.currentUser =
          UserDM(id: credential.user!.uid, email: email, userName: username);
      registerUserInFireStore(UserDM.currentUser!);
      if (context.mounted) {
        hideLoading(context);
        Navigator.pushNamed(context, Home.routeName);
      }
    } on FirebaseAuthException catch (authError) {
      String message;
      if (authError.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (authError.code == 'email-already-in-use') {
        message = "The account already exists for that email.";
      } else {
        message = Constants.defaultErrorMessage;
      }
      if (context.mounted) {
        hideLoading(context);
        showMessage(context,
            title: "Error", body: message, posButtonTitle: "ok");
      }
    } catch (e) {
      if (context.mounted) {
        hideLoading(context);
        showMessage(context,
            title: "Error",
            body: Constants.defaultErrorMessage,
            posButtonTitle: "ok");
      }
    }
  }

  void registerUserInFireStore(UserDM user) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(UserDM.collectionName);
    DocumentReference newUserDoc = collectionReference.doc(user.id);
    await newUserDoc.set(user.toJson());
  }
}
