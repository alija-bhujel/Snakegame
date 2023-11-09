// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snakegame/homepage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDD0kgmY_RVz5HrAc2EgggZUCvW9gPvRhk",
          authDomain: "snakegame-778d2.firebaseapp.com",
          projectId: "snakegame-778d2",
          storageBucket: "snakegame-778d2.appspot.com",
          messagingSenderId: "1024274040348",
          appId: "1:1024274040348:web:65c3896a95bddbe36cc1d9",
          measurementId: "G-SV4NSLQSP3"));

  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
      // theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
