import 'dart:io';
import 'chatMessage.dart';
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
  bool _carregandoImg = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen(
      (user) {
        setState(() {
          _userAtual = user;
        });
      },
    );
  }

  Future<FirebaseUser> _getUser() async {
    if (_userAtual != null)
      return _userAtual;
    else
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
        return _userAtual;
      } catch (erro) {
        return erro;
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
    } else {
      Map<String, dynamic> dados = {
        'uid': user.uid,
        'senderName': user.displayName,
        'senderPhoto': user.photoUrl,
        'Time': Timestamp.now()
      };
      if (image != null) {
        StorageUploadTask task = FirebaseStorage.instance
            .ref()
            .child(UniqueKey().toString())
            .putFile(image);

        setState(
          () {
            _carregandoImg = true;
          },
        );
        StorageTaskSnapshot taskSnapshot = await task.onComplete;
        String url = await taskSnapshot.ref.getDownloadURL();
        dados['ImgUrl'] = url;

        setState(
          () {
            _carregandoImg = false;
          },
        );
      }
      if (text != null) {
        dados['Texto'] = text;
      }
      Firestore.instance.collection('Mensagens').add(dados);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title:
            Text(_userAtual != null ? '${_userAtual.displayName}' : 'Chat :)'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              _googleSignIn.signOut();
              _key.currentState.showSnackBar(
                SnackBar(
                  content: Text('Você saiu com sucesso'),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('Mensagens')
                  .orderBy('Time')
                  .snapshots(),
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
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(docs[index].data,
                            docs[index].data['uid'] == _userAtual?.uid);
                      },
                    );
                }
              },
            ),
          ),
          _carregandoImg ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
