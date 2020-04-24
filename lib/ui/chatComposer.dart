import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);
  final Function({String text, File image}) sendMessage;
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _composed = false;
  final _textEditing = TextEditingController();

  void _reset() {
    _textEditing.clear();
    setState(
      () {
        _composed = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final File imagem =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              if (imagem == null)
                return;
              else
                widget.sendMessage(image: imagem);
            },
          ),
          Expanded(
            child: TextField(
              controller: _textEditing,
              decoration:
                  InputDecoration.collapsed(hintText: 'Digite sua mensagem'),
              onChanged: (text) {
                setState(() {
                  _composed = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _composed
                ? () {
                    widget.sendMessage(text: _textEditing.text);
                    _reset();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
