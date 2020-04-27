import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'chatComposer.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser _userAtual;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen(
      (user) {
        _userAtual = user;
      },
    );
  }

  Future<FirebaseUser> _getUser() async {
    if (_userAtual != null) return _userAtual;
    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      final FirebaseUser firebaseUser = authResult.user;
    } catch (erro) {
      return null;
    }
  }

  void _sendMessage({String text, File image}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _key.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possível efetuar o login,tente novamente'),
        ),
      );
    }

    Map<String, dynamic> dados = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhoto': user.photoUrl
    };
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
      key: _key,
      appBar: AppBar(
        title: Text('Teste'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('Mensagens').snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: false,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            docs[index].data['Texto'],
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
