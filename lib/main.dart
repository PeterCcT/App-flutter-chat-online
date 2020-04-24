import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ui/chat.dart';

void main() {
  runApp(
    MyApp(),
  );

/*   Firestore.instance
      .collection('col')
      .document('doc')
      .setData({'Text': 'teste'}); */
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.indigoAccent,
        ),
      ),
      home: Chat(),
    );
  }
}
