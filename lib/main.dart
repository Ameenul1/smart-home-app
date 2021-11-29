import 'package:esp_sample/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ESPApp());
}

class ESPApp extends StatefulWidget {
  @override
  _ESPAppState createState() => _ESPAppState();
}

class _ESPAppState extends State<ESPApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

