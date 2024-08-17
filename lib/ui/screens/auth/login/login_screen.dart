import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/user_dm.dart';
import 'package:todo_app/ui/utils/dialog_utils.dart';

import '../../../utils/constants.dart';
import '../../home/home.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "login";

  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .25,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Welcome back !",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
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
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text(
                    "Password",
                  ),
                ),
              ),
              const SizedBox(
                height: 26,
              ),
              ElevatedButton(
                  onPressed: () {
                    signIn();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward)
                      ],
                    ),
                  )),
              const SizedBox(
                height: 18,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RegisterScreen.routeName);
                },
                child: const Text(
                  "Create account",
                  style: TextStyle(fontSize: 18, color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signIn() async {
    try {
      showLoading(context);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserDM.currentUser = await getUserFromFirestore(credential.user!.uid);
      if (context.mounted) {
        hideLoading(context);
        Navigator.pushNamed(context, Home.routeName);
      }
    } on FirebaseAuthException catch (authError) {
      String message;
      print("FirebaseAuthException: ${authError.code}");
      if (authError.code == 'invalid-credential') {
        message = "Double your email or password and try again!";
      } else {
        message = Constants.defaultErrorMessage;
      }
      if (context.mounted) {
        hideLoading(context);
        showMessage(context,
            title: "Error", body: message, posButtonTitle: "ok");
      }
    } catch (e, stackTrace) {
      print("Catching error: ${e} - $stackTrace");
      if (context.mounted) {
        hideLoading(context);
        showMessage(context,
            title: "Error",
            body: Constants.defaultErrorMessage,
            posButtonTitle: "ok");
      }
    }
  }

  Future<UserDM> getUserFromFirestore(String id) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(UserDM.collectionName);
    DocumentReference userDoc = collectionReference.doc(id);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return UserDM.fromJson(userSnapshot.data() as Map<String, dynamic>);
  }
}
