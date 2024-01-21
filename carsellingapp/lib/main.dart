import 'package:flutter/material.dart';
import 'statecontrollers/authtree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:autoplusapp/pages/onboarding.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 247, 247)),
        useMaterial3: true,
      ),
      home: const OnboardingPage(),
    );
  }
}

