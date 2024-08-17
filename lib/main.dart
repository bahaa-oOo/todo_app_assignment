import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/ui/screens/auth/login/login_screen.dart';
import 'package:todo_app/ui/screens/auth/register/register_screen.dart';
import 'package:todo_app/ui/screens/home/home.dart';
import 'package:todo_app/ui/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDvoqTWmoZK-SDSToJtRYY58MggkZqHxgE",
        appId: "1:944261957564:android:822990823f2bfb4901cdb9",
        messagingSenderId: "todo-app-d3df8",
        projectId: "todo-app-d3df8"),
  );
  FirebaseFirestore.instance.settings =
      Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routes: {
        Home.routeName: (_) => const Home(),
        LoginScreen.routeName: (_) => LoginScreen(),
        RegisterScreen.routeName: (_) => RegisterScreen()
      },
      initialRoute: LoginScreen.routeName,
    );
  }
}
