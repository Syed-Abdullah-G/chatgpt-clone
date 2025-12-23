import 'package:chatgptclone/firebase_options.dart';
import 'package:chatgptclone/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Clone',
      theme: ThemeData(brightness: Brightness.light, scaffoldBackgroundColor: const Color(0xFFF7F7F8), fontFamily: 'SF Pro Display'),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
