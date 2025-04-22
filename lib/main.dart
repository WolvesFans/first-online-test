import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_online/app.dart';
import 'package:test_online/firebase_options.dart';

Future<void> main() async {
  //widget bindings
  WidgetsFlutterBinding.ensureInitialized();

  //initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
