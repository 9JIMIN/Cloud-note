import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum InputType { H1, T, QUOTE, BULLET, IMG }

extension MarkdownTextStyle on InputType {
  TextStyle get textStyle {
    switch (this) {
      case InputType.QUOTE:
        return TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
          color: Colors.white70,
        );
      case InputType.H1:
        return TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        );
      default:
        return TextStyle(fontSize: 16.0);
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case InputType.H1:
        return EdgeInsets.fromLTRB(16, 24, 16, 8);
        break;
      case InputType.QUOTE:
        return EdgeInsets.fromLTRB(16, 16, 16, 16);
      case InputType.BULLET:
        return EdgeInsets.fromLTRB(24, 8, 16, 8);
      default:
        return EdgeInsets.fromLTRB(16, 8, 16, 8);
    }
  }

  TextAlign get align {
    switch (this) {
      case InputType.QUOTE:
        return TextAlign.center;
        break;
      default:
        return TextAlign.start;
    }
  }

  String get prefix {
    switch (this) {
      case InputType.BULLET:
        return '\u2022 ';
        break;
      default:
        return '';
    }
  }
}

class MarkdownTextField extends StatelessWidget {
  const MarkdownTextField({Key key, this.type, this.controller, this.focusNode})
      : super(key: key);

  final InputType type;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    if (type == InputType.IMG) {
      return FutureBuilder(
        future: ImagePicker().getImage(source: ImageSource.gallery),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            File _image = File(snapshot.data.path);
            return Image.file(_image);
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else {
      return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          cursorColor: Colors.teal,
          textAlign: type.align,
          decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: type.prefix,
              prefixStyle: type.textStyle,
              isDense: true,
              contentPadding: type.padding),
          style: type.textStyle);
    }
  }
}
