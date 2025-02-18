import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'message_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MessagesScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }

  Future<void> uploadFile(File file, String path) async {
    try {
      await FirebaseStorage.instance.ref(path).putFile(file);
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}
