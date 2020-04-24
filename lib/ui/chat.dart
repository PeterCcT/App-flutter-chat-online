import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'chatComposer.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  void _sendMessage({String text, File image}) async {
    Map<String, dynamic> dados = {};
    if (image != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(UniqueKey().toString())
          .putFile(image);
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      dados['ImgUrl'] = url;
    }
    if (text != null) {
      dados['Texto'] = text;
    }
    Firestore.instance.collection('Mensagens').add(dados);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste'),
        elevation: 0,
      ),
      body: TextComposer(_sendMessage),
    );
  }
}
